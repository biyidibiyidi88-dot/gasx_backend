/*
 * ESP32 Gas Monitor - Quality Data Version
 * Features: Quality data validation, valve control button, optimized weight transmission
 */

#include <WiFi.h>
#include <HTTPClient.h>
#include <ArduinoJson.h>
#include <WiFiManager.h>
#include <Preferences.h>
#include "HX711.h"
#include <ESP32Servo.h>
#include <Wire.h>
#include <LiquidCrystal_I2C.h>

LiquidCrystal_I2C lcd(0x27, 16, 2);

// Hardware Constants - Same as gas_monitor_fixed.ino except buzzer pin
const int MQ_SENSOR_PIN = 34;
const int LOADCELL_DOUT_PIN = 2;
const int LOADCELL_SCK_PIN = 15;
const int SERVO_PIN = 4;
const int LED_NORMAL_PIN = 5;
const int LED_WARNING_PIN = 18;
const int LED_CRITICAL_PIN = 19;
const int BUZZER_PIN = 233;  // Changed from 21 to avoid LCD conflict
const int CONFIG_BUTTON_PIN = 0;
const int ALARM_SILENCE_PIN = 26;
const int VALVE_CONTROL_BUTTON_PIN = 25;  // New button for valve control

// Configuration - Same authentication
const char* API_TOKEN = "972e4539789c26414553c450b2994111b7ebccae";
const int SENSOR_ID = 13;
const char* DEVICE_ID = "ESP32_GAS_001";
const char* LOCATION = "Home Gas Monitor";
const char* api_base_url = "https://gas-monitor-sfk3.onrender.com/api";

// Thresholds
const int GAS_NORMAL_THRESHOLD = 200;
const int GAS_WARNING_THRESHOLD = 400;
const int GAS_CRITICAL_THRESHOLD = 600;
const float TANK_EMPTY_WEIGHT = 6.0;
const float TANK_FULL_WEIGHT = 26.0;
const float MIN_WEIGHT_CHANGE = 0.2;  // Changed to 0.2kg as requested

// Timing
const unsigned long READING_INTERVAL = 30000;
const unsigned long WEIGHT_READING_INTERVAL = 10000;
const unsigned long ALERT_COOLDOWN = 10000;
const unsigned long BUTTON_DEBOUNCE = 500;
const unsigned long WIFI_CHECK_INTERVAL = 10000;

// Servo positions
const int SERVO_OPEN_POSITION = 0;
const int SERVO_CLOSED_POSITION = 180;
const int SERVO_DELAY_MS = 1000;

// Gas severity levels
enum GasSeverity {
  GAS_LOW = 0,
  GAS_MEDIUM = 1,
  GAS_HIGH = 2,
  GAS_CRITICAL = 3
};

// Global Objects
HX711 scale;
Preferences preferences;
WiFiManager wifiManager;
Servo valveServo;
HTTPClient http;

// State Variables
struct {
  unsigned long lastReadingTime = 0;
  unsigned long lastWeightReadingTime = 0;
  unsigned long lastAlertTime = 0;
  unsigned long lastAlarmSilencePress = 0;
  unsigned long lastValveButtonPress = 0;
  unsigned long lastWiFiCheck = 0;
  bool wifiConnected = false;
  bool scaleCalibrated = false;
  bool valveClosed = false;
  bool alarmActive = false;
  float currentWeight = 0.0;
  float lastSentWeight = 0.0;  // Track last weight sent to backend
  float lastStableWeight = 0.0;
  float calibration_factor = 1.0;
  int currentGasLevel = 0;
  GasSeverity currentSeverity = GAS_LOW;
} state;

