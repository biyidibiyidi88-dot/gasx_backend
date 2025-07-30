/*
 * ESP32 Gas Monitor System
 * Connects to Gas Monitor Backend API
 * Uses MQ sensor for gas leak detection
 * 
 * Hardware Requirements:
 * - ESP32 Development Board
 * - MQ-2, MQ-5, or MQ-6 Gas Sensor
 * - 10kΩ resistor (pull-down for analog reading)
 * - Breadboard and jumper wires
 * 
 * Wiring:
 * - MQ Sensor VCC -> ESP32 3.3V
 * - MQ Sensor GND -> ESP32 GND
 * - MQ Sensor A0 (Analog) -> ESP32 GPIO 34 (ADC1_CH6)
 * - MQ Sensor D0 (Digital) -> ESP32 GPIO 32 (optional)
 */

#include <WiFi.h>
#include <HTTPClient.h>
#include <ArduinoJson.h>
#include <WiFiClientSecure.h>

// WiFi Configuration
const char* ssid = "name";
const char* password = "11111111";

// API Configuration
const char* apiBaseUrl = "https://gas-monitor-sfk3.onrender.com/api";
const char* authToken = "YOUR_AUTH_TOKEN_HERE"; // Replace with actual token
const int sensorId = 1; // Replace with your sensor ID from backend

// Hardware Configuration
const int MQ_ANALOG_PIN = 34;  // ADC1_CH6
const int MQ_DIGITAL_PIN = 32; // Digital output (optional)
const int LED_PIN = 2;         // Built-in LED for status indication
const int BUZZER_PIN = 25;     // Optional buzzer for local alerts

// Sensor Configuration
const float TANK_CAPACITY = 20.0; // kg (matches backend)
const int GAS_THRESHOLD = 300;     // Analog threshold for gas detection
const int READING_INTERVAL = 30000; // 30 seconds between readings
const int ALERT_INTERVAL = 5000;   // 5 seconds between alerts when gas detected

// Global Variables
unsigned long lastReading = 0;
unsigned long lastAlert = 0;
bool gasDetected = false;
bool wifiConnected = false;
float currentGasLevel = 20.0; // Start with full tank

void setup() {
  Serial.begin(115200);
  delay(1000);
  
  Serial.println("=== ESP32 Gas Monitor System ===");
  
  // Initialize pins
  pinMode(MQ_ANALOG_PIN, INPUT);
  pinMode(MQ_DIGITAL_PIN, INPUT);
  pinMode(LED_PIN, OUTPUT);
  pinMode(BUZZER_PIN, OUTPUT);
  
  // Initialize LED and buzzer
  digitalWrite(LED_PIN, LOW);
  digitalWrite(BUZZER_PIN, LOW);
  
  // Connect to WiFi
  connectToWiFi();
  
  // Initial sensor warm-up
  Serial.println("Warming up gas sensor...");
  for(int i = 0; i < 30; i++) {
    digitalWrite(LED_PIN, HIGH);
    delay(500);
    digitalWrite(LED_PIN, LOW);
    delay(500);
    Serial.print(".");
  }
  Serial.println("\nSensor ready!");
  
  // Send initial reading
  sendGasReading(currentGasLevel, false);
}

void loop() {
  // Check WiFi connection
  if(WiFi.status() != WL_CONNECTED) {
    wifiConnected = false;
    digitalWrite(LED_PIN, LOW);
    connectToWiFi();
  } else {
    wifiConnected = true;
  }
  
  // Read gas sensor
  int analogValue = analogRead(MQ_ANALOG_PIN);
  int digitalValue = digitalRead(MQ_DIGITAL_PIN);
  
  // Convert analog reading to gas level (simplified simulation)
  // In real implementation, you'd calibrate this based on your specific sensor
  bool currentGasDetected = (analogValue > GAS_THRESHOLD) || (digitalValue == HIGH);
  
  // Simulate gas consumption over time (for demo purposes)
  // In real implementation, you'd calculate based on actual sensor readings
  simulateGasConsumption();
  
  // Check for gas leak detection
  if(currentGasDetected && !gasDetected) {
    gasDetected = true;
    Serial.println("⚠️  GAS LEAK DETECTED!");
    triggerLocalAlert();
    
    // Send immediate alert
    sendGasReading(currentGasLevel, true);
  } else if(!currentGasDetected && gasDetected) {
    gasDetected = false;
    Serial.println("✅ Gas levels normal");
    stopLocalAlert();
  }
  
  // Send periodic readings
  unsigned long currentTime = millis();
  if(currentTime - lastReading >= READING_INTERVAL) {
    sendGasReading(currentGasLevel, gasDetected);
    lastReading = currentTime;
  }
  
  // Handle continuous alerts
  if(gasDetected && (currentTime - lastAlert >= ALERT_INTERVAL)) {
    triggerLocalAlert();
    lastAlert = currentTime;
  }
  
  // Status LED blink
  if(wifiConnected) {
    digitalWrite(LED_PIN, HIGH);
    delay(100);
    digitalWrite(LED_PIN, LOW);
  }
  
  delay(1000); // Main loop delay
}

