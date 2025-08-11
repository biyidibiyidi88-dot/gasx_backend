/*
 * ESP32 Gas Monitor with Weight Measurement - Enhanced Version
 * Compatible with Gas Monitor Backend API (Deployed Version)
 * 
 * Features:
 * - MQ-2/MQ-5/MQ-6 gas sensor reading
 * - HX711 Load Cell weight measurement with persistent calibration
 * - WiFi connectivity with persistent storage
 * - Device registration system
 * - Gas leak detection and alerts
 * - Regular gas level and weight readings
 * - One-time calibration that persists across power cycles
 */

#include <WiFi.h>
#include <HTTPClient.h>
#include <ArduinoJson.h>
#include <EEPROM.h>
#include <WiFiManager.h>
#include <Preferences.h>
#include "HX711.h"

// EEPROM Configuration
#define EEPROM_SIZE 512
#define CONFIG_START_ADDR 0

// HX711 Load Cell Configuration
const int LOADCELL_DOUT_PIN = 2;  // Connect to DT pin
const int LOADCELL_SCK_PIN = 16;  // Connect to SCK pin

// Hardcoded Configuration - No device registration needed
const char* API_TOKEN = "972e4539789c26414553c450b2994111b7ebccae";
const int SENSOR_ID = 13;
const char* DEVICE_ID = "ESP32_GAS_001";
const char* LOCATION = "Home Gas Monitor";

// API Configuration
const char* api_base_url = "https://gas-monitor-sfk3.onrender.com/api";

// Hardware Pin Configuration
const int MQ_SENSOR_PIN = 34;
const int MQ_DIGITAL_PIN = 4;
const int LED_NORMAL_PIN = 5;
const int LED_WARNING_PIN = 18;
const int LED_CRITICAL_PIN = 19;
const int BUZZER_PIN = 21;
const int CONFIG_BUTTON_PIN = 0;

// Gas Detection Thresholds
const int GAS_NORMAL_THRESHOLD = 300;
const int GAS_WARNING_THRESHOLD = 800;
const int GAS_CRITICAL_THRESHOLD = 1500;

// Weight Configuration
const float TANK_EMPTY_WEIGHT = 15.0;  // Empty tank weight in kg
const float TANK_FULL_WEIGHT = 35.0;   // Full tank weight in kg
const float MIN_WEIGHT_CHANGE = 0.05;

// Timing Configuration
const unsigned long READING_INTERVAL = 30000;
const unsigned long WEIGHT_READING_INTERVAL = 5000;
const unsigned long ALERT_COOLDOWN = 300000;

// Global Variables
HX711 scale;
Preferences preferences;

unsigned long lastReadingTime = 0;
unsigned long lastWeightReadingTime = 0;
unsigned long lastAlertTime = 0;
bool wifiConnected = false;
bool scaleCalibrated = false;
int currentGasLevel = 0;
float currentWeight = 0.0;
float lastStableWeight = 0.0;
String currentSeverity = "LOW";
WiFiManager wifiManager;

float calibration_factor = 1.0;
bool calibration_in_progress = false;

void setup() {
  Serial.begin(115200);
  Serial.println("=== ESP32 Gas Monitor with Weight Measurement ===");
  
  // Initialize EEPROM and Preferences
  EEPROM.begin(EEPROM_SIZE);
  preferences.begin("gas_monitor", false);
  
  // Initialize hardware pins
  pinMode(MQ_DIGITAL_PIN, INPUT);
  pinMode(LED_NORMAL_PIN, OUTPUT);
  pinMode(LED_WARNING_PIN, OUTPUT);
  pinMode(LED_CRITICAL_PIN, OUTPUT);
  pinMode(BUZZER_PIN, OUTPUT);
  pinMode(CONFIG_BUTTON_PIN, INPUT_PULLUP);
  
  testLEDs();
  initializeLoadCell();
  
  connectToWiFi();
  
  Serial.println("Warming up MQ sensor...");
  setStatusLED("warming");
  delay(30000);
  
  Serial.println("Gas Monitor with Weight Measurement Ready!");
  printDeviceInfo();
  setStatusLED("normal");
}