void setup() {
  Serial.begin(115200);
  Serial.println("\n=== ESP32 Gas Monitor - Quality Version ===");

  preferences.begin("gas_monitor", false);

  // Initialize LCD
  Wire.begin(21, 22); // SDA=21, SCL=22 for ESP32
  lcd.init();
  lcd.backlight();
  lcd.setCursor(0, 0);
  lcd.print("Gas Monitor");
  lcd.setCursor(0, 1);
  lcd.print("Quality Mode");

  // Initialize hardware
  pinMode(LED_NORMAL_PIN, OUTPUT);
  pinMode(LED_WARNING_PIN, OUTPUT);
  pinMode(LED_CRITICAL_PIN, OUTPUT);
  pinMode(BUZZER_PIN, OUTPUT);
  pinMode(CONFIG_BUTTON_PIN, INPUT_PULLUP);
  pinMode(ALARM_SILENCE_PIN, INPUT_PULLUP);
  pinMode(VALVE_CONTROL_BUTTON_PIN, INPUT_PULLUP);  // New valve control button

  valveServo.attach(SERVO_PIN);
  openValve();

  testLEDs();
  initializeLoadCell();
  connectToWiFi();

  Serial.println("Warming up sensors...");
  setStatusLED("warming");
  delay(2000);

  Serial.println("\n✅ System Ready - Quality Mode Active");
  printDeviceInfo();
  setStatusLED("normal");
  
  // Update LCD to show ready status
  lcd.clear();
  lcd.setCursor(0, 0);
  lcd.print("Gas Monitor");
  lcd.setCursor(0, 1);
  lcd.print("Ready - Quality");
}

void loop() {
  handleWiFiConnection();
  handleButtons();
  monitorGas();
  monitorWeight();
  sendRegularReadings();
  handleSerialCommands();
  delay(10);
}

// Core Functions
void handleWiFiConnection() {
  if (millis() - state.lastWiFiCheck >= WIFI_CHECK_INTERVAL) {
    state.lastWiFiCheck = millis();
    if (WiFi.status() != WL_CONNECTED) {
      if (state.wifiConnected) {
        Serial.println("⚠️  WiFi disconnected");
        setStatusLED("warning");
        state.wifiConnected = false;
      }
    } else {
      if (!state.wifiConnected) {
        Serial.println("✅ WiFi reconnected");
        setStatusLED("normal");
        state.wifiConnected = true;
      }
    }
  }
}

void handleButtons() {
  // Alarm silence button
  if (digitalRead(ALARM_SILENCE_PIN) == LOW && 
      millis() - state.lastAlarmSilencePress > BUTTON_DEBOUNCE) {
    state.lastAlarmSilencePress = millis();
    silenceAlarm();
    Serial.println("🔇 Alarm silenced by button");
  }

  // Valve control button - NEW FEATURE
  if (digitalRead(VALVE_CONTROL_BUTTON_PIN) == LOW && 
      millis() - state.lastValveButtonPress > BUTTON_DEBOUNCE) {
    state.lastValveButtonPress = millis();
    toggleValve();
    Serial.printf("🔧 Valve toggled: %s\n", state.valveClosed ? "CLOSED" : "OPEN");
    
    // Update LCD to show valve status
    lcd.clear();
    lcd.setCursor(0, 0);
    lcd.print("Valve Status:");
    lcd.setCursor(0, 1);
    lcd.print(state.valveClosed ? "CLOSED" : "OPEN");
    delay(2000);
    updateLCDDisplay();
  }

  // Config button
  if (digitalRead(CONFIG_BUTTON_PIN) == LOW) {
    delay(50); // Debounce
    if (digitalRead(CONFIG_BUTTON_PIN) == LOW) {
      enterConfigurationMode();
    }
  }
}

void monitorGas() {
  int gasLevel = readGasSensor();
  
  // Quality check: Ensure no negative values
  if (gasLevel < 0) {
    gasLevel = 0;
    Serial.println("⚠️  Negative gas reading corrected to 0");
  }
  
  state.currentGasLevel = gasLevel;
  GasSeverity newSeverity = determineGasSeverity(gasLevel);
  
  // Update severity and LED status immediately
  state.currentSeverity = newSeverity;
  updateStatusLED();
  
  // Handle alerts for HIGH and CRITICAL levels (not just on changes)
  if (newSeverity >= GAS_HIGH) {
    handleGasAlert(gasLevel, newSeverity);
  }
}

