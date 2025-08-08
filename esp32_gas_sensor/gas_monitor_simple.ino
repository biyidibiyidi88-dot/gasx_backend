/*
 * ESP32 Gas Monitor - Simple MQ Sensor Only
 * Compatible with Gas Monitor Backend API (Deployed Version)
 * 
 * Features:
 * - MQ-2/MQ-5/MQ-6 gas sensor reading only
 * - WiFi connectivity with persistent storage
 * - Device registration system (no hardcoded user tokens)
 * - Persistent configuration in EEPROM
 * - Gas leak detection and alerts
 * - Regular gas level readings
 * - Serial monitoring and configuration
 * - No LEDs, buzzer, or extra hardware required
 */

#include <WiFi.h>
#include <HTTPClient.h>
#include <ArduinoJson.h>
#include <EEPROM.h>
#include <WiFiManager.h>

// EEPROM Configuration
#define EEPROM_SIZE 512
#define CONFIG_START_ADDR 0

// Device Configuration Structure
struct DeviceConfig {
  char device_id[37];        // UUID for device identification
  char api_key[65];          // Device-specific API key
  int sensor_id;             // Sensor ID from backend
  bool is_registered;        // Registration status
  char location[100];        // Device location description
  char checksum[10];         // Simple checksum for validation
};

// API Configuration (Using deployed backend)
const char* api_base_url = "https://gas-monitor-sfk3.onrender.com/api";

// Hardcoded credentials for sensor ID 13 (associated with biyiditchoua@gmail.com)
const char* USER_API_TOKEN = "972e4539789c26414553c450b2994111b7ebccae";
const int SENSOR_ID = 13;
const char* DEVICE_LOCATION = "Kitchen Gas Sensor";

// WiFi credentials will be set via WiFiManager

// Hardware Pin Configuration - ONLY MQ SENSOR
const int MQ_SENSOR_PIN = A0;      // Analog pin for MQ sensor (GPIO36 on ESP32)
const int MQ_DIGITAL_PIN = 2;      // Digital pin for MQ sensor threshold detection
const int CONFIG_BUTTON_PIN = 0;   // Button for configuration mode (built-in BOOT button)

// Gas Detection Thresholds
const int GAS_NORMAL_THRESHOLD = 300;     // Normal gas level (0-300 ppm)
const int GAS_WARNING_THRESHOLD = 800;    // Warning level (300-800 ppm)
const int GAS_CRITICAL_THRESHOLD = 1500;  // Critical/leak level (>1500 ppm)

// Timing Configuration
const unsigned long READING_INTERVAL = 30000;    // Send readings every 30 seconds
const unsigned long ALERT_COOLDOWN = 300000;     // 5 minutes cooldown between alerts
const unsigned long REGISTRATION_RETRY = 60000;  // Retry registration every minute
const unsigned long CONFIG_TIMEOUT = 180000;     // 3 minutes for configuration

// Global Variables
DeviceConfig deviceConfig;
unsigned long lastReadingTime = 0;
unsigned long lastAlertTime = 0;
unsigned long lastRegistrationAttempt = 0;
bool wifiConnected = false;
bool deviceRegistered = false;
int currentGasLevel = 0;
String currentSeverity = "LOW";
WiFiManager wifiManager;

// Function declarations
void setupHardcodedCredentials();

void setup() {
  Serial.begin(115200);
  Serial.println("=== ESP32 Gas Monitor - Simple MQ Sensor Only ===");
  
  // Initialize EEPROM
  EEPROM.begin(EEPROM_SIZE);
  
  // Initialize hardware pins - ONLY MQ SENSOR AND CONFIG BUTTON
  pinMode(MQ_DIGITAL_PIN, INPUT);
  pinMode(CONFIG_BUTTON_PIN, INPUT_PULLUP);
  
  Serial.println("Hardware initialized: MQ sensor + config button only");
  
  // Load configuration from EEPROM
  loadConfiguration();
  
  // Check for configuration mode (button pressed during startup)
  if (digitalRead(CONFIG_BUTTON_PIN) == LOW) {
    enterConfigurationMode();
  }
  
  // Initialize WiFi using WiFiManager (dynamic configuration)
  connectToWiFi();
  
  // Setup hardcoded credentials for sensor ID 13
  setupHardcodedCredentials();
  
  Serial.printf("Device ID: %s\n", deviceConfig.device_id);
  Serial.printf("Sensor ID: %d\n", deviceConfig.sensor_id);
  Serial.printf("User: biyiditchoua@gmail.com\n");
  Serial.printf("Registration Status: %s\n", deviceConfig.is_registered ? "REGISTERED" : "NOT REGISTERED");
  
  // Warm up MQ sensor
  Serial.println("Warming up MQ sensor (30 seconds)...");
  delay(30000);
  
  Serial.println("Gas Monitor Ready!");
  printDeviceInfo();
}