void loop() {
  if (WiFi.status() != WL_CONNECTED) {
    wifiConnected = false;
    setStatusLED("error");
    connectToWiFi();
    return;
  }
  
  if (digitalRead(CONFIG_BUTTON_PIN) == LOW) {
    delay(100);
    if (digitalRead(CONFIG_BUTTON_PIN) == LOW) {
      enterConfigurationMode();
    }
  }
  
  currentGasLevel = readGasSensor();
  currentSeverity = determineGasSeverity(currentGasLevel);
  
  if (millis() - lastWeightReadingTime >= WEIGHT_READING_INTERVAL) {
    readWeightSensor();
    lastWeightReadingTime = millis();
  }
  
  updateStatusIndicators(currentSeverity);
  
  if (currentSeverity == "CRITICAL" || currentSeverity == "HIGH") {
    handleGasLeak(currentGasLevel, currentSeverity);
  }
  
  if (millis() - lastReadingTime >= READING_INTERVAL) {
    if (wifiConnected) {
      sendGasReading(currentGasLevel);
      sendWeightReading(currentWeight);
    }
    lastReadingTime = millis();
  }
  
  handleSerialCommands();
  delay(1000);
}

void initializeLoadCell() {
  Serial.println("Initializing HX711 Load Cell...");
  scale.begin(LOADCELL_DOUT_PIN, LOADCELL_SCK_PIN);
  delay(2000);
  
  bool connected = false;
  for (int i = 0; i < 10; i++) {
    if (scale.is_ready()) {
      connected = true;
      break;
    }
    Serial.printf("Attempt %d - Waiting for HX711...\n", i + 1);
    delay(500);
  }
  
  if (connected) {
    Serial.println("✅ HX711 connected successfully!");
    loadCalibration();
    
    if (scaleCalibrated) {
      Serial.printf("✅ Using saved calibration factor: %.2f\n", calibration_factor);
      scale.set_scale(calibration_factor);
      scale.tare();
    } else {
      Serial.println("⚠️  Scale not calibrated. Use 'calibrate' command to calibrate.");
      scale.set_scale();
      scale.tare();
    }
  } else {
    Serial.println("❌ HX711 not found! Check wiring.");
  }
}

void loadCalibration() {
  calibration_factor = preferences.getFloat("cal_factor", 0.0);
  scaleCalibrated = preferences.getBool("cal_done", false);
  
  if (scaleCalibrated && calibration_factor != 0.0) {
    Serial.printf("Loaded calibration factor: %.2f\n", calibration_factor);
  } else {
    Serial.println("No valid calibration found.");
    scaleCalibrated = false;
  }
}

void saveCalibration() {
  preferences.putFloat("cal_factor", calibration_factor);
  preferences.putBool("cal_done", true);
  Serial.printf("✅ Calibration saved: %.2f\n", calibration_factor);
}

void readWeightSensor() {
  if (!scale.is_ready() || !scaleCalibrated) return;
  
  float weight = scale.get_units(5);
  
  if (abs(weight - lastStableWeight) > MIN_WEIGHT_CHANGE) {
    currentWeight = weight;
    lastStableWeight = weight;
    
    float gasWeight = max(0.0f, currentWeight - TANK_EMPTY_WEIGHT);
    float gasPercentage = (gasWeight / (TANK_FULL_WEIGHT - TANK_EMPTY_WEIGHT)) * 100.0;
    gasPercentage = constrain(gasPercentage, 0.0, 100.0);
    
    Serial.printf("Weight: %.2f kg | Gas: %.2f kg (%.1f%%)\n", 
                  currentWeight, gasWeight, gasPercentage);
    
    if (gasPercentage <= 10.0 && millis() - lastAlertTime >= ALERT_COOLDOWN) {
      handleLowGasAlert(gasPercentage);
    }
  }
}

void handleSerialCommands() {
  if (Serial.available()) {
    String command = Serial.readStringUntil('\n');
    command.trim();
    command.toLowerCase();
    
    if (command == "calibrate") {
      startWeightCalibration();
    } else if (command == "tare") {
      if (scaleCalibrated) {
        scale.tare();
        Serial.println("✅ Scale tared (zeroed)");
      }
    } else if (command == "weight") {
      if (scaleCalibrated && scale.is_ready()) {
        float weight = scale.get_units(3);
        Serial.printf("Current weight: %.2f kg\n", weight);
      }
    } else if (command == "reset_cal") {
      preferences.remove("cal_factor");
      preferences.remove("cal_done");
      scaleCalibrated = false;
      calibration_factor = 1.0;
      Serial.println("✅ Calibration reset. Use 'calibrate' to recalibrate.");
    } else if (command == "help") {
      printCommands();
    }
  }
}

void printCommands() {
  Serial.println("\n=== Available Commands ===");
  Serial.println("calibrate - Start weight calibration process");
  Serial.println("tare      - Zero the scale");
  Serial.println("weight    - Show current weight");
  Serial.println("reset_cal - Reset calibration");
  Serial.println("help      - Show this help");
  Serial.println("========================\n");
}