void monitorWeight() {
  if (millis() - state.lastWeightReadingTime >= WEIGHT_READING_INTERVAL) {
    state.lastWeightReadingTime = millis();
    readWeightSensor();
    
    // Quality check: Only send weight if significant change (0.2kg or more)
    float weightDifference = abs(state.currentWeight - state.lastSentWeight);
    if (weightDifference >= MIN_WEIGHT_CHANGE) {
      Serial.printf("📊 Significant weight change detected: %.2f kg (diff: %.2f kg)\n", 
                    state.currentWeight, weightDifference);
      sendWeightReading();
      state.lastSentWeight = state.currentWeight;
    }
  }
}

void sendRegularReadings() {
  if (millis() - state.lastReadingTime >= READING_INTERVAL) {
    state.lastReadingTime = millis();
    
    if (state.wifiConnected) {
      sendGasReading();
      Serial.printf("📡 Regular reading sent - Gas: %d, Weight: %.2f kg\n", 
                    state.currentGasLevel, state.currentWeight);
    } else {
      Serial.println("⚠️  Skipping reading - WiFi not connected");
    }
  }
}

// Hardware Control Functions
void connectToWiFi() {
  Serial.println("🔗 Connecting to WiFi...");
  setStatusLED("warning");
  
  wifiManager.setConfigPortalTimeout(180);
  
  if (wifiManager.autoConnect("GasMonitor_Setup")) {
    Serial.println("✅ WiFi connected!");
    Serial.printf("IP: %s\n", WiFi.localIP().toString().c_str());
    state.wifiConnected = true;
    setStatusLED("normal");
  } else {
    Serial.println("❌ WiFi connection failed");
    setStatusLED("critical");
    state.wifiConnected = false;
  }
}

void initializeLoadCell() {
  Serial.println("🏗️  Initializing load cell...");
  scale.begin(LOADCELL_DOUT_PIN, LOADCELL_SCK_PIN);
  
  if (scale.is_ready()) {
    loadCalibration();
    Serial.println("✅ Load cell ready");
  } else {
    Serial.println("❌ Load cell initialization failed");
  }
}

void loadCalibration() {
  state.calibration_factor = preferences.getFloat("cal_factor", 0.0);
  state.scaleCalibrated = preferences.getBool("cal_done", false);
  if (state.scaleCalibrated) {
    scale.set_scale(state.calibration_factor);
    Serial.printf("✅ Calibration loaded: %.2f\n", state.calibration_factor);
  } else {
    Serial.println("⚠️  Scale not calibrated - use 'calibrate' command");
  }
}

void saveCalibration() {
  preferences.putFloat("cal_factor", state.calibration_factor);
  preferences.putBool("cal_done", true);
  Serial.println("💾 Calibration saved");
}

// Sensor Functions
int readGasSensor() {
  int rawValue = analogRead(MQ_SENSOR_PIN);
  
  // Quality validation: Ensure reading is within valid range
  if (rawValue < 0) rawValue = 0;
  if (rawValue > 4095) rawValue = 4095;
  
  // Convert to gas level (0-1000 scale)
  int gasLevel = map(rawValue, 0, 4095, 0, 1000);
  
  // Additional quality check
  if (gasLevel < 0) gasLevel = 0;
  
  return gasLevel;
}

GasSeverity determineGasSeverity(int gasLevel) {
  if (gasLevel >= GAS_CRITICAL_THRESHOLD) return GAS_CRITICAL;
  if (gasLevel >= GAS_WARNING_THRESHOLD) return GAS_HIGH;
  if (gasLevel >= GAS_NORMAL_THRESHOLD) return GAS_MEDIUM;
  return GAS_LOW;
}

void readWeightSensor() {
  if (!state.scaleCalibrated) {
    state.currentWeight = 0.0;
    return;
  }
  
  if (scale.is_ready()) {
    float weight = scale.get_units(3);
    
    // Quality validation: Ensure no negative weights
    if (weight < 0) {
      weight = 0.0;
      Serial.println("⚠️  Negative weight reading corrected to 0");
    }
    
    // Reasonable upper limit check
    if (weight > 100.0) {
      Serial.printf("⚠️  Unusually high weight reading: %.2f kg - using previous value\n", weight);
      return;
    }
    
    state.currentWeight = weight;
    
    // Update stable weight for trend analysis
    if (abs(weight - state.lastStableWeight) < 0.05) {
      state.lastStableWeight = weight;
    }
  }
}