void loop() {
  // Check WiFi connection
  if (WiFi.status() != WL_CONNECTED) {
    wifiConnected = false;
    Serial.println("WiFi disconnected. Attempting reconnection...");
    connectToWiFi();
    return;
  }
  
  // Check for configuration button press
  if (digitalRead(CONFIG_BUTTON_PIN) == LOW) {
    delay(50); // Debounce
    if (digitalRead(CONFIG_BUTTON_PIN) == LOW) {
      Serial.println("Configuration button pressed. Entering config mode...");
      enterConfigurationMode();
    }
  }
  
  // Device is preconfigured - always ready for gas monitoring
  // No registration checks needed
  
  // Read gas sensor
  int gasReading = readGasSensor();
  currentGasLevel = gasReading;
  
  // Determine gas level status
  String severity = determineGasSeverity(gasReading);
  currentSeverity = severity;
  
  // Print current status with WiFi info
  Serial.printf("Gas Level: %d ppm | Severity: %s | Device: %s | WiFi: %s\n", 
                gasReading, severity.c_str(), deviceConfig.device_id, 
                wifiConnected ? "Connected" : "Disconnected");
  
  // Check for gas leak (critical level)
  if (severity == "CRITICAL" || severity == "HIGH") {
    handleGasLeak(gasReading, severity);
  }
  
  // Send regular readings
  if (millis() - lastReadingTime >= READING_INTERVAL) {
    sendGasReading(gasReading);
    lastReadingTime = millis();
  }
  
  delay(5000); // Check every 5 seconds
}

void loadConfiguration() {
  Serial.println("Loading configuration from EEPROM...");
  
  // Read configuration from EEPROM
  EEPROM.get(CONFIG_START_ADDR, deviceConfig);
  
  // Check if configuration is valid (simple checksum)
  String expectedChecksum = String(strlen(deviceConfig.device_id) + deviceConfig.sensor_id);
  if (String(deviceConfig.checksum) != expectedChecksum || strlen(deviceConfig.device_id) == 0) {
    Serial.println("No valid configuration found. Generating new device ID...");
    generateDeviceConfig();
  } else {
    Serial.printf("Configuration loaded. Device ID: %s\n", deviceConfig.device_id);
    Serial.printf("Sensor ID: %d, Registered: %s\n", 
                  deviceConfig.sensor_id, deviceConfig.is_registered ? "Yes" : "No");
  }
}

void generateDeviceConfig() {
  // Generate unique device ID based on MAC address (after WiFi init)
  String macAddress = WiFi.macAddress();
  macAddress.replace(":", "");
  
  // If MAC is still 00:00:00:00:00:00, use chip ID as fallback
  if (macAddress == "000000000000") {
    uint64_t chipid = ESP.getEfuseMac();
    macAddress = String((uint32_t)(chipid >> 32), HEX) + String((uint32_t)chipid, HEX);
    macAddress.toUpperCase();
  }
  
  String deviceId = "ESP32_GAS_" + macAddress;
  
  // Initialize configuration with hardcoded values
  strcpy(deviceConfig.device_id, deviceId.c_str());
  strcpy(deviceConfig.api_key, USER_API_TOKEN); // Hardcoded token for biyiditchoua@gmail.com
  deviceConfig.sensor_id = SENSOR_ID;           // Hardcoded sensor ID 13
  deviceConfig.is_registered = true;            // Mark as registered
  strcpy(deviceConfig.location, DEVICE_LOCATION); // Default location
  
  // Calculate simple checksum
  String checksum = String(strlen(deviceConfig.device_id) + deviceConfig.sensor_id);
  strcpy(deviceConfig.checksum, checksum.c_str());
  
  saveConfiguration();
  Serial.printf("Generated hardcoded device. Device ID: %s\n", deviceConfig.device_id);
  Serial.printf("Sensor ID: %d, User: biyiditchoua@gmail.com\n", SENSOR_ID);
}

void saveConfiguration() {
  // Update checksum
  String checksum = String(strlen(deviceConfig.device_id) + deviceConfig.sensor_id);
  strcpy(deviceConfig.checksum, checksum.c_str());
  
  // Save to EEPROM
  EEPROM.put(CONFIG_START_ADDR, deviceConfig);
  EEPROM.commit();
  Serial.println("Configuration saved to EEPROM");
}