void startWeightCalibration() {
  if (calibration_in_progress || !scale.is_ready()) return;
  
  calibration_in_progress = true;
  Serial.println("\n🔧 === WEIGHT CALIBRATION MODE ===");
  
  Serial.println("Step 1: Remove ALL weight from the scale");
  Serial.println("Press ENTER when scale is empty...");
  waitForEnter();
  
  scale.tare();
  Serial.println("✅ Scale tared (zeroed)");
  
  Serial.println("\nStep 2: Enter the weight of your calibration object");
  Serial.print("Known weight (kg): ");
  
  float known_weight = 0.0;
  while (known_weight <= 0) {
    if (Serial.available()) {
      known_weight = Serial.parseFloat();
      clearSerialBuffer();
    }
    delay(100);
  }
  
  Serial.printf("Known weight set to: %.2f kg\n", known_weight);
  
  Serial.println("\nStep 3: Place the known weight on the scale");
  Serial.println("Press ENTER when weight is placed...");
  waitForEnter();
  
  Serial.println("Taking calibration readings...");
  delay(2000);
  
  long reading = scale.get_value(10);
  
  if (reading != 0) {
    calibration_factor = reading / known_weight;
    scale.set_scale(calibration_factor);
    
    Serial.printf("✅ Calibration factor: %.2f\n", calibration_factor);
    
    float measured_weight = scale.get_units(5);
    Serial.printf("Verification - Measured: %.2f kg\n", measured_weight);
    
    Serial.println("\nSave this calibration? (y/n): ");
    char response = waitForResponse();
    
    if (response == 'y' || response == 'Y') {
      scaleCalibrated = true;
      saveCalibration();
      Serial.println("✅ Calibration saved permanently!");
    } else {
      Serial.println("❌ Calibration not saved.");
      scaleCalibrated = false;
    }
  } else {
    Serial.println("❌ Error: No reading detected.");
  }
  
  calibration_in_progress = false;
  Serial.println("=== CALIBRATION COMPLETE ===\n");
}

void waitForEnter() {
  clearSerialBuffer();
  while (!Serial.available()) delay(100);
  clearSerialBuffer();
}

char waitForResponse() {
  clearSerialBuffer();
  while (!Serial.available()) delay(100);
  char response = Serial.read();
  clearSerialBuffer();
  return response;
}

void clearSerialBuffer() {
  while (Serial.available()) Serial.read();
}

void handleLowGasAlert(float gasPercentage) {
  Serial.printf("🚨 LOW GAS ALERT: %.1f%% remaining\n", gasPercentage);
  // Note: Backend automatically creates alerts when gas readings are low
  // No need to send separate alert - just log it
  lastAlertTime = millis();
  
  // Visual/audio alert
  for (int i = 0; i < 3; i++) {
    digitalWrite(LED_CRITICAL_PIN, HIGH);
    digitalWrite(BUZZER_PIN, HIGH);
    delay(200);
    digitalWrite(LED_CRITICAL_PIN, LOW);
    digitalWrite(BUZZER_PIN, LOW);
    delay(200);
  }
}

void connectToWiFi() {
  if (wifiManager.autoConnect("GasMonitor-Setup")) {
    wifiConnected = true;
    Serial.println("✅ WiFi connected!");
  } else {
    wifiConnected = false;
  }
}

void printDeviceInfo() {
  Serial.println("\n=== Device Information ===");
  Serial.printf("Device ID: %s\n", DEVICE_ID);
  Serial.printf("Location: %s\n", LOCATION);
  Serial.printf("Sensor ID: %d\n", SENSOR_ID);
  Serial.printf("WiFi Status: %s\n", wifiConnected ? "Connected" : "Disconnected");
  Serial.printf("Scale Calibrated: %s\n", scaleCalibrated ? "Yes" : "No");
  if (scaleCalibrated) {
    Serial.printf("Calibration Factor: %.2f\n", calibration_factor);
  }
  Serial.println("============================\n");
}

int readGasSensor() {
  int analogValue = analogRead(MQ_SENSOR_PIN);
  return map(analogValue, 0, 4095, 0, 2000);
}

String determineGasSeverity(int gasLevel) {
  if (gasLevel >= GAS_CRITICAL_THRESHOLD) return "CRITICAL";
  if (gasLevel >= GAS_WARNING_THRESHOLD) return "HIGH";
  if (gasLevel >= GAS_NORMAL_THRESHOLD) return "MEDIUM";
  return "LOW";
}