// API Communication Functions
void sendGasReading() {
  if (!state.wifiConnected) return;
  
  http.begin(String(api_base_url) + "/gas-readings/create/");
  http.addHeader("Content-Type", "application/json");
  http.addHeader("Authorization", "Token " + String(API_TOKEN));
  
  // Use actual weight if available, otherwise estimate from gas sensor
  float remainingGas;
  if (state.scaleCalibrated && state.currentWeight > 0) {
    // Use actual weight measurement (subtract empty tank weight)
    remainingGas = max(0.0f, state.currentWeight - TANK_EMPTY_WEIGHT);
  } else {
    // Estimate from gas sensor reading (0-1000 -> 0-20kg)
    remainingGas = map(state.currentGasLevel, 0, 1000, 0, 20);
    remainingGas = max(0.0f, remainingGas);
  }
  
  // Backend expects exact field names from GasReadingSerializer
  StaticJsonDocument<1024> doc;
  doc["sensor"] = SENSOR_ID;  // Backend expects 'sensor' field with sensor ID
  doc["remaining_gas"] = remainingGas;  // Actual gas weight in kg
  
  String payload;
  serializeJson(doc, payload);
  
  int httpResponseCode = http.POST(payload);
  
  if (httpResponseCode == 201) {
    Serial.printf("✅ Gas reading sent: %.2f kg\n", remainingGas);
  } else {
    Serial.printf("❌ Gas reading failed: %d\n", httpResponseCode);
    if (httpResponseCode > 0) {
      Serial.println("Response: " + http.getString());
    }
  }
  
  http.end();
}

void sendWeightReading() {
  if (!state.wifiConnected || !state.scaleCalibrated) return;
  
  // Only send if weight is valid and positive
  if (state.currentWeight < 0) {
    Serial.println("⚠️  Skipping weight transmission - invalid reading");
    return;
  }
  
  http.begin(String(api_base_url) + "/gas-readings/create/");
  http.addHeader("Content-Type", "application/json");
  http.addHeader("Authorization", "Token " + String(API_TOKEN));
  
  // Calculate gas weight (subtract empty tank weight)
  float gasWeight = max(0.0f, state.currentWeight - TANK_EMPTY_WEIGHT);
  float gasWeightRounded = round(gasWeight * 100.0) / 100.0;
  
  StaticJsonDocument<1024> doc;
  doc["sensor"] = SENSOR_ID;  // Changed from sensor_id to sensor
  doc["remaining_gas"] = gasWeightRounded;  // Properly rounded
  
  String payload;
  serializeJson(doc, payload);
  
  int httpResponseCode = http.POST(payload);
  
  if (httpResponseCode == 201) {
    Serial.printf("✅ Weight reading sent: %.2f kg\n", gasWeightRounded);
  } else {
    Serial.printf("❌ Weight reading failed: %d\n", httpResponseCode);
    if (httpResponseCode > 0) {
      Serial.println("Response: " + http.getString());
    }
  }
  
  http.end();
}

void handleGasAlert(int gasLevel, GasSeverity severity) {
  // Allow immediate valve closure and alarm activation, but limit API calls
  bool shouldSendAlert = (millis() - state.lastAlertTime >= ALERT_COOLDOWN);
  
  String severityStr;
  switch (severity) {
    case GAS_CRITICAL: severityStr = "CRITICAL"; break;
    case GAS_HIGH: severityStr = "HIGH"; break;
    case GAS_MEDIUM: severityStr = "MEDIUM"; break;
    default: severityStr = "LOW"; break;
  }
  
  Serial.printf("🚨 Gas Alert: %s (Level: %d)\n", severityStr.c_str(), gasLevel);
  
  if (severity >= GAS_HIGH) {
    // Always activate alarm and close valve immediately for safety
    activateAlarm(severity);
    
    // Close valve on HIGH or CRITICAL levels for immediate safety
    if (!state.valveClosed) {
      closeValve();
      Serial.printf("🔒 Valve automatically closed due to %s gas level\n", severityStr.c_str());
    }
    
    // Only send API alert if cooldown period has passed
    if (shouldSendAlert) {
      sendGasLeakAlert(gasLevel, severityStr);
      state.lastAlertTime = millis();
    }
  }
  
  updateLCDDisplay();
}