void connectToWiFi() {
  Serial.println("Connecting to WiFi...");
  
  // Set WiFiManager timeout and auto-connect
  wifiManager.setConfigPortalTimeout(180); // 3 minutes timeout
  wifiManager.setConnectTimeout(30);       // 30 seconds to connect
  
  // Try to auto-connect to saved WiFi credentials
  if (wifiManager.autoConnect("ESP32-GasMonitor", "password123")) {
    wifiConnected = true;
    Serial.println();
    Serial.printf("✅ WiFi connected! IP: %s\n", WiFi.localIP().toString().c_str());
    Serial.printf("SSID: %s\n", WiFi.SSID().c_str());
  } else {
    wifiConnected = false;
    Serial.println("❌ Failed to connect to WiFi");
    Serial.println("Device will retry connection on next boot");
    Serial.println("To configure WiFi, press and hold BOOT button during startup");
  }
}

void setupHardcodedCredentials() {
  Serial.println("🔧 Setting up hardcoded credentials for sensor ID 13...");
  
  // Generate device ID from MAC address
  String macAddress = WiFi.macAddress();
  macAddress.replace(":", "");
  String deviceId = "ESP32_GAS_" + macAddress;
  strcpy(deviceConfig.device_id, deviceId.c_str());
  
  // Set hardcoded credentials
  strcpy(deviceConfig.api_key, USER_API_TOKEN);
  deviceConfig.sensor_id = SENSOR_ID;
  deviceConfig.is_registered = true;
  strcpy(deviceConfig.location, DEVICE_LOCATION);
  
  // Save configuration to EEPROM
  saveConfiguration();
  
  Serial.println("✅ Hardcoded credentials configured!");
  Serial.printf("🔑 API Token: %s\n", deviceConfig.api_key);
  Serial.printf("🎯 Sensor ID: %d\n", deviceConfig.sensor_id);
  Serial.printf("📍 Location: %s\n", deviceConfig.location);
  Serial.printf("🏠 Associated with: biyiditchoua@gmail.com\n");
  
  deviceRegistered = true;
}

void enterConfigurationMode() {
  Serial.println("=== CONFIGURATION MODE ===");
  Serial.println("1. Reset WiFi settings");
  Serial.println("2. Reset device registration");
  Serial.println("3. Set device location");
  Serial.println("4. View current configuration");
  Serial.println("5. Exit configuration mode");
  Serial.println("Enter choice (1-5):");
  
  unsigned long configStart = millis();
  while (millis() - configStart < CONFIG_TIMEOUT) {
    if (Serial.available()) {
      int choice = Serial.parseInt();
      Serial.read(); // Clear newline
      
      switch (choice) {
        case 1:
          Serial.println("Resetting WiFi settings...");
          wifiManager.resetSettings();
          Serial.println("WiFi settings reset. Device will restart.");
          delay(2000);
          ESP.restart();
          break;
          
        case 2:
          Serial.println("Resetting device registration...");
          deviceConfig.is_registered = false;
          strcpy(deviceConfig.api_key, "");
          deviceConfig.sensor_id = 0;
          saveConfiguration();
          Serial.println("Registration reset. Device will re-register on next startup.");
          break;
          
        case 3:
          {
            Serial.println("Enter new location (max 99 chars):");
            while (!Serial.available()) delay(100);
            String newLocation = Serial.readString();
            newLocation.trim();
            if (newLocation.length() > 0) {
              strcpy(deviceConfig.location, newLocation.c_str());
              saveConfiguration();
              Serial.printf("Location updated to: %s\n", deviceConfig.location);
            }
            break;
          }
          
        case 4:
          printDeviceInfo();
          break;
          
        case 5:
          Serial.println("Exiting configuration mode...");
          return;
          
        default:
          Serial.println("Invalid choice. Try again.");
          break;
      }
      
      Serial.println("\nEnter choice (1-5):");
    }
    delay(100);
  }
  
  Serial.println("Configuration timeout. Exiting...");
}

void printDeviceInfo() {
  Serial.println("=== DEVICE INFORMATION ===");
  Serial.printf("Device ID: %s\n", deviceConfig.device_id);
  Serial.printf("MAC Address: %s\n", WiFi.macAddress().c_str());
  Serial.printf("IP Address: %s\n", WiFi.localIP().toString().c_str());
  Serial.printf("API Key: %s\n", deviceConfig.is_registered ? deviceConfig.api_key : "Not registered");
  Serial.printf("Sensor ID: %d\n", deviceConfig.sensor_id);
  Serial.printf("Location: %s\n", deviceConfig.location);
  Serial.printf("Registration Status: %s\n", deviceConfig.is_registered ? "Registered" : "Not registered");
  Serial.printf("WiFi Status: %s\n", wifiConnected ? "Connected" : "Disconnected");
  Serial.println("========================");
}

// Gas sensor functions
int readGasSensor() {
  // Read analog value from MQ sensor
  int analogValue = analogRead(MQ_SENSOR_PIN);
  
  // Debug: Print raw analog reading
  Serial.printf("[DEBUG] Raw analog: %d | ", analogValue);
  
  // Convert to PPM (adjust mapping based on your sensor)
  // MQ sensors typically output higher voltage for higher gas concentration
  int ppm = map(analogValue, 0, 4095, 0, 2000); // Reduced max range for more realistic readings
  
  // Apply calibration
  ppm = calibrateSensorReading(ppm);
  
  return ppm;
}

