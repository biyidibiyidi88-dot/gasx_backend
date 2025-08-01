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
  
  // Initialize WiFi
  connectToWiFi();
  
  // Register device if not already registered
  if (wifiConnected && !deviceConfig.is_registered) {
    registerDevice();
  }
  
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
  
  // Try to register device if not registered
  if (!deviceConfig.is_registered && millis() - lastRegistrationAttempt > REGISTRATION_RETRY) {
    registerDevice();
    lastRegistrationAttempt = millis();
  }
  
  // Only proceed with gas monitoring if device is registered
  if (!deviceConfig.is_registered) {
    Serial.println("Device not registered. Please complete registration first.");
    delay(10000);
    return;
  }
  
  // Read gas sensor
  int gasReading = readGasSensor();
  currentGasLevel = gasReading;
  
  // Determine gas level status
  String severity = determineGasSeverity(gasReading);
  currentSeverity = severity;
  
  // Print current status
  Serial.printf("Gas Level: %d ppm | Severity: %s | Device: %s\n", 
                gasReading, severity.c_str(), deviceConfig.device_id);
  
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
  // Generate unique device ID based on MAC address
  String macAddress = WiFi.macAddress();
  macAddress.replace(":", "");
  String deviceId = "ESP32_GAS_" + macAddress;
  
  // Initialize configuration
  strcpy(deviceConfig.device_id, deviceId.c_str());
  strcpy(deviceConfig.api_key, ""); // Will be set during registration
  deviceConfig.sensor_id = 0;       // Will be set during registration
  deviceConfig.is_registered = false;
  strcpy(deviceConfig.location, "Unknown Location");
  
  // Calculate simple checksum
  String checksum = String(strlen(deviceConfig.device_id) + deviceConfig.sensor_id);
  strcpy(deviceConfig.checksum, checksum.c_str());
  
  saveConfiguration();
  Serial.printf("Generated new device configuration. Device ID: %s\n", deviceConfig.device_id);
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
  // Use WiFiManager for easy WiFi configuration
  wifiManager.setConfigPortalTimeout(CONFIG_TIMEOUT);
  
  if (!wifiManager.autoConnect("GasMonitor_Setup")) {
    Serial.println("Failed to connect to WiFi. Restarting...");
    delay(3000);
    ESP.restart();
  }
  
  wifiConnected = true;
  Serial.println();
  Serial.printf("WiFi Connected! IP: %s\n", WiFi.localIP().toString().c_str());
}

void registerDevice() {
  if (!wifiConnected) return;
  
  Serial.println("Attempting device registration...");
  
  HTTPClient http;
  http.begin(String(api_base_url) + "/devices/register/");
  http.addHeader("Content-Type", "application/json");
  
  // Create registration payload
  DynamicJsonDocument doc(1024);
  doc["device_id"] = deviceConfig.device_id;
  doc["device_type"] = "ESP32_GAS_SENSOR";
  doc["mac_address"] = WiFi.macAddress();
  doc["ip_address"] = WiFi.localIP().toString();
  doc["firmware_version"] = "1.0.0";
  doc["sensor_type"] = "MQ_GAS_SENSOR";
  doc["location"] = deviceConfig.location;
  
  String payload;
  serializeJson(doc, payload);
  
  Serial.printf("Registration payload: %s\n", payload.c_str());
  
  int httpResponseCode = http.POST(payload);
  
  if (httpResponseCode > 0) {
    String response = http.getString();
    Serial.printf("Registration response (%d): %s\n", httpResponseCode, response.c_str());
    
    if (httpResponseCode == 200 || httpResponseCode == 201) {
      // Parse response to get API key and sensor ID
      DynamicJsonDocument responseDoc(1024);
      deserializeJson(responseDoc, response);
      
      if (responseDoc["status"] == "success") {
        strcpy(deviceConfig.api_key, responseDoc["api_key"]);
        deviceConfig.sensor_id = responseDoc["sensor_id"];
        deviceConfig.is_registered = true;
        
        saveConfiguration();
        
        Serial.println("✅ Device registered successfully!");
        Serial.printf("API Key: %s\n", deviceConfig.api_key);
        Serial.printf("Sensor ID: %d\n", deviceConfig.sensor_id);
      }
    }
  } else {
    Serial.printf("Registration failed: %d\n", httpResponseCode);
  }
  
  http.end();
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
  int analogValue = analogRead(MQ_SENSOR_PIN);
  int ppm = map(analogValue, 0, 4095, 0, 5000);
  ppm = calibrateSensorReading(ppm);
  return ppm;
}

int calibrateSensorReading(int rawPpm) {
  int calibratedPpm = (rawPpm * 0.8) + 50;
  return max(0, calibratedPpm);
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
  if (!wifiConnected || !deviceConfig.is_registered) return;
  
  HTTPClient http;
  http.begin(String(api_base_url) + "/gas-readings/create/");
  http.addHeader("Content-Type", "application/json");
  http.addHeader("Authorization", "Device " + String(deviceConfig.api_key));
  
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
  if (!wifiConnected || !deviceConfig.is_registered) return;
  
  HTTPClient http;
  http.begin(String(api_base_url) + "/alerts/gas-leak/");
  http.addHeader("Content-Type", "application/json");
  http.addHeader("Authorization", "Device " + String(deviceConfig.api_key));
  
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