void sendGasLeakAlert(int gasLevel, String severity) {
  if (!state.wifiConnected) return;
  
  http.begin(String(api_base_url) + "/alerts/gas-leak/");
  http.addHeader("Content-Type", "application/json");
  http.addHeader("Authorization", "Token " + String(API_TOKEN));
  
  StaticJsonDocument<1024> doc;
  doc["sensor_id"] = SENSOR_ID;  // This endpoint uses sensor_id (different from gas-readings)
  doc["severity_level"] = severity;
  doc["gas_concentration"] = max(0, gasLevel);  // Ensure non-negative
  doc["location_details"] = LOCATION;
  doc["alert_message"] = "Gas leak detected - Level: " + String(gasLevel);
  
  String payload;
  serializeJson(doc, payload);
  
  int httpResponseCode = http.POST(payload);
  
  if (httpResponseCode == 201) {
    Serial.println("✅ Gas leak alert sent");
  } else {
    Serial.printf("❌ Gas leak alert failed: %d\n", httpResponseCode);
    if (httpResponseCode > 0) {
      Serial.println("Response: " + http.getString());
    }
  }
  
  http.end();
}

// Control Functions
void toggleValve() {
  if (state.valveClosed) {
    openValve();
  } else {
    closeValve();
  }
}

void openValve() {
  valveServo.write(SERVO_OPEN_POSITION);
  delay(SERVO_DELAY_MS);
  state.valveClosed = false;
  Serial.println("🔓 Valve opened");
}

void closeValve() {
  valveServo.write(SERVO_CLOSED_POSITION);
  delay(SERVO_DELAY_MS);
  state.valveClosed = true;
  Serial.println("🔒 Valve closed");
}

void activateAlarm(GasSeverity severity) {
  state.alarmActive = true;
  
  // Different alarm patterns based on severity
  switch (severity) {
    case GAS_CRITICAL:
      // Continuous alarm
      digitalWrite(BUZZER_PIN, HIGH);
      break;
    case GAS_HIGH:
      // Fast beeping
      for (int i = 0; i < 10; i++) {
        digitalWrite(BUZZER_PIN, HIGH);
        delay(100);
        digitalWrite(BUZZER_PIN, LOW);
        delay(100);
      }
      break;
    case GAS_MEDIUM:
      // Slow beeping
      for (int i = 0; i < 5; i++) {
        digitalWrite(BUZZER_PIN, HIGH);
        delay(300);
        digitalWrite(BUZZER_PIN, LOW);
        delay(300);
      }
      break;
    default:
      break;
  }
}

void silenceAlarm() {
  digitalWrite(BUZZER_PIN, LOW);
  state.alarmActive = false;
  Serial.println("🔇 Alarm silenced");
}

// LED Control Functions
void setStatusLED(String status) {
  // Turn off all LEDs first
  digitalWrite(LED_NORMAL_PIN, LOW);
  digitalWrite(LED_WARNING_PIN, LOW);
  digitalWrite(LED_CRITICAL_PIN, LOW);
  
  if (status == "normal") {
    digitalWrite(LED_NORMAL_PIN, HIGH);
  } else if (status == "warning" || status == "warming") {
    digitalWrite(LED_WARNING_PIN, HIGH);
  } else if (status == "critical") {
    digitalWrite(LED_CRITICAL_PIN, HIGH);
  }
}