void updateStatusIndicators(String severity) {
  digitalWrite(LED_NORMAL_PIN, LOW);
  digitalWrite(LED_WARNING_PIN, LOW);
  digitalWrite(LED_CRITICAL_PIN, LOW);
  digitalWrite(BUZZER_PIN, LOW);
  
  if (severity == "CRITICAL") {
    digitalWrite(LED_CRITICAL_PIN, HIGH);
    digitalWrite(BUZZER_PIN, HIGH);
  } else if (severity == "HIGH") {
    digitalWrite(LED_CRITICAL_PIN, HIGH);
  } else if (severity == "MEDIUM") {
    digitalWrite(LED_WARNING_PIN, HIGH);
  } else {
    digitalWrite(LED_NORMAL_PIN, HIGH);
  }
}

void setStatusLED(String status) {
  digitalWrite(LED_NORMAL_PIN, LOW);
  digitalWrite(LED_WARNING_PIN, LOW);
  digitalWrite(LED_CRITICAL_PIN, LOW);
  
  if (status == "normal") {
    digitalWrite(LED_NORMAL_PIN, HIGH);
  } else if (status == "warning") {
    digitalWrite(LED_WARNING_PIN, HIGH);
  } else if (status == "error") {
    digitalWrite(LED_CRITICAL_PIN, HIGH);
  } else if (status == "warming") {
    for (int i = 0; i < 3; i++) {
      digitalWrite(LED_WARNING_PIN, HIGH);
      delay(300);
      digitalWrite(LED_WARNING_PIN, LOW);
      delay(300);
    }
  }
}

void testLEDs() {
  Serial.println("Testing LEDs...");
  digitalWrite(LED_NORMAL_PIN, HIGH);
  delay(300);
  digitalWrite(LED_NORMAL_PIN, LOW);
  digitalWrite(LED_WARNING_PIN, HIGH);
  delay(300);
  digitalWrite(LED_WARNING_PIN, LOW);
  digitalWrite(LED_CRITICAL_PIN, HIGH);
  delay(300);
  digitalWrite(LED_CRITICAL_PIN, LOW);
  digitalWrite(BUZZER_PIN, HIGH);
  delay(150);
  digitalWrite(BUZZER_PIN, LOW);
}
  } else if (status == "warming") {
    for (int i = 0; i < 3; i++) {
      digitalWrite(LED_NORMAL_PIN, HIGH);
      delay(300);
      digitalWrite(LED_NORMAL_PIN, LOW);
      digitalWrite(LED_WARNING_PIN, HIGH);
      delay(300);
      digitalWrite(LED_WARNING_PIN, LOW);
      digitalWrite(LED_CRITICAL_PIN, HIGH);
      delay(300);
      digitalWrite(LED_CRITICAL_PIN, LOW);
    }
  }
}

void testLEDs() {
  Serial.println("Testing LEDs...");
  digitalWrite(LED_NORMAL_PIN, HIGH);
  delay(500);
  digitalWrite(LED_NORMAL_PIN, LOW);
  digitalWrite(LED_WARNING_PIN, HIGH);
  delay(500);
  digitalWrite(LED_WARNING_PIN, LOW);
  digitalWrite(LED_CRITICAL_PIN, HIGH);
  delay(500);
  digitalWrite(LED_CRITICAL_PIN, LOW);
  digitalWrite(BUZZER_PIN, HIGH);
  delay(200);
  digitalWrite(BUZZER_PIN, LOW);
}

void handleGasLeak(int gasLevel, String severity) {
  if (millis() - lastAlertTime < ALERT_COOLDOWN) return;
  sendGasLeakAlert(gasLevel, severity);
  lastAlertTime = millis();
}

void sendGasReading(int gasLevel) {
  if (!wifiConnected) return;
  
  HTTPClient http;
  http.begin(String(api_base_url) + "/gas-readings/create/");
  http.addHeader("Content-Type", "application/json");
  http.addHeader("Authorization", "Token " + String(API_TOKEN));
  
  // Convert gas sensor reading to estimated remaining gas (simplified)
  // This is a rough estimation - you may need to calibrate this
  float estimatedGas = map(gasLevel, 0, 2000, 0, 20); // Map sensor reading to 0-20kg
  
  DynamicJsonDocument doc(1024);
  doc["sensor"] = SENSOR_ID;
  doc["remaining_gas"] = estimatedGas;
  
  String payload;
  serializeJson(doc, payload);
  
  int httpResponseCode = http.POST(payload);
  if (httpResponseCode > 0) {
    Serial.printf("Gas reading sent (%d) - Estimated: %.1fkg\n", httpResponseCode, estimatedGas);
    if (httpResponseCode != 200 && httpResponseCode != 201) {
      String response = http.getString();
      Serial.println("Response: " + response);
    }
  } else {
    Serial.printf("Gas reading error: %s\n", http.errorToString(httpResponseCode).c_str());
  }
  http.end();
}

