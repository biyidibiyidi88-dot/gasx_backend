/*
 * ESP32 Gas Monitor with Weight Measurement and Valve Control
 * 
 * Features:
 * - Hardcoded API token authentication
 * - MQ gas sensor for leak detection
 * - HX711 Load Cell for weight measurement
 * - Servo motor for automatic gas valve shutoff
 * - Buzzer for audible alerts
 * - Sends data to Gas Monitor backend
 */

 #include <WiFi.h>
 #include <HTTPClient.h>
 #include <ArduinoJson.h>
 #include <WiFiManager.h>
 #include <Preferences.h>
 #include "HX711.h"
 #include <ESP32Servo.h>
 
 // Hardcoded Configuration
 const char* API_TOKEN = "972e4539789c26414553c450b2994111b7ebccae";
 const int SENSOR_ID = 13;
 const char* DEVICE_ID = "ESP32_GAS_001";
 const char* LOCATION = "Home Gas Monitor";
 
 // API Configuration
 const char* api_base_url = "https://gas-monitor-sfk3.onrender.com/api";
 
 // Hardware Pin Configuration
 const int MQ_SENSOR_PIN = 34;      // Analog pin for MQ sensor
 const int LOADCELL_DOUT_PIN = 2;   // HX711 DT pin
 const int LOADCELL_SCK_PIN = 15;   // HX711 SCK pin
 const int SERVO_PIN = 35;          // Servo control pin (yellow wire)
 
 const int LED_NORMAL_PIN = 5;      // Green LED
 const int LED_WARNING_PIN = 18;    // Yellow LED
 const int LED_CRITICAL_PIN = 19;   // Red LED
 const int BUZZER_PIN = 21;         // Buzzer
 const int CONFIG_BUTTON_PIN = 0;   // Configuration button
 
 // Servo Configuration
 const int SERVO_OPEN_ANGLE = 0;    // Angle when valve is open
 const int SERVO_CLOSED_ANGLE = 180; // Angle when valve is closed
 
 // Gas Detection Thresholds (in ppm)
 const int GAS_NORMAL_THRESHOLD = 300;
 const int GAS_WARNING_THRESHOLD = 800;
 const int GAS_CRITICAL_THRESHOLD = 1500;
 
 // Weight Measurement Configuration
 const float TANK_EMPTY_WEIGHT = 6.0;     // Weight of empty tank in kg
 const float TANK_FULL_WEIGHT = 26.0;     // Weight of full tank (20kg gas + 15kg tank)
 const float MIN_WEIGHT_CHANGE = 0.1;     // Minimum weight change to trigger update
 
 // Timing Configuration
 const unsigned long READING_INTERVAL = 30000;    // Send readings every 30 seconds
 const unsigned long WEIGHT_READING_INTERVAL = 5000;  // Read weight every 5 seconds
 const unsigned long ALERT_COOLDOWN = 300000;     // 5 minutes cooldown between alerts
 
 // Global Variables
 HX711 scale;
 Servo gasValveServo;
 Preferences preferences;
 WiFiManager wifiManager;
 
 unsigned long lastReadingTime = 0;
 unsigned long lastWeightReadingTime = 0;
 unsigned long lastAlertTime = 0;
 
 bool wifiConnected = false;
 bool scaleCalibrated = false;
 bool valveClosed = false;
 
 float currentWeight = 0.0;
 float lastStableWeight = 0.0;
 float calibration_factor = 1.0;
 
 int currentGasLevel = 0;
 String currentSeverity = "LOW";
 
 void setup() {
   Serial.begin(115200);
   Serial.println("\n=== ESP32 Gas & Weight Monitor with Valve Control ===");
 
   // Initialize Preferences for calibration storage
   preferences.begin("gas_monitor", false);
 
   // Initialize hardware pins
   pinMode(LED_NORMAL_PIN, OUTPUT);
   pinMode(LED_WARNING_PIN, OUTPUT);
   pinMode(LED_CRITICAL_PIN, OUTPUT);
   pinMode(BUZZER_PIN, OUTPUT);
   pinMode(CONFIG_BUTTON_PIN, INPUT_PULLUP);
 
   // Initialize servo
   gasValveServo.attach(SERVO_PIN);
   gasValveServo.write(SERVO_OPEN_ANGLE); // Start with valve open
   delay(500); // Give servo time to move
 
   // Test LEDs and initialize
   testLEDs();
   initializeLoadCell();
   connectToWiFi();
 
   // Warm up MQ sensor
   Serial.println("Warming up MQ sensor (2 seconds)...");
   setStatusLED("warming");
   delay(2000);
 
   Serial.println("\n✅ System Ready!");
   printDeviceInfo();
   setStatusLED("normal");
 }
 
 void loop() {
   // Check WiFi connection
   if (WiFi.status() != WL_CONNECTED) {
     if (wifiConnected) {
       Serial.println("WiFi disconnected. Reconnecting...");
       wifiConnected = false;
       setStatusLED("error");
     }
     connectToWiFi();
     delay(5000);
     return;
   }
 
   // Check for configuration button press
   if (digitalRead(CONFIG_BUTTON_PIN) == LOW) {
     delay(100); // Debounce
     if (digitalRead(CONFIG_BUTTON_PIN) == LOW) {
       enterConfigurationMode();
     }
   }
 
   // Read gas sensor for leak detection
   currentGasLevel = readGasSensor();
   currentSeverity = determineGasSeverity(currentGasLevel);
   updateStatusIndicators(currentSeverity);
 
   // Handle gas leak detection
   if (currentSeverity == "CRITICAL" || currentSeverity == "HIGH") {
     handleGasLeak(currentGasLevel, currentSeverity);
   }
 
   // Read weight sensor for remaining gas level
   if (millis() - lastWeightReadingTime >= WEIGHT_READING_INTERVAL) {
     readWeightSensor();
     lastWeightReadingTime = millis();
   }
 
   // Send regular readings
   if (millis() - lastReadingTime >= READING_INTERVAL) {
     if (wifiConnected) {
       sendGasReading(currentGasLevel);
       sendWeightReading();
     }
     lastReadingTime = millis();
   }
 
   // Handle serial commands for calibration and valve control
   handleSerialCommands();
   delay(1000);
 }
 
 // --- WiFi & Initialization Functions ---
 void connectToWiFi() {
   wifiManager.setConfigPortalTimeout(180);
   if (wifiManager.autoConnect("GasMonitor-Setup")) {
     Serial.println("\n✅ WiFi connected via Manager!");
     Serial.print("IP Address: ");
     Serial.println(WiFi.localIP());
     wifiConnected = true;
   } else {
     Serial.println("\n❌ Could not connect to WiFi.");
     wifiConnected = false;
   }
 }
 
 void initializeLoadCell() {
   Serial.println("Initializing HX711 Load Cell...");
   scale.begin(LOADCELL_DOUT_PIN, LOADCELL_SCK_PIN);
   delay(1000);
 
   if (scale.is_ready()) {
     Serial.println("✅ HX711 connected.");
     loadCalibration();
     if (scaleCalibrated) {
       scale.set_scale(calibration_factor);
       scale.tare();
       Serial.println("✅ Scale calibrated and ready.");
     } else {
       Serial.println("⚠️ Scale not calibrated. Use 'calibrate' command.");
     }
   } else {
     Serial.println("❌ HX711 not found! Check wiring.");
   }
 }
 
 // --- Weight & Calibration Functions ---
 void loadCalibration() {
   calibration_factor = preferences.getFloat("cal_factor", 0.0);
   scaleCalibrated = preferences.getBool("cal_done", false);
   if (scaleCalibrated) {
     Serial.printf("Loaded calibration factor: %.2f\n", calibration_factor);
   } else {
     Serial.println("No valid calibration found in Preferences.");
   }
 }
 
 void saveCalibration() {
   preferences.putFloat("cal_factor", calibration_factor);
   preferences.putBool("cal_done", true);
   Serial.printf("✅ Calibration factor saved permanently: %.2f\n", calibration_factor);
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
 
     Serial.printf("Weight: %.2f kg | Gas: %.2f kg (%.1f%%)\n", currentWeight, gasWeight, gasPercentage);
 
     // Check for low gas alert (≤10% remaining)
     if (gasPercentage <= 10.0 && millis() - lastAlertTime >= ALERT_COOLDOWN) {
       handleLowGasAlert(gasPercentage);
     }
   }
 }
 
 // --- Gas Sensor Functions ---
 int readGasSensor() {
   int analogValue = analogRead(MQ_SENSOR_PIN);
   return map(analogValue, 0, 4095, 0, 2000); // Map to approximate ppm
 }
 
 String determineGasSeverity(int gasLevel) {
   if (gasLevel >= GAS_CRITICAL_THRESHOLD) return "CRITICAL";
   if (gasLevel >= GAS_WARNING_THRESHOLD) return "HIGH";
   if (gasLevel >= GAS_NORMAL_THRESHOLD) return "MEDIUM";
   return "LOW";
 }
 
 // --- Valve Control Functions ---
 void controlGasValve(bool open) {
   if (open) {
     gasValveServo.write(SERVO_OPEN_ANGLE);
     valveClosed = false;
     Serial.println("Gas valve opened");
   } else {
     gasValveServo.write(SERVO_CLOSED_ANGLE);
     valveClosed = true;
     Serial.println("Gas valve closed");
   }
   delay(500); // Give servo time to move
 }
 
 // --- Alert Handling Functions ---
 void handleGasLeak(int gasLevel, String severity) {
   if (millis() - lastAlertTime < ALERT_COOLDOWN) return;
   
   Serial.printf("🚨 GAS LEAK DETECTED! Level: %d ppm, Severity: %s\n", gasLevel, severity.c_str());
   
   // Close gas valve
   controlGasValve(false);
   
   // Sound alarm
   for (int i = 0; i < 5; i++) {
     digitalWrite(BUZZER_PIN, HIGH);
     delay(200);
     digitalWrite(BUZZER_PIN, LOW);
     delay(200);
   }
   
   sendGasLeakAlert(gasLevel, severity);
   lastAlertTime = millis();
 }
 
 void handleLowGasAlert(float gasPercentage) {
   Serial.printf("🚨 LOW GAS ALERT: %.1f%% remaining\n", gasPercentage);
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
 
 // --- API Communication Functions ---
 void sendGasReading(int gasLevel) {
   if (!wifiConnected) return;
   
   HTTPClient http;
   http.begin(String(api_base_url) + "/gas-readings/create/");
   http.addHeader("Content-Type", "application/json");
   http.addHeader("Authorization", "Token " + String(API_TOKEN));
   
   float estimatedGas = map(gasLevel, 0, 2000, 0, 20);
   float estimatedGasRounded = round(estimatedGas * 100.0) / 100.0;
   
   DynamicJsonDocument doc(1024);
   doc["sensor"] = SENSOR_ID;
   doc["remaining_gas"] = estimatedGasRounded;
   
   String payload;
   serializeJson(doc, payload);
   
   int httpResponseCode = http.POST(payload);
   if (httpResponseCode > 0) {
     Serial.printf("Gas reading sent (%d) - Estimated: %.2fkg\n", httpResponseCode, estimatedGasRounded);
   } else {
     Serial.printf("Gas reading error: %s\n", http.errorToString(httpResponseCode).c_str());
   }
   http.end();
 }
 
 void sendWeightReading() {
   if (!wifiConnected || !scaleCalibrated) return;
   
   float weight = scale.get_units(5);
   
   HTTPClient http;
   http.begin(String(api_base_url) + "/gas-readings/create/");
   http.addHeader("Content-Type", "application/json");
   http.addHeader("Authorization", "Token " + String(API_TOKEN));
   
   float gasWeight = max(0.0f, weight - TANK_EMPTY_WEIGHT);
   float gasPercentage = (gasWeight / (TANK_FULL_WEIGHT - TANK_EMPTY_WEIGHT)) * 100.0;
   gasPercentage = constrain(gasPercentage, 0.0, 100.0);
   
   float gasWeightRounded = round(gasWeight * 100.0) / 100.0;
   
   DynamicJsonDocument doc(1024);
   doc["sensor"] = SENSOR_ID;
   doc["remaining_gas"] = gasWeightRounded;
   
   String payload;
   serializeJson(doc, payload);
   
   int httpResponseCode = http.POST(payload);
   if (httpResponseCode > 0) {
     Serial.printf("Weight reading sent (%d) - Total: %.2fkg, Gas: %.2fkg (%.1f%%)\n", 
                  httpResponseCode, weight, gasWeightRounded, gasPercentage);
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
   doc["valve_status"] = "closed";
   
   String payload;
   serializeJson(doc, payload);
   
   int httpResponseCode = http.POST(payload);
   if (httpResponseCode > 0) {
     Serial.printf("Gas leak alert sent (%d)\n", httpResponseCode);
   } else {
     Serial.printf("Gas leak alert error: %s\n", http.errorToString(httpResponseCode).c_str());
   }
   http.end();
 }
 
 // --- Status & LED Functions ---
 void updateStatusIndicators(String severity) {
   digitalWrite(LED_NORMAL_PIN, LOW);
   digitalWrite(LED_WARNING_PIN, LOW);
   digitalWrite(LED_CRITICAL_PIN, LOW);
   
   if (severity == "CRITICAL") {
     digitalWrite(LED_CRITICAL_PIN, HIGH);
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
   Serial.println("Testing LEDs and Buzzer...");
   digitalWrite(LED_NORMAL_PIN, HIGH);
   delay(300);
   digitalWrite(LED_NORMAL_PIN, LOW);
   digitalWrite(LED_WARNING_PIN, HIGH);
   delay(300);
   digitalWrite(LED_WARNING_PIN, LOW);
   digitalWrite(LED_CRITICAL_PIN, HIGH);
   delay(300);
   digitalWrite(LED_CRITICAL_PIN, LOW);
   
   // Test buzzer
   digitalWrite(BUZZER_PIN, HIGH);
   delay(200);
   digitalWrite(BUZZER_PIN, LOW);
   
   // Test servo
   gasValveServo.write(SERVO_OPEN_ANGLE);
   delay(500);
   gasValveServo.write(SERVO_CLOSED_ANGLE);
   delay(500);
   gasValveServo.write(SERVO_OPEN_ANGLE);
   delay(500);
 }
 
 // --- Serial Commands & Configuration ---
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
         Serial.println("Scale tared.");
       } else {
         Serial.println("Scale not calibrated.");
       }
     } else if (command == "weight") {
       if (scaleCalibrated) {
         Serial.printf("Weight: %.2f kg\n", scale.get_units(3));
       } else {
         Serial.println("Scale not calibrated.");
       }
     } else if (command == "reset_cal") {
       preferences.remove("cal_factor");
       preferences.remove("cal_done");
       scaleCalibrated = false;
       Serial.println("Calibration reset.");
     } else if (command == "open_valve") {
       controlGasValve(true);
     } else if (command == "close_valve") {
       controlGasValve(false);
     } else if (command == "valve_status") {
       Serial.println(valveClosed ? "Valve is CLOSED" : "Valve is OPEN");
     } else if (command == "info") {
       printDeviceInfo();
     } else if (command == "help") {
       Serial.println("\nAvailable commands:");
       Serial.println("- calibrate: Start weight calibration");
       Serial.println("- tare: Zero the scale");
       Serial.println("- weight: Show current weight");
       Serial.println("- reset_cal: Reset calibration");
       Serial.println("- open_valve: Open gas valve");
       Serial.println("- close_valve: Close gas valve");
       Serial.println("- valve_status: Check valve status");
       Serial.println("- info: Show device info");
       Serial.println("- help: Show this help");
     }
   }
 }
 
 void startWeightCalibration() {
   if (!scale.is_ready()) {
     Serial.println("Scale not ready.");
     return;
   }
   
   Serial.println("\n🔧 === Weight Calibration ===");
   Serial.println("Step 1: Remove ALL weight. Press ENTER when ready.");
   while (!Serial.available()) delay(100);
   while (Serial.available()) Serial.read();
   
   scale.tare();
   Serial.println("Scale tared.");
 
   Serial.println("\nStep 2: Enter known weight (kg), e.g., 1.5");
   float known_weight = 0.0;
   while (known_weight <= 0) {
     if (Serial.available()) {
       known_weight = Serial.parseFloat();
     }
     delay(100);
   }
   while (Serial.available()) Serial.read();
   Serial.printf("Known weight: %.2f kg\n", known_weight);
 
   Serial.println("\nStep 3: Place known weight on scale. Press ENTER.");
   while (!Serial.available()) delay(100);
   while (Serial.available()) Serial.read();
 
   Serial.println("Calibrating...");
   delay(2000);
   long reading = scale.get_value(10);
   calibration_factor = reading / known_weight;
   scale.set_scale(calibration_factor);
 
   Serial.printf("Factor: %.2f. Measured: %.2f kg\n", calibration_factor, scale.get_units(5));
   Serial.println("Save calibration? (y/n)");
 
   while (!Serial.available()) delay(100);
   char response = Serial.read();
   if (response == 'y' || response == 'Y') {
     scaleCalibrated = true;
     saveCalibration();
   } else {
     Serial.println("Calibration not saved.");
   }
   while (Serial.available()) Serial.read();
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
   Serial.printf("Gas Valve Status: %s\n", valveClosed ? "CLOSED" : "OPEN");
   Serial.printf("Current Gas Level: %d ppm\n", currentGasLevel);
   Serial.printf("Current Severity: %s\n", currentSeverity.c_str());
   Serial.println("============================\n");
 }