void updateStatusLED() {
  switch (state.currentSeverity) {
    case GAS_CRITICAL:
      setStatusLED("critical");
      break;
    case GAS_HIGH:
    case GAS_MEDIUM:
      setStatusLED("warning");
      break;
    default:
      if (state.wifiConnected) {
        setStatusLED("normal");
      } else {
        setStatusLED("warning");
      }
      break;
  }
}

void testLEDs() {
  Serial.println("🔍 Testing LEDs...");
  digitalWrite(LED_NORMAL_PIN, HIGH);
  delay(500);
  digitalWrite(LED_NORMAL_PIN, LOW);
  digitalWrite(LED_WARNING_PIN, HIGH);
  delay(500);
  digitalWrite(LED_WARNING_PIN, LOW);
  digitalWrite(LED_CRITICAL_PIN, HIGH);
  delay(500);
  digitalWrite(LED_CRITICAL_PIN, LOW);
  Serial.println("✅ LED test complete");
}

// LCD Functions
void updateLCDDisplay() {
  lcd.clear();
  lcd.setCursor(0, 0);
  
  if (state.currentSeverity >= GAS_HIGH) {
    lcd.print("GAS ALERT!");
    lcd.setCursor(0, 1);
    lcd.printf("Level: %d", state.currentGasLevel);
  } else {
    // Calculate gas percentage
    float gasPercentage = 0.0;
    if (state.scaleCalibrated && state.currentWeight > 0) {
      // Calculate based on actual weight
      float gasWeight = max(0.0f, state.currentWeight - TANK_EMPTY_WEIGHT);
      float tankCapacity = TANK_FULL_WEIGHT - TANK_EMPTY_WEIGHT;
      gasPercentage = (gasWeight / tankCapacity) * 100.0;
      gasPercentage = constrain(gasPercentage, 0.0, 100.0);
    } else {
      // Estimate from gas sensor reading
      gasPercentage = map(state.currentGasLevel, 0, 1000, 0, 100);
      gasPercentage = constrain(gasPercentage, 0.0, 100.0);
    }
    
    // Display gas percentage and status
    lcd.printf("Gas: %.1f%%", gasPercentage);
    lcd.setCursor(0, 1);
    
    if (state.scaleCalibrated) {
      lcd.printf("%.1fkg %s", state.currentWeight, state.valveClosed ? "CLOSED" : "OPEN");
    } else {
      lcd.printf("Est %s", state.valveClosed ? "CLOSED" : "OPEN");
    }
  }
}

// Serial Command Handling
void handleSerialCommands() {
  if (Serial.available()) {
    String command = Serial.readStringUntil('\n');
    command.trim();
    command.toLowerCase();
    
    if (command == "calibrate") startWeightCalibration();
    else if (command == "tare") tareScale();
    else if (command == "weight") printWeight();
    else if (command == "reset_cal") resetCalibration();
    else if (command == "valve_open") openValve();
    else if (command == "valve_close") closeValve();
    else if (command == "valve_toggle") toggleValve();
    else if (command == "alarm_off") silenceAlarm();
    else if (command == "info") printDeviceInfo();
    else if (command == "test_leds") testLEDs();
    else if (command == "help") printHelp();
  }
}

void startWeightCalibration() {
  if (!scale.is_ready()) {
    Serial.println("❌ Scale not ready");
    return;
  }
  
  Serial.println("\n=== Weight Calibration ===");
  Serial.println("1. Remove all weight and press ENTER");
  waitForSerial();
  
  scale.tare();
  Serial.println("✅ Scale tared");

  Serial.println("\n2. Enter known weight (kg):");
  float known_weight = readFloatFromSerial();
  Serial.printf("Known weight: %.2f kg\n", known_weight);

  Serial.println("\n3. Place weight and press ENTER");
  waitForSerial();

  Serial.println("🔄 Calibrating...");
  delay(2000);
  long reading = scale.get_value(10);
  state.calibration_factor = reading / known_weight;
  scale.set_scale(state.calibration_factor);

  Serial.printf("✅ Calibration factor: %.2f\n", state.calibration_factor);
  Serial.printf("Current reading: %.2f kg\n", scale.get_units(5));
  Serial.println("Save calibration? (y/n)");

  if (readYesNoFromSerial()) {
    state.scaleCalibrated = true;
    saveCalibration();
    Serial.println("✅ Calibration saved");
  }
}