void sendWeightReading(float weight) {
  if (!wifiConnected || !scaleCalibrated) return;
  
  HTTPClient http;
  http.begin(String(api_base_url) + "/gas-readings/create/");
  http.addHeader("Content-Type", "application/json");
  http.addHeader("Authorization", "Token " + String(API_TOKEN));
  
  float gasWeight = max(0.0f, weight - TANK_EMPTY_WEIGHT);
  float gasPercentage = (gasWeight / (TANK_FULL_WEIGHT - TANK_EMPTY_WEIGHT)) * 100.0;
  gasPercentage = constrain(gasPercentage, 0.0, 100.0);
  
  DynamicJsonDocument doc(1024);
  doc["sensor"] = SENSOR_ID;
  doc["remaining_gas"] = gasWeight;  // Backend expects this field
  
  String payload;
  serializeJson(doc, payload);
  
  int httpResponseCode = http.POST(payload);
  if (httpResponseCode > 0) {
    Serial.printf("Weight reading sent (%d) - Gas: %.1fkg (%.1f%%)\n", httpResponseCode, gasWeight, gasPercentage);
    if (httpResponseCode != 200 && httpResponseCode != 201) {
      String response = http.getString();
      Serial.println("Response: " + response);
    }
  } else {
    Serial.printf("Weight reading error: %s\n", http.errorToString(httpResponseCode).c_str());
  }
  http.end();
}

void sendGasLeakAlert(int gasLevel, String severity) {
  if (!wifiConnected) return;
  
  HTTPClient http;
  http.begin(String(api_base_url) + "/alerts/gas-leak/");
  http.addHeader("Content-Type", "application/json");
  http.addHeader("Authorization", "Token " + String(API_TOKEN));
  
  DynamicJsonDocument doc(1024);
  doc["sensor_id"] = SENSOR_ID;
  doc["severity_level"] = severity;
  doc["gas_concentration"] = (float)gasLevel;
  doc["alert_message"] = "Gas leak detected by ESP32";
  
  String payload;
  serializeJson(doc, payload);
  
  int httpResponseCode = http.POST(payload);
  if (httpResponseCode > 0) {
    Serial.printf("Gas leak alert sent (%d)\n", httpResponseCode);
    if (httpResponseCode != 200 && httpResponseCode != 201) {
      String response = http.getString();
      Serial.println("Response: " + response);
    }
  } else {
    Serial.printf("Gas leak alert error: %s\n", http.errorToString(httpResponseCode).c_str());
  }
  http.end();
}

void sendLowGasWeightAlert(float gasPercentage) {
  if (!wifiConnected) return;
  
  HTTPClient http;
  http.begin(String(api_base_url) + "/alerts/gas-leak/");
  http.addHeader("Content-Type", "application/json");
  http.addHeader("Authorization", "Token " + String(API_TOKEN));
  
  String severity = gasPercentage <= 5.0 ? "CRITICAL" : "HIGH";
  
  DynamicJsonDocument doc(1024);
  doc["sensor_id"] = SENSOR_ID;
  doc["severity_level"] = severity;
  doc["alert_message"] = "Low gas level: " + String(gasPercentage, 1) + "% remaining";
  doc["gas_percentage"] = gasPercentage;
  doc["alert_type"] = "LOW_GAS_WEIGHT";
  doc["device_id"] = DEVICE_ID;
  
  String payload;
  serializeJson(doc, payload);
  
  int httpResponseCode = http.POST(payload);
  if (httpResponseCode > 0) {
    Serial.printf("Low gas weight alert sent (%d)\n", httpResponseCode);
  }
  http.end();
}

void enterConfigurationMode() {
  Serial.println("\n🔧 === CONFIGURATION MODE ===");
  Serial.println("Commands: calibrate, info, exit");
  
  while (true) {
    if (Serial.available()) {
      String command = Serial.readStringUntil('\n');
      command.trim();
      
      if (command == "calibrate") {
        startWeightCalibration();
      } else if (command == "info") {
        printDeviceInfo();
      } else if (command == "exit") {
        break;
      } else {
        Serial.println("Available commands: calibrate, info, exit");
      }
    }
    delay(100);
  }
}