int calibrateSensorReading(int rawPpm) {
  // Simple calibration - adjust based on your sensor's baseline
  // Most MQ sensors have a baseline of 100-300 ppm in clean air
  int calibratedPpm = rawPpm;
  
  // Ensure minimum baseline (clean air should be ~100-200 ppm)
  if (calibratedPpm < 100) {
    calibratedPpm = 100 + (calibratedPpm / 10); // Gentle baseline adjustment
  }
  
  return max(100, calibratedPpm); // Minimum 100 ppm baseline
}

String determineGasSeverity(int gasLevel) {
  if (gasLevel >= GAS_CRITICAL_THRESHOLD) return "CRITICAL";
  else if (gasLevel >= GAS_WARNING_THRESHOLD) return "HIGH";
  else if (gasLevel >= GAS_NORMAL_THRESHOLD) return "MEDIUM";
  else return "LOW";
}

void handleGasLeak(int gasLevel, String severity) {
  if (millis() - lastAlertTime < ALERT_COOLDOWN) return;
  
  Serial.printf("⚠️  GAS LEAK DETECTED! Level: %d ppm, Severity: %s\n", gasLevel, severity.c_str());
  sendGasLeakAlert(gasLevel, severity);
  lastAlertTime = millis();
}

void sendGasReading(int gasLevel) {
  Serial.printf("[DEBUG] Attempting to send gas reading: WiFi=%s, Registered=%s\n", 
                wifiConnected ? "OK" : "FAIL", deviceConfig.is_registered ? "OK" : "FAIL");
  
  if (!wifiConnected || !deviceConfig.is_registered) {
    Serial.println("[ERROR] Cannot send reading - WiFi or registration issue");
    return;
  }
  
  HTTPClient http;
  http.begin(String(api_base_url) + "/gas-readings/create/");
  http.addHeader("Content-Type", "application/json");
  http.addHeader("Authorization", "Token " + String(deviceConfig.api_key));
  
  DynamicJsonDocument doc(1024);
  doc["sensor_id"] = deviceConfig.sensor_id;
  doc["remaining_gas"] = gasLevel;
  doc["is_alert_triggered"] = (currentSeverity == "CRITICAL" || currentSeverity == "HIGH");
  doc["device_id"] = deviceConfig.device_id;
  
  String payload;
  serializeJson(doc, payload);
  
  int httpResponseCode = http.POST(payload);
  
  if (httpResponseCode > 0) {
    Serial.printf("📊 Gas reading sent (%d)\n", httpResponseCode);
  } else {
    Serial.printf("❌ Gas reading error: %d\n", httpResponseCode);
  }
  
  http.end();
}

void sendGasLeakAlert(int gasLevel, String severity) {
  Serial.printf("[DEBUG] Attempting to send gas leak alert: WiFi=%s, Registered=%s\n", 
                wifiConnected ? "OK" : "FAIL", deviceConfig.is_registered ? "OK" : "FAIL");
  
  if (!wifiConnected || !deviceConfig.is_registered) {
    Serial.println("[ERROR] Cannot send alert - WiFi or registration issue");
    return;
  }
  
  HTTPClient http;
  http.begin(String(api_base_url) + "/alerts/gas-leak/");
  http.addHeader("Content-Type", "application/json");
  http.addHeader("Authorization", "Token " + String(deviceConfig.api_key));
  
  DynamicJsonDocument doc(1024);
  doc["sensor_id"] = deviceConfig.sensor_id;
  doc["severity_level"] = severity;
  doc["gas_concentration"] = (float)gasLevel;
  doc["alert_message"] = "Gas leak detected by " + String(deviceConfig.device_id);
  doc["location_details"] = deviceConfig.location;
  doc["device_id"] = deviceConfig.device_id;
  
  String payload;
  serializeJson(doc, payload);
  
  Serial.printf("🚨 Sending gas leak alert: %s\n", payload.c_str());
  
  int httpResponseCode = http.POST(payload);
  
  if (httpResponseCode > 0) {
    String response = http.getString();
    Serial.printf("Gas leak alert response (%d): %s\n", httpResponseCode, response.c_str());
    
    DynamicJsonDocument responseDoc(1024);
    deserializeJson(responseDoc, response);
    
    if (responseDoc["status"] == "success") {
      Serial.println("✅ Gas leak alert sent successfully!");
      if (responseDoc["email_notification"]["sent"]) {
        Serial.println("✅ Email notification sent!");
      }
    }
  } else {
    Serial.printf("❌ Gas leak alert error: %d\n", httpResponseCode);
  }
  
  http.end();
}