void connectToWiFi() {
  Serial.print("Connecting to WiFi: ");
  Serial.println(ssid);
  
  WiFi.begin(ssid, password);
  
  int attempts = 0;
  while(WiFi.status() != WL_CONNECTED && attempts < 20) {
    delay(1000);
    Serial.print(".");
    attempts++;
  }
  
  if(WiFi.status() == WL_CONNECTED) {
    wifiConnected = true;
    Serial.println();
    Serial.println("✅ WiFi Connected!");
    Serial.print("IP Address: ");
    Serial.println(WiFi.localIP());
    Serial.print("Signal Strength: ");
    Serial.print(WiFi.RSSI());
    Serial.println(" dBm");
  } else {
    wifiConnected = false;
    Serial.println();
    Serial.println("❌ WiFi Connection Failed!");
  }
}

void sendGasReading(float gasLevel, bool isAlert) {
  if(!wifiConnected) {
    Serial.println("❌ Cannot send reading - WiFi not connected");
    return;
  }
  
  WiFiClientSecure client;
  client.setInsecure(); // For development only - use proper certificates in production
  
  HTTPClient http;
  http.begin(client, String(apiBaseUrl) + "/gas-readings/create/");
  
  // Set headers
  http.addHeader("Content-Type", "application/json");
  http.addHeader("Authorization", String("Token ") + authToken);
  
  // Create JSON payload
  DynamicJsonDocument doc(1024);
  doc["sensor"] = sensorId;
  doc["remaining_gas"] = gasLevel;
  doc["reading_timestamp"] = getCurrentTimestamp();
  
  String jsonString;
  serializeJson(doc, jsonString);
  
  Serial.println("📡 Sending gas reading...");
  Serial.println("Payload: " + jsonString);
  
  // Send POST request
  int httpResponseCode = http.POST(jsonString);
  
  if(httpResponseCode > 0) {
    String response = http.getString();
    Serial.print("✅ HTTP Response: ");
    Serial.println(httpResponseCode);
    Serial.println("Response: " + response);
    
    if(httpResponseCode == 201) {
      Serial.println("✅ Gas reading sent successfully!");
      
      // Parse response to check if alert was triggered
      DynamicJsonDocument responseDoc(1024);
      deserializeJson(responseDoc, response);
      
      if(responseDoc["is_alert_triggered"].as<bool>()) {
        Serial.println("🚨 BACKEND ALERT TRIGGERED - Low gas level!");
      }
    }
  } else {
    Serial.print("❌ HTTP Error: ");
    Serial.println(httpResponseCode);
    Serial.println("Error: " + http.errorToString(httpResponseCode));
  }
  
  http.end();
}

void simulateGasConsumption() {
  // Simulate gradual gas consumption (for demo purposes)
  // In real implementation, you'd calculate based on actual sensor readings
  static unsigned long lastConsumption = 0;
  unsigned long currentTime = millis();
  
  if(currentTime - lastConsumption >= 60000) { // Every minute
    currentGasLevel -= 0.01; // Consume 0.01kg per minute
    if(currentGasLevel < 0) currentGasLevel = 0;
    lastConsumption = currentTime;
    
    Serial.print("💧 Current gas level: ");
    Serial.print(currentGasLevel);
    Serial.print("kg (");
    Serial.print((currentGasLevel / TANK_CAPACITY) * 100);
    Serial.println("%)");
  }
}

void triggerLocalAlert() {
  // Visual alert
  for(int i = 0; i < 5; i++) {
    digitalWrite(LED_PIN, HIGH);
    delay(100);
    digitalWrite(LED_PIN, LOW);
    delay(100);
  }
  
  // Audio alert (if buzzer connected)
  for(int i = 0; i < 3; i++) {
    digitalWrite(BUZZER_PIN, HIGH);
    delay(200);
    digitalWrite(BUZZER_PIN, LOW);
    delay(200);
  }
}

void stopLocalAlert() {
  digitalWrite(LED_PIN, LOW);
  digitalWrite(BUZZER_PIN, LOW);
}

String getCurrentTimestamp() {
  // Simple timestamp - in production, use NTP for accurate time
  return String(millis());
}

void printSensorInfo() {
  Serial.println("=== Sensor Information ===");
  Serial.print("Analog Reading: ");
  Serial.println(analogRead(MQ_ANALOG_PIN));
  Serial.print("Digital Reading: ");
  Serial.println(digitalRead(MQ_DIGITAL_PIN));
  Serial.print("Gas Level: ");
  Serial.print(currentGasLevel);
  Serial.println("kg");
  Serial.print("WiFi Status: ");
  Serial.println(wifiConnected ? "Connected" : "Disconnected");
  Serial.println("========================");
}
