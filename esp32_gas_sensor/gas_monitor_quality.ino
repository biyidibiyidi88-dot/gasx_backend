/*
 * ESP32 Gas Monitor - Quality Data Version
 * Features: Quality data validation, valve control button, remote valve control,
 *           non-blocking screen refresh, raw weight payload transmission
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
#include <math.h>

LiquidCrystal_I2C lcd(0x27, 16, 2);

// Hardware Constants - Same as gas_monitor_fixed.ino except buzzer pin
const int MQ_SENSOR_PIN = 34;
const int LOADCELL_DOUT_PIN = 2;
const int LOADCELL_SCK_PIN = 15;
const int SERVO_PIN = 4;
const int LED_NORMAL_PIN = 5;
const int LED_WARNING_PIN = 18;
const int LED_CRITICAL_PIN = 19;
const int BUZZER_PIN = 23;  // Fixed pin 23
// LEDC (PWM) config for buzzer
const int BUZZER_LEDC_CHANNEL = 0;   // use channel 0
const int BUZZER_LEDC_FREQ = 2000;   // 2 kHz tone
const int BUZZER_LEDC_RES = 8;       // 8-bit resolution
const int CONFIG_BUTTON_PIN = 0;
const int ALARM_SILENCE_PIN = 26;
const int VALVE_CONTROL_BUTTON_PIN = 25;  // New button for valve control

// Configuration
const int SENSOR_ID = 13;
const char* DEVICE_ID = "ESP32_GAS_001";
const char* LOCATION = "Home Gas Monitor";
const char* api_base_url = "https://web-production-c23ce.up.railway.app/api";

// Thresholds
const int GAS_NORMAL_THRESHOLD = 200;
const int GAS_WARNING_THRESHOLD = 400;
const int GAS_CRITICAL_THRESHOLD = 600;

// Timing
const unsigned long READING_INTERVAL = 10000;
const unsigned long WEIGHT_READING_INTERVAL = 10000;
const unsigned long DEVICE_COMMAND_POLL_INTERVAL = 3000;
const unsigned long ALERT_COOLDOWN = 10000;
const unsigned long GAS_SAFE_RESET_MS = 10000;
const unsigned long BUTTON_DEBOUNCE = 500;
const unsigned long WIFI_CHECK_INTERVAL = 10000;
const unsigned long LCD_REFRESH_INTERVAL = 500; // 500ms non-blocking refresh rate

// Continuous-rotation servo: 60 RPM is about 1000 ms per turn; calibrate for this unit.
const int SERVO_OPEN_SPEED_US = 1000;
const int SERVO_CLOSE_SPEED_US = 2000;
const int SERVO_STOP_US = 1500;
const unsigned long SERVO_FULL_TURN_MS = 1000;

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
String deviceApiToken;

// State Variables
struct {
  unsigned long lastReadingTime = 0;
  unsigned long lastWeightReadingTime = 0;
  unsigned long lastDeviceCommandPollTime = 0;
  unsigned long lastAlertTime = 0;
  unsigned long lastAlarmSilencePress = 0;
  unsigned long lastValveButtonPress = 0;
  unsigned long lastWiFiCheck = 0;
  unsigned long lastLCDUpdate = 0;
  bool wifiConnected = false;
  bool scaleCalibrated = false;
  bool scaleReadingValid = false;
  bool valveClosed = false;
  bool gasSafetyLockout = false;
  bool alarmArmed = true;
  bool alarmActive = false;
  bool buzzerOutputOn = false;
  unsigned long lastAlarmToggle = 0;
  unsigned long safeGasSince = 0;
  float currentWeight = 0.0;
  float lastStableWeight = 0.0;
  float calibration_factor = 1.0;
  int currentGasLevel = 0;
  GasSeverity currentSeverity = GAS_LOW;
} state;

void syncValveStateToBackend();

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
  // Configure LEDC PWM for buzzer
  ledcSetup(BUZZER_LEDC_CHANNEL, BUZZER_LEDC_FREQ, BUZZER_LEDC_RES);
  ledcAttachPin(BUZZER_PIN, BUZZER_LEDC_CHANNEL);
  pinMode(CONFIG_BUTTON_PIN, INPUT_PULLUP);
  pinMode(ALARM_SILENCE_PIN, INPUT_PULLUP);
  pinMode(VALVE_CONTROL_BUTTON_PIN, INPUT_PULLUP);  // New valve control button

  // Restore saved valve state from flash storage (do NOT move motor on boot!)
  state.valveClosed = preferences.getBool("valve_closed", false);
  state.gasSafetyLockout = preferences.getBool("gas_lockout", false);
  deviceApiToken = preferences.getString("api_token", "");
  Serial.printf("ℹ️ Valve boot state loaded: %s\n", state.valveClosed ? "CLOSED" : "OPEN");
  Serial.println(deviceApiToken.length() > 0
                     ? "✅ API token loaded from device storage"
                     : "⚠️ API token missing; provision it once with: set_token <token>");

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
  updateAlarmOutput();
  monitorWeight();
  handleLCDRefresh();
  if (millis() - state.lastDeviceCommandPollTime >= DEVICE_COMMAND_POLL_INTERVAL) {
    state.lastDeviceCommandPollTime = millis();
    pollDeviceCommands();
  }
  sendRegularReadings();
  handleSerialCommands();
  delay(10);
}

void handleLCDRefresh() {
  if (millis() - state.lastLCDUpdate >= LCD_REFRESH_INTERVAL) {
    state.lastLCDUpdate = millis();
    updateLCDDisplay();
  }
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
    bool wasClosed = state.valveClosed;
    toggleValve();
    Serial.printf("🔧 Valve toggled: %s\n", state.valveClosed ? "CLOSED" : "OPEN");
    if (state.valveClosed != wasClosed) {
      syncValveStateToBackend();
    }
    
    // Update LCD to show valve status
    lcd.clear();
    lcd.setCursor(0, 0);
    lcd.print("Valve Status:");
    lcd.setCursor(0, 1);
    lcd.print(state.valveClosed ? "CLOSED" : "OPEN");
    delay(800);
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

void syncValveStateToBackend() {
  if (!state.wifiConnected || deviceApiToken.length() == 0) return;

  http.begin(String(api_base_url) + "/sensors/" + String(SENSOR_ID) + "/control-valve/");
  http.setFollowRedirects(HTTPC_STRICT_FOLLOW_REDIRECTS);
  http.addHeader("Content-Type", "application/json");
  http.addHeader("Authorization", "Token " + deviceApiToken);

  StaticJsonDocument<128> doc;
  doc["command"] = state.valveClosed ? "CLOSE" : "OPEN";
  String payload;
  serializeJson(doc, payload);

  int code = http.POST(payload);
  if (code == 200) {
    Serial.println("☁️ Local valve state synced to backend");
  } else {
    Serial.printf("⚠️ Could not sync local valve state: HTTP %d\n", code);
    if (code > 0) Serial.println(http.getString());
  }
  http.end();
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
  
  // Handle alerts for MEDIUM, HIGH and CRITICAL levels immediately upon gas detection
  if (newSeverity >= GAS_MEDIUM) {
    state.safeGasSince = 0;
    handleGasAlert(gasLevel, newSeverity);
  } else if (state.gasSafetyLockout) {
    if (state.alarmActive) stopAlarmOutput();
    // Require a continuous safe reading before allowing an intentional reopen.
    if (state.safeGasSince == 0) state.safeGasSince = millis();
    if (millis() - state.safeGasSince >= GAS_SAFE_RESET_MS) {
      state.gasSafetyLockout = false;
      preferences.putBool("gas_lockout", false);
      state.safeGasSince = 0;
      Serial.println("✅ Gas level stayed safe; valve can be opened manually or remotely");
    }
  } else {
    if (state.alarmActive) stopAlarmOutput();
    state.safeGasSince = 0;
  }
}

void monitorWeight() {
  if (millis() - state.lastWeightReadingTime >= WEIGHT_READING_INTERVAL) {
    state.lastWeightReadingTime = millis();
    readWeightSensor();
  }
}

void sendRegularReadings() {
  if (millis() - state.lastReadingTime >= READING_INTERVAL) {
    state.lastReadingTime = millis();
    
    if (!state.wifiConnected) {
      Serial.println("⚠️  Skipping weight upload - WiFi not connected");
    } else if (state.scaleCalibrated && state.scaleReadingValid) {
      if (sendWeightReading()) {
        Serial.printf("📡 Backend accepted gross bottle weight: %.2f kg\n", state.currentWeight);
      } else {
        Serial.println("⚠️  Backend did not accept the weight; it will retry at the next interval");
      }
    } else {
      Serial.println("⚠️  Skipping weight upload: scale is uncalibrated or reading is invalid");
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
  const float storedFactor = preferences.getFloat("cal_factor", 0.0f);
  const bool calibrationMarkedDone = preferences.getBool("cal_done", false);
  if (calibrationMarkedDone && isfinite(storedFactor) && fabsf(storedFactor) > 0.000001f) {
    state.calibration_factor = storedFactor;
    state.scaleCalibrated = true;
    scale.set_scale(state.calibration_factor);
    Serial.printf("✅ Calibration loaded: %.2f\n", state.calibration_factor);
  } else {
    state.scaleCalibrated = false;
    preferences.putBool("cal_done", false);
    Serial.println("⚠️  Scale not calibrated - use 'calibrate' command");
  }
}

bool saveCalibration(float calibrationFactor) {
  if (!isfinite(calibrationFactor) || fabsf(calibrationFactor) <= 0.000001f) {
    Serial.println("❌ Calibration not saved: invalid calibration factor");
    return false;
  }

  const size_t factorBytes = preferences.putFloat("cal_factor", calibrationFactor);
  const size_t doneBytes = preferences.putBool("cal_done", true);
  const float savedFactor = preferences.getFloat("cal_factor", 0.0f);
  const bool savedDone = preferences.getBool("cal_done", false);
  const bool saved = factorBytes == sizeof(float) && doneBytes > 0 && savedDone &&
                     isfinite(savedFactor) && fabsf(savedFactor - calibrationFactor) < 0.000001f;
  if (saved) {
    Serial.println("💾 Calibration saved to ESP32 flash and verified");
  } else {
    Serial.println("❌ Calibration could not be verified in ESP32 flash");
  }
  return saved;
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
  state.scaleReadingValid = false;
  if (!state.scaleCalibrated) {
    state.currentWeight = 0.0;
    return;
  }
  
  if (scale.is_ready()) {
    float weight = scale.get_units(3);
    
    // Quality validation: Ensure no negative weights
    if (weight <= 0) {
      Serial.println("⚠️  Non-positive gross weight; upload skipped");
      return;
    }
    
    // Reasonable upper limit check
    if (weight > 100.0) {
      Serial.printf("⚠️  Unusually high weight reading: %.2f kg - using previous value\n", weight);
      return;
    }
    
    state.currentWeight = weight;
    state.scaleReadingValid = true;
    
    // Update stable weight for trend analysis
    if (abs(weight - state.lastStableWeight) < 0.05) {
      state.lastStableWeight = weight;
    }
  }
}

// Device Command Processing Function
void processDeviceCommands(JsonObject doc) {
  if (doc.containsKey("valve_command")) {
    String valveCmd = doc["valve_command"].as<String>();
    valveCmd.toUpperCase();
    if (valveCmd == "CLOSE") {
      if (!state.valveClosed) closeValve();
      Serial.println("🔒 Remote command: Valve CLOSE acknowledged");
    } else if (valveCmd == "OPEN" && state.valveClosed) {
      if (state.currentSeverity >= GAS_MEDIUM || state.gasSafetyLockout) {
        Serial.println("⛔ Valve OPEN rejected by gas safety lockout");
      } else {
        openValve();
        Serial.println("🔓 Remote command: Valve OPENED");
      }
    }
  }

  if (doc.containsKey("alarm_command")) {
    String alarmCmd = doc["alarm_command"].as<String>();
    alarmCmd.toUpperCase();
    if (alarmCmd == "SILENCE") {
      state.alarmArmed = false;
      silenceAlarm();
      Serial.println("🔇 Remote command: Alarm SILENCED");
    } else if (alarmCmd == "ARM") {
      state.alarmArmed = true;
      if (state.currentSeverity >= GAS_MEDIUM && !state.alarmActive) {
        activateAlarm(state.currentSeverity);
      }
      Serial.println("🔊 Remote command: Alarm ARMED");
    }
  }
}

void pollDeviceCommands() {
  if (!state.wifiConnected || deviceApiToken.length() == 0) return;

  http.begin(String(api_base_url) + "/sensors/" + String(SENSOR_ID) +
             "/device-command/?current_valve=" + (state.valveClosed ? "CLOSE" : "OPEN"));
  http.setFollowRedirects(HTTPC_STRICT_FOLLOW_REDIRECTS);
  http.addHeader("Authorization", "Token " + deviceApiToken);

  int code = http.GET();
  if (code == 200) {
    String responseStr = http.getString();
    StaticJsonDocument<512> resDoc;
    if (!DeserializationError(deserializeJson(resDoc, responseStr))) {
      processDeviceCommands(resDoc.as<JsonObject>());
    }
  }
  http.end();
}

// Send gross bottle weight only; the backend subtracts the configured tare.
bool sendWeightReading() {
  if (!state.wifiConnected || deviceApiToken.length() == 0 ||
      !state.scaleCalibrated || !state.scaleReadingValid) {
    Serial.println("⚠️  Skipping weight transmission - no calibrated valid weight");
    return false;
  }
  
  http.begin(String(api_base_url) + "/gas-readings/create/");
  http.setFollowRedirects(HTTPC_STRICT_FOLLOW_REDIRECTS);
  http.addHeader("Content-Type", "application/json");
  http.addHeader("Authorization", "Token " + deviceApiToken);
  
  float rawRounded = roundf(state.currentWeight * 100.0f) / 100.0f;
  
  StaticJsonDocument<512> doc;
  doc["sensor"] = SENSOR_ID;
  doc["raw_weight"] = rawRounded;
  
  String payload;
  serializeJson(doc, payload);
  
  int httpResponseCode = http.POST(payload);
  
  if (httpResponseCode == 201 || httpResponseCode == 200) {
    String responseStr = http.getString();
    Serial.printf("✅ Raw weight reading sent: %.2f kg\n", rawRounded);
    StaticJsonDocument<512> resDoc;
    if (!DeserializationError(deserializeJson(resDoc, responseStr))) {
      processDeviceCommands(resDoc.as<JsonObject>());
    }
    http.end();
    return true;
  } else {
    Serial.printf("❌ Weight reading failed: %d\n", httpResponseCode);
    if (httpResponseCode > 0) {
      Serial.println("Response: " + http.getString());
    }
  }
  
  http.end();
  return false;
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
  
  if (severity >= GAS_MEDIUM) {
    // Close the valve and start the alarm immediately after gas detection.
    if (!state.gasSafetyLockout) {
      state.gasSafetyLockout = true;
      preferences.putBool("gas_lockout", true);
    }
    if (!state.valveClosed) {
      closeValve();
      Serial.printf("🔒 Valve automatically closed due to %s gas level\n", severityStr.c_str());
    }
    if (state.alarmArmed && !state.alarmActive) {
      activateAlarm(severity);
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
  if (!state.wifiConnected || deviceApiToken.length() == 0) return;
  
  http.begin(String(api_base_url) + "/alerts/gas-leak/");
  http.setFollowRedirects(HTTPC_STRICT_FOLLOW_REDIRECTS);
  http.addHeader("Content-Type", "application/json");
  http.addHeader("Authorization", "Token " + deviceApiToken);
  
  StaticJsonDocument<1024> doc;
  doc["sensor_id"] = SENSOR_ID;  // This endpoint uses sensor_id (different from gas-readings)
  doc["severity_level"] = severity;
  doc["location_details"] = LOCATION;
  doc["alert_message"] = "Gas threshold detected - normalized sensor level: " + String(gasLevel) + "/1000";
  
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
  if (state.currentSeverity >= GAS_MEDIUM || state.gasSafetyLockout) {
    Serial.println("⛔ Valve OPEN blocked by gas safety lockout");
    return;
  }
  Serial.println("🔄 Actuating servo to OPEN...");
  valveServo.attach(SERVO_PIN);
  valveServo.writeMicroseconds(SERVO_OPEN_SPEED_US);
  delay(SERVO_FULL_TURN_MS);
  valveServo.writeMicroseconds(SERVO_STOP_US);
  delay(100);
  valveServo.detach();
  state.valveClosed = false;
  preferences.putBool("valve_closed", false);
  Serial.println("🔓 Valve opened & servo detached");
}

void closeValve() {
  Serial.println("🔄 Actuating servo to CLOSE...");
  valveServo.attach(SERVO_PIN);
  valveServo.writeMicroseconds(SERVO_CLOSE_SPEED_US);
  delay(SERVO_FULL_TURN_MS);
  valveServo.writeMicroseconds(SERVO_STOP_US);
  delay(100);
  valveServo.detach();
  state.valveClosed = true;
  preferences.putBool("valve_closed", true);
  Serial.println("🔒 Valve closed & servo detached");
}

// Buzzer helpers (LEDC PWM)
void buzzerOn() {
  ledcWriteTone(BUZZER_LEDC_CHANNEL, BUZZER_LEDC_FREQ);
  ledcWrite(BUZZER_LEDC_CHANNEL, 128);
}

void buzzerOff() {
  ledcWriteTone(BUZZER_LEDC_CHANNEL, 0);
  ledcWrite(BUZZER_LEDC_CHANNEL, 0);
}

void activateAlarm(GasSeverity severity) {
  if (!state.alarmArmed || severity < GAS_MEDIUM) return;

  state.alarmActive = true;
  state.buzzerOutputOn = true;
  state.lastAlarmToggle = millis();
  buzzerOn();
}

void updateAlarmOutput() {
  if (!state.alarmActive || !state.alarmArmed) return;

  if (state.currentSeverity == GAS_CRITICAL) {
    if (!state.buzzerOutputOn) {
      buzzerOn();
      state.buzzerOutputOn = true;
    }
    return;
  }

  const unsigned long interval = state.currentSeverity == GAS_HIGH ? 150 : 400;
  if (millis() - state.lastAlarmToggle >= interval) {
    state.lastAlarmToggle = millis();
    state.buzzerOutputOn = !state.buzzerOutputOn;
    if (state.buzzerOutputOn) buzzerOn();
    else buzzerOff();
  }
}

void stopAlarmOutput() {
  buzzerOff();
  state.alarmActive = false;
  state.buzzerOutputOn = false;
  state.lastAlarmToggle = 0;
}

void silenceAlarm() {
  stopAlarmOutput();
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
  
  if (state.currentSeverity >= GAS_MEDIUM) {
    lcd.print("GAS ALERT!");
    lcd.setCursor(0, 1);
    lcd.printf("Level:%d %s", state.currentGasLevel,
               state.valveClosed ? "CLOSED" : "OPEN");
  } else if (!state.scaleCalibrated || !state.scaleReadingValid) {
    lcd.print("Scale not ready");
    lcd.setCursor(0, 1);
    lcd.print(state.valveClosed ? "Valve: CLOSED" : "Valve: OPEN");
  } else {
    // The device reports only gross weight. Backend/app calculate LPG remaining.
    lcd.printf("Weight %.1fkg", state.currentWeight);
    lcd.setCursor(0, 1);
    lcd.print(state.valveClosed ? "Valve: CLOSED" : "Valve: OPEN");
  }
}

// Serial Command Handling
void handleSerialCommands() {
  if (Serial.available()) {
    String command = Serial.readStringUntil('\n');
    command.trim();

    String normalizedCommand = command;
    normalizedCommand.toLowerCase();
    const String tokenCommandPrefix = "set_token ";
    if (normalizedCommand.startsWith(tokenCommandPrefix)) {
      String newToken = command.substring(tokenCommandPrefix.length());
      newToken.trim();
      bool isValidToken = newToken.length() == 40;
      for (size_t i = 0; isValidToken && i < newToken.length(); i++) {
        const char c = newToken[i];
        isValidToken = (c >= '0' && c <= '9') || (c >= 'a' && c <= 'f') ||
                       (c >= 'A' && c <= 'F');
      }

      if (isValidToken) {
        newToken.toLowerCase();
        deviceApiToken = newToken;
        preferences.putString("api_token", deviceApiToken);
        Serial.println("✅ API token saved to device storage");
      } else {
        Serial.println("❌ Token not saved; expected a 40-character API token");
      }
      return;
    }

    command = normalizedCommand;
    
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

  const bool hadPreviousCalibration = state.scaleCalibrated;
  const float previousCalibrationFactor = state.calibration_factor;
  
  Serial.println("\n=== Weight Calibration ===");
  Serial.println("1. Remove all weight and press ENTER");
  waitForSerial();
  
  scale.tare();
  Serial.println("✅ Scale tared");

  Serial.println("\n2. Enter known weight (kg):");
  float known_weight = readFloatFromSerial();
  if (!isfinite(known_weight) || known_weight <= 0.0f) {
    Serial.println("❌ Calibration stopped: enter a valid weight greater than zero");
    return;
  }
  Serial.printf("Known weight: %.2f kg\n", known_weight);

  Serial.println("\n3. Place weight and press ENTER");
  waitForSerial();

  Serial.println("🔄 Calibrating...");
  delay(2000);
  long reading = scale.get_value(10);
  const float calibrationFactor = static_cast<float>(reading) / known_weight;
  if (!isfinite(calibrationFactor) || fabsf(calibrationFactor) <= 0.000001f) {
    Serial.println("❌ Calibration stopped: sensor produced an invalid factor");
    return;
  }

  scale.set_scale(calibrationFactor);
  Serial.printf("✅ Calibration factor: %.2f\n", calibrationFactor);
  Serial.printf("Current reading: %.2f kg\n", scale.get_units(5));
  if (saveCalibration(calibrationFactor)) {
    state.calibration_factor = calibrationFactor;
    state.scaleCalibrated = true;
  } else {
    state.calibration_factor = previousCalibrationFactor;
    state.scaleCalibrated = hadPreviousCalibration;
    if (hadPreviousCalibration) scale.set_scale(previousCalibrationFactor);
    else scale.set_scale();
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
  Serial.printf("Gas Level: %d\n", state.currentGasLevel);
  Serial.printf("Gas Safety Lockout: %s\n", state.gasSafetyLockout ? "Active" : "Inactive");
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
  Serial.println("set_token .. - Save the API token to device storage");
  Serial.println("info         - Show device information");
  Serial.println("test_leds    - Test LED functionality");
  Serial.println("help         - Show this help menu");
  Serial.println("===========================");
}