void tareScale() {
  if (state.scaleCalibrated) {
    scale.tare();
    Serial.println("✅ Scale tared");
  } else {
    Serial.println("❌ Scale not calibrated");
  }
}

void printWeight() {
  if (state.scaleCalibrated) {
    float weight = scale.get_units(3);
    // Quality check before displaying
    if (weight < 0) weight = 0.0;
    Serial.printf("📏 Current weight: %.2f kg\n", weight);
  } else {
    Serial.println("❌ Scale not calibrated");
  }
}

void resetCalibration() {
  preferences.remove("cal_factor");
  preferences.remove("cal_done");
  state.scaleCalibrated = false;
  Serial.println("🔄 Calibration reset");
}

void enterConfigurationMode() {
  Serial.println("\n=== CONFIGURATION MODE ===");
  Serial.println("Commands: calibrate, info, valve_open, valve_close, valve_toggle, exit");
  
  while (true) {
    if (Serial.available()) {
      String command = Serial.readStringUntil('\n');
      command.trim();
      
      if (command == "exit") break;
      else if (command == "calibrate") startWeightCalibration();
      else if (command == "info") printDeviceInfo();
      else if (command == "valve_open") openValve();
      else if (command == "valve_close") closeValve();
      else if (command == "valve_toggle") toggleValve();
      else Serial.println("❌ Unknown command");
    }
    delay(100);
  }
  
  Serial.println("✅ Exiting configuration mode");
}

// Utility Functions
void waitForSerial() {
  while (!Serial.available());
  while (Serial.available()) Serial.read();
}

float readFloatFromSerial() {
  float value = 0;
  while (value <= 0) {
    if (Serial.available()) {
      value = Serial.parseFloat();
    }
    delay(100);
  }
  while (Serial.available()) Serial.read();
  return value;
}

bool readYesNoFromSerial() {
  while (!Serial.available());
  char response = Serial.read();
  while (Serial.available()) Serial.read();
  return (response == 'y' || response == 'Y');
}

void printDeviceInfo() {
  Serial.println("\n=== DEVICE INFO - QUALITY VERSION ===");
  Serial.printf("Device ID: %s\n", DEVICE_ID);
  Serial.printf("Location: %s\n", LOCATION);
  Serial.printf("Sensor ID: %d\n", SENSOR_ID);
  Serial.printf("WiFi: %s\n", state.wifiConnected ? "Connected" : "Disconnected");
  Serial.printf("Scale: %s\n", state.scaleCalibrated ? "Calibrated" : "Not calibrated");
  Serial.printf("Valve: %s\n", state.valveClosed ? "Closed" : "Open");
  Serial.printf("Alarm: %s\n", state.alarmActive ? "Active" : "Inactive");
  Serial.printf("Current Weight: %.2f kg\n", state.currentWeight);
  Serial.printf("Last Sent Weight: %.2f kg\n", state.lastSentWeight);
  Serial.printf("Gas Level: %d\n", state.currentGasLevel);
  Serial.printf("Min Weight Change: %.1f kg\n", MIN_WEIGHT_CHANGE);
  Serial.println("=====================================");
}

void printHelp() {
  Serial.println("\n=== AVAILABLE COMMANDS ===");
  Serial.println("calibrate    - Calibrate weight scale");
  Serial.println("tare         - Zero the scale");
  Serial.println("weight       - Show current weight");
  Serial.println("reset_cal    - Reset calibration");
  Serial.println("valve_open   - Open gas valve");
  Serial.println("valve_close  - Close gas valve");
  Serial.println("valve_toggle - Toggle valve state");
  Serial.println("alarm_off    - Silence alarm");
  Serial.println("info         - Show device information");
  Serial.println("test_leds    - Test LED functionality");
  Serial.println("help         - Show this help menu");
  Serial.println("===========================");
}
