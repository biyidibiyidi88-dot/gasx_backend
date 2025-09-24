/*
 * ESP32 Gas Monitor - Quality Data Version (Non-Blocking + Smoothed)
 *
 * Changes vs gas_monitor_quality.ino:
 * - Non-blocking alarm patterns using millis() -> silence button stops immediately and LED turns green
 * - MQ sensor smoothing (moving average) + basic hysteresis to reduce flicker
 * - remaining_gas rounded to 2 decimals in sendGasReading() to satisfy backend
 * - Fix BUZZER_PIN to 23
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

// Hardware Constants
const int MQ_SENSOR_PIN = 34;
const int LOADCELL_DOUT_PIN = 2;
const int LOADCELL_SCK_PIN = 15;
const int SERVO_PIN = 4;
const int LED_NORMAL_PIN = 5;
const int LED_WARNING_PIN = 18;
const int LED_CRITICAL_PIN = 19;
const int BUZZER_PIN = 23; // fixed
// LEDC (PWM) config for buzzer
const int BUZZER_LEDC_CHANNEL = 0;   // use channel 0
const int BUZZER_LEDC_FREQ = 2000;   // 2 kHz tone
const int BUZZER_LEDC_RES = 8;       // 8-bit resolution
const int CONFIG_BUTTON_PIN = 0;
const int ALARM_SILENCE_PIN = 26;
const int VALVE_CONTROL_BUTTON_PIN = 25;  // New button for valve control

// Configuration
const char* API_TOKEN = "972e4539789c26414553c450b2994111b7ebccae";
const int SENSOR_ID = 13;
const char* DEVICE_ID = "ESP32_GAS_001";
const char* LOCATION = "Home Gas Monitor";
const char* api_base_url = "https://gas-monitor-sfk3.onrender.com/api";

// Thresholds (requested)
const int GAS_NORMAL_THRESHOLD = 200;
const int GAS_WARNING_THRESHOLD = 1500;
const int GAS_CRITICAL_THRESHOLD = 500;
const float TANK_EMPTY_WEIGHT = 6.0;
const float TANK_FULL_WEIGHT = 26.0;
const float MIN_WEIGHT_CHANGE = 0.2;

// Timing
const unsigned long READING_INTERVAL = 30000;
const unsigned long WEIGHT_READING_INTERVAL = 10000;
const unsigned long ALERT_COOLDOWN = 10000;
const unsigned long BUTTON_DEBOUNCE = 200;
const unsigned long WIFI_CHECK_INTERVAL = 10000;

// Servo positions
const int SERVO_OPEN_POSITION = 0;
const int SERVO_CLOSED_POSITION = 180;
const int SERVO_DELAY_MS = 600;

// Gas severity levels
enum GasSeverity { GAS_LOW = 0, GAS_MEDIUM = 1, GAS_HIGH = 2, GAS_CRITICAL = 3 };

// Global Objects
HX711 scale;
Preferences preferences;
WiFiManager wifiManager;
Servo valveServo;
HTTPClient http;

// Smoothing configuration
const int MQ_SAMPLES = 8;             // multi-sample average
const float EMA_ALPHA = 0.3;          // exponential smoothing factor
int mqSampleIdx = 0;
int mqSamples[MQ_SAMPLES] = {0};
float mqEma = 0.0;                    // smoothed gas level

// Hysteresis
const int HYSTERESIS_MARGIN = 50;     // prevent rapid toggling around thresholds

// Alarm non-blocking pattern
struct AlarmState {
  bool active = false;                // buzzer sounding allowed
  bool silenced = false;              // user silenced
  GasSeverity severity = GAS_LOW;
  unsigned long lastToggle = 0;       // buzzer on/off toggle
  bool buzzerOn = false;              // current buzzer state
} alarmState;

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
  float currentWeight = 0.0;
  float lastSentWeight = 0.0;
  float lastStableWeight = 0.0;
  float calibration_factor = 1.0;
  int currentGasLevel = 0;            // latest smoothed gas level
  GasSeverity currentSeverity = GAS_LOW;
} state;

void setup() {
  Serial.begin(115200);
  Serial.println("\n=== ESP32 Gas Monitor - Quality (NB) ===");

  preferences.begin("gas_monitor", false);

  // LCD
  Wire.begin(21, 22);
  lcd.init();
  lcd.backlight();
  lcd.setCursor(0, 0); lcd.print("Gas Monitor");
  lcd.setCursor(0, 1); lcd.print("Quality NB");

  // Hardware
  pinMode(LED_NORMAL_PIN, OUTPUT);
  pinMode(LED_WARNING_PIN, OUTPUT);
  pinMode(LED_CRITICAL_PIN, OUTPUT);
  pinMode(BUZZER_PIN, OUTPUT);
  // Configure LEDC PWM for buzzer (works with active or passive buzzer)
  ledcSetup(BUZZER_LEDC_CHANNEL, BUZZER_LEDC_FREQ, BUZZER_LEDC_RES);
  ledcAttachPin(BUZZER_PIN, BUZZER_LEDC_CHANNEL);
  pinMode(CONFIG_BUTTON_PIN, INPUT_PULLUP);
  pinMode(ALARM_SILENCE_PIN, INPUT_PULLUP);
  pinMode(VALVE_CONTROL_BUTTON_PIN, INPUT_PULLUP);

  valveServo.attach(SERVO_PIN);
  openValve();

  testLEDs();
  // Quick buzzer self-test
  buzzerOn();
  delay(150);
  buzzerOff();
  initializeLoadCell();
  connectToWiFi();

  Serial.println("Warming up sensors...");
  setStatusLED("warning");
  delay(1500);

  Serial.println("\n✅ System Ready - Quality NB Active");
  setStatusLED("normal");
  lcd.clear();
  lcd.setCursor(0, 0); lcd.print("Gas Monitor");
  lcd.setCursor(0, 1); lcd.print("Ready - NB");
}

void loop() {
  handleWiFiConnection();
  handleButtons();
  monitorGas();
  monitorWeight();
  updateAlarm();           // non-blocking buzzer handling
  sendRegularReadings();
  handleSerialCommands();
  delay(5);
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
    } else if (!state.wifiConnected) {
      Serial.println("✅ WiFi reconnected");
      setStatusLED("normal");
      state.wifiConnected = true;
    }
  }
}

void handleButtons() {
  // Alarm silence button
  if (digitalRead(ALARM_SILENCE_PIN) == LOW && (millis() - state.lastAlarmSilencePress > BUTTON_DEBOUNCE)) {
    state.lastAlarmSilencePress = millis();
    silenceAlarmImmediate();
    Serial.println("🔇 Alarm silenced by button");
  }

  // Valve control button
  if (digitalRead(VALVE_CONTROL_BUTTON_PIN) == LOW && (millis() - state.lastValveButtonPress > BUTTON_DEBOUNCE)) {
    state.lastValveButtonPress = millis();
    toggleValve();

    lcd.clear();
    lcd.setCursor(0, 0); lcd.print("Valve Status:");
    lcd.setCursor(0, 1); lcd.print(state.valveClosed ? "CLOSED" : "OPEN");
    delay(800);
    updateLCDDisplay();
  }

  // Config button
  if (digitalRead(CONFIG_BUTTON_PIN) == LOW) {
    delay(50);
    if (digitalRead(CONFIG_BUTTON_PIN) == LOW) {
      enterConfigurationMode();
    }
  }
}

void monitorGas() {
  int gasLevel = readGasSensorSmoothed();
  if (gasLevel < 0) gasLevel = 0;

  state.currentGasLevel = gasLevel;
  GasSeverity newSeverity = determineGasSeverityHysteresis(gasLevel, state.currentSeverity);
  state.currentSeverity = newSeverity;
  updateStatusLED();

  // Start alarm from MEDIUM and above to ensure audible alert on detection
  if (newSeverity >= GAS_MEDIUM) {
    handleGasAlert(gasLevel, newSeverity);
  }
}

void monitorWeight() {
  if (millis() - state.lastWeightReadingTime >= WEIGHT_READING_INTERVAL) {
    state.lastWeightReadingTime = millis();
    readWeightSensor();

    float weightDiff = fabs(state.currentWeight - state.lastSentWeight);
    if (weightDiff >= MIN_WEIGHT_CHANGE) {
      Serial.printf("📊 Significant weight change: %.2f kg (Δ %.2f)\n", state.currentWeight, weightDiff);
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
      Serial.printf("📡 Regular reading sent - Gas: %d, Weight: %.2f kg\n", state.currentGasLevel, state.currentWeight);
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
int readGasSensorRaw() {
  int raw = analogRead(MQ_SENSOR_PIN);
  if (raw < 0) raw = 0;
  if (raw > 4095) raw = 4095;
  return map(raw, 0, 4095, 0, 1000);
}

int readGasSensorSmoothed() {
  // rolling average
  int reading = readGasSensorRaw();
  mqSamples[mqSampleIdx] = reading;
  mqSampleIdx = (mqSampleIdx + 1) % MQ_SAMPLES;

  long sum = 0;
  for (int i = 0; i < MQ_SAMPLES; i++) sum += mqSamples[i];
  float avg = (float)sum / MQ_SAMPLES;

  // EMA smoothing
  mqEma = (EMA_ALPHA * avg) + ((1.0 - EMA_ALPHA) * mqEma);
  if (mqEma < 0) mqEma = 0;
  if (mqEma > 1000) mqEma = 1000;
  return (int)round(mqEma);
}

GasSeverity determineGasSeverityHysteresis(int gasLevel, GasSeverity current) {
  // Enter thresholds
  if (current == GAS_LOW) {
    if (gasLevel >= GAS_NORMAL_THRESHOLD) return GAS_MEDIUM;
    return GAS_LOW;
  }
  if (current == GAS_MEDIUM) {
    if (gasLevel >= GAS_WARNING_THRESHOLD) return GAS_HIGH;
    if (gasLevel < (GAS_NORMAL_THRESHOLD - HYSTERESIS_MARGIN)) return GAS_LOW;
    return GAS_MEDIUM;
  }
  if (current == GAS_HIGH) {
    if (gasLevel >= GAS_CRITICAL_THRESHOLD) return GAS_CRITICAL;
    if (gasLevel < (GAS_WARNING_THRESHOLD - HYSTERESIS_MARGIN)) return GAS_MEDIUM;
    return GAS_HIGH;
  }
  // GAS_CRITICAL
  if (gasLevel < (GAS_CRITICAL_THRESHOLD - HYSTERESIS_MARGIN)) return GAS_HIGH;
  return GAS_CRITICAL;
}

void readWeightSensor() {
  if (!state.scaleCalibrated) { state.currentWeight = 0.0; return; }
  if (scale.is_ready()) {
    float weight = scale.get_units(3);
    if (weight < 0) { weight = 0.0; Serial.println("⚠️  Negative weight corrected to 0"); }
    if (weight > 100.0) { Serial.printf("⚠️  Unusually high weight: %.2f kg - ignored\n", weight); return; }
    state.currentWeight = weight;
    if (fabs(weight - state.lastStableWeight) < 0.05) state.lastStableWeight = weight;
  }
}

// API Communication Functions
void sendGasReading() {
  if (!state.wifiConnected) return;

  http.begin(String(api_base_url) + "/gas-readings/create/");
  http.addHeader("Content-Type", "application/json");
  http.addHeader("Authorization", "Token " + String(API_TOKEN));

  float remainingGas;
  if (state.scaleCalibrated && state.currentWeight > 0) {
    remainingGas = max(0.0f, state.currentWeight - TANK_EMPTY_WEIGHT);
  } else {
    remainingGas = map(state.currentGasLevel, 0, 1000, 0, 20);
    remainingGas = max(0.0f, remainingGas);
  }
  // Round to 2 decimals to satisfy backend
  float remainingRounded = roundf(remainingGas * 100.0f) / 100.0f;

  StaticJsonDocument<512> doc;
  doc["sensor"] = SENSOR_ID;
  doc["remaining_gas"] = remainingRounded;

  String payload; serializeJson(doc, payload);
  int code = http.POST(payload);

  if (code == 201) {
    Serial.printf("✅ Gas reading sent: %.2f kg\n", remainingRounded);
  } else {
    Serial.printf("❌ Gas reading failed: %d\n", code);
    if (code > 0) Serial.println("Response: " + http.getString());
  }
  http.end();
}

void sendWeightReading() {
  if (!state.wifiConnected || !state.scaleCalibrated) return;
  if (state.currentWeight < 0) { Serial.println("⚠️  Skip weight tx - invalid"); return; }

  http.begin(String(api_base_url) + "/gas-readings/create/");
  http.addHeader("Content-Type", "application/json");
  http.addHeader("Authorization", "Token " + String(API_TOKEN));

  float gasWeight = max(0.0f, state.currentWeight - TANK_EMPTY_WEIGHT);
  float gasRounded = roundf(gasWeight * 100.0f) / 100.0f;

  StaticJsonDocument<512> doc;
  doc["sensor"] = SENSOR_ID;
  doc["remaining_gas"] = gasRounded;

  String payload; serializeJson(doc, payload);
  int code = http.POST(payload);

  if (code == 201) {
    Serial.printf("✅ Weight reading sent: %.2f kg\n", gasRounded);
  } else {
    Serial.printf("❌ Weight reading failed: %d\n", code);
    if (code > 0) Serial.println("Response: " + http.getString());
  }
  http.end();
}

void handleGasAlert(int gasLevel, GasSeverity severity) {
  bool shouldSendAlert = (millis() - state.lastAlertTime >= ALERT_COOLDOWN);

  // Request alarm (non-blocking) unless silenced currently
  if (!alarmState.silenced) {
    alarmState.active = true;
    alarmState.severity = severity;
    // Immediate buzzer kick so user hears alert instantly
    buzzerOn();
    alarmState.buzzerOn = true;
    alarmState.lastToggle = millis();
  }

  // Auto-close valve for HIGH/CRITICAL
  if (!state.valveClosed) {
    closeValve();
    Serial.println("🔒 Valve auto-closed due to gas level");
  }

  if (shouldSendAlert) {
    String sevStr = (severity == GAS_CRITICAL ? "CRITICAL" : severity == GAS_HIGH ? "HIGH" : "MEDIUM");
    sendGasLeakAlert(gasLevel, sevStr);
    state.lastAlertTime = millis();
  }

  updateLCDDisplay();
}

void sendGasLeakAlert(int gasLevel, String severity) {
  if (!state.wifiConnected) return;
  http.begin(String(api_base_url) + "/alerts/gas-leak/");
  http.addHeader("Content-Type", "application/json");
  http.addHeader("Authorization", "Token " + String(API_TOKEN));

  StaticJsonDocument<512> doc;
  doc["sensor_id"] = SENSOR_ID;
  doc["severity_level"] = severity;
  doc["gas_concentration"] = max(0, gasLevel);
  doc["location_details"] = LOCATION;
  doc["alert_message"] = String("Gas leak detected - Level: ") + gasLevel;

  String payload; serializeJson(doc, payload);
  int code = http.POST(payload);

  if (code == 201) Serial.println("✅ Gas leak alert sent");
  else {
    Serial.printf("❌ Gas leak alert failed: %d\n", code);
    if (code > 0) Serial.println("Response: " + http.getString());
  }
  http.end();
}

// Control Functions
void toggleValve() { if (state.valveClosed) openValve(); else closeValve(); }

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

// Non-blocking alarm handling
void updateAlarm() {
  // If silenced: ensure buzzer off and green LED if WiFi OK and not high severity
  if (alarmState.silenced) {
    if (alarmState.buzzerOn) { digitalWrite(BUZZER_PIN, LOW); alarmState.buzzerOn = false; }
    setStatusLED("normal");
    alarmState.active = false; // stop pattern until re-armed by new event
    return;
  }

  if (!alarmState.active) { // ensure off
    if (alarmState.buzzerOn) { digitalWrite(BUZZER_PIN, LOW); alarmState.buzzerOn = false; }
    return;
  }

  unsigned long now = millis();
  unsigned long onMs = 0, offMs = 0;
  switch (alarmState.severity) {
    case GAS_CRITICAL: onMs = 1000; offMs = 50; break;   // almost continuous
    case GAS_HIGH:     onMs = 120;  offMs = 120; break;  // fast beeps
    case GAS_MEDIUM:   onMs = 300;  offMs = 300; break;  // slower
    default:           onMs = 0;    offMs = 0; break;
  }

  if (onMs == 0 && offMs == 0) { buzzerOff(); alarmState.buzzerOn = false; return; }

  // Toggle pattern
  if (alarmState.buzzerOn) {
    if (now - alarmState.lastToggle >= onMs) {
      buzzerOff();
      alarmState.buzzerOn = false;
      alarmState.lastToggle = now;
    }
  } else {
    if (now - alarmState.lastToggle >= offMs) {
      buzzerOn();
      alarmState.buzzerOn = true;
      alarmState.lastToggle = now;
    }
  }
}

void silenceAlarmImmediate() {
  alarmState.silenced = true;
  alarmState.active = false;
  buzzerOff();
  alarmState.buzzerOn = false;
  setStatusLED("normal"); // turn gas green LED on immediately
}

// Buzzer helpers (LEDC PWM)
void buzzerOn() {
  // drive a tone that works for both active (as steady drive) and passive (as tone)
  ledcWriteTone(BUZZER_LEDC_CHANNEL, BUZZER_LEDC_FREQ);
  // ensure duty > 0
  ledcWrite(BUZZER_LEDC_CHANNEL, 128);
}

void buzzerOff() {
  ledcWriteTone(BUZZER_LEDC_CHANNEL, 0);
  ledcWrite(BUZZER_LEDC_CHANNEL, 0);
}

// LED Control Functions
void setStatusLED(String status) {
  digitalWrite(LED_NORMAL_PIN, LOW);
  digitalWrite(LED_WARNING_PIN, LOW);
  digitalWrite(LED_CRITICAL_PIN, LOW);
  if (status == "normal")      digitalWrite(LED_NORMAL_PIN, HIGH);
  else if (status == "warning") digitalWrite(LED_WARNING_PIN, HIGH);
  else if (status == "critical")digitalWrite(LED_CRITICAL_PIN, HIGH);
}

void updateStatusLED() {
  if (alarmState.silenced) { setStatusLED("normal"); return; }
  switch (state.currentSeverity) {
    case GAS_CRITICAL: setStatusLED("critical"); break;
    case GAS_HIGH:
    case GAS_MEDIUM:  setStatusLED("warning");  break;
    default:          setStatusLED("normal");   break;
  }
}

void testLEDs() {
  digitalWrite(LED_NORMAL_PIN, HIGH); delay(200); digitalWrite(LED_NORMAL_PIN, LOW);
  digitalWrite(LED_WARNING_PIN, HIGH); delay(200); digitalWrite(LED_WARNING_PIN, LOW);
  digitalWrite(LED_CRITICAL_PIN, HIGH); delay(200); digitalWrite(LED_CRITICAL_PIN, LOW);
}

// LCD Functions
void updateLCDDisplay() {
  lcd.clear();
  lcd.setCursor(0, 0);
  if (state.currentSeverity >= GAS_HIGH && !alarmState.silenced) {
    lcd.print("GAS ALERT!");
    lcd.setCursor(0, 1); lcd.printf("Level: %d", state.currentGasLevel);
  } else {
    float gasPct = 0.0;
    if (state.scaleCalibrated && state.currentWeight > 0) {
      float gasWeight = max(0.0f, state.currentWeight - TANK_EMPTY_WEIGHT);
      float cap = TANK_FULL_WEIGHT - TANK_EMPTY_WEIGHT;
      gasPct = constrain((gasWeight / cap) * 100.0f, 0.0f, 100.0f);
    } else {
      gasPct = constrain(map(state.currentGasLevel, 0, 1000, 0, 100), 0, 100);
    }
    lcd.printf("Gas: %.1f%%", gasPct);
    lcd.setCursor(0, 1);
    if (state.scaleCalibrated) lcd.printf("%.1fkg %s", state.currentWeight, state.valveClosed ? "CLOSED" : "OPEN");
    else lcd.printf("Est %s", state.valveClosed ? "CLOSED" : "OPEN");
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
    else if (command == "alarm_off") silenceAlarmImmediate();
    else if (command == "alarm_on") { alarmState.silenced = false; }
    else if (command == "info") printDeviceInfo();
    else if (command == "test_leds") testLEDs();
    else if (command == "help") printHelp();
  }
}

void startWeightCalibration() {
  if (!scale.is_ready()) { Serial.println("❌ Scale not ready"); return; }
  Serial.println("\n=== Weight Calibration ===");
  Serial.println("1. Remove all weight and press ENTER");
  waitForSerial();
  scale.tare(); Serial.println("✅ Scale tared");
  Serial.println("\n2. Enter known weight (kg):");
  float known = readFloatFromSerial();
  Serial.printf("Known weight: %.2f kg\n", known);
  Serial.println("\n3. Place weight and press ENTER");
  waitForSerial();
  Serial.println("🔄 Calibrating...");
  delay(1200);
  long reading = scale.get_value(10);
  state.calibration_factor = reading / known;
  scale.set_scale(state.calibration_factor);
  Serial.printf("✅ Cal factor: %.2f\n", state.calibration_factor);
  Serial.printf("Current: %.2f kg\n", scale.get_units(5));
  Serial.println("Save calibration? (y/n)");
  if (readYesNoFromSerial()) { state.scaleCalibrated = true; saveCalibration(); Serial.println("✅ Calibration saved"); }
}

void tareScale() {
  if (state.scaleCalibrated) { scale.tare(); Serial.println("✅ Scale tared"); }
  else Serial.println("❌ Scale not calibrated");
}

void printWeight() {
  if (state.scaleCalibrated) {
    float w = scale.get_units(3);
    if (w < 0) w = 0.0;
    Serial.printf("📏 Current weight: %.2f kg\n", w);
  } else Serial.println("❌ Scale not calibrated");
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
    delay(80);
  }
  Serial.println("✅ Exiting configuration mode");
}

// Utils
void waitForSerial() { while (!Serial.available()); while (Serial.available()) Serial.read(); }

float readFloatFromSerial() {
  float value = 0;
  while (value <= 0) { if (Serial.available()) value = Serial.parseFloat(); delay(80); }
  while (Serial.available()) Serial.read();
  return value;
}

bool readYesNoFromSerial() {
  while (!Serial.available());
  char r = Serial.read();
  while (Serial.available()) Serial.read();
  return (r == 'y' || r == 'Y');
}

void printDeviceInfo() {
  Serial.println("\n=== DEVICE INFO - QUALITY NB ===");
  Serial.printf("Device ID: %s\n", DEVICE_ID);
  Serial.printf("Location: %s\n", LOCATION);
  Serial.printf("Sensor ID: %d\n", SENSOR_ID);
  Serial.printf("WiFi: %s\n", state.wifiConnected ? "Connected" : "Disconnected");
  Serial.printf("Scale: %s\n", state.scaleCalibrated ? "Calibrated" : "Not calibrated");
  Serial.printf("Valve: %s\n", state.valveClosed ? "Closed" : "Open");
  Serial.printf("Current Weight: %.2f kg\n", state.currentWeight);
  Serial.printf("Last Sent Weight: %.2f kg\n", state.lastSentWeight);
  Serial.printf("Gas Level: %d\n", state.currentGasLevel);
  Serial.printf("Min Weight Change: %.1f kg\n", MIN_WEIGHT_CHANGE);
  Serial.println("=================================");
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
  Serial.println("alarm_off    - Silence alarm immediately");
  Serial.println("alarm_on     - Re-arm alarm beeps");
  Serial.println("info         - Show device information");
  Serial.println("test_leds    - Test LED functionality");
  Serial.println("help         - Show this help menu");
  Serial.println("===========================");
}
