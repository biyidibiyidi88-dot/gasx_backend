#include <WiFi.h>
#include <HTTPClient.h>
#include <ArduinoJson.h>

// WiFi credentials
const char* ssid = "name";
const char* password = "11111111";

// API Configuration
const char* apiBaseUrl = "https://gas-monitor-sfk3.onrender.com/api";
const char* authToken = "f86db4d9e988dc64c1cf5be6daef467807dbeade";

// Sensor Configuration
const int sensorId = 12; // The sensor ID we just created

// Pin definitions
const int ledPin = 2; // Built-in LED
const int buttonPin = 0; // Built-in button (GPIO 0)

void setup() {
  Serial.begin(115200);
  
  // Initialize pins
  pinMode(ledPin, OUTPUT);
  pinMode(buttonPin, INPUT_PULLUP);
  
  // Connect to WiFi
  WiFi.begin(ssid, password);
  Serial.print("Connecting to WiFi");
  
  while (WiFi.status() != WL_CONNECTED) {
    delay(1000);
    Serial.print(".");
    digitalWrite(ledPin, !digitalRead(ledPin)); // Blink LED while connecting
  }
  
  Serial.println();
  Serial.println("WiFi connected!");
  Serial.print("IP address: ");
  Serial.println(WiFi.localIP());
  
  // Turn on LED to indicate connection
  digitalWrite(ledPin, HIGH);
  
  Serial.println("ESP32 Gas Monitor Test Ready!");
  Serial.println("Press the button to send a critical gas alert");
  
  // Send initial critical alert for testing
  delay(2000);
  sendCriticalAlert();
}

void loop() {
  // Check button press for immediate critical alert
  if (digitalRead(buttonPin) == LOW) {
    Serial.println("Button pressed! Sending critical gas alert...");
    sendCriticalAlert();
    delay(2000); // Debounce delay
  }
  
  delay(100);
}

void sendCriticalAlert() {
  if (WiFi.status() == WL_CONNECTED) {
    HTTPClient http;
    http.begin(String(apiBaseUrl) + "/gas-readings/create/");
    http.addHeader("Content-Type", "application/json");
    http.addHeader("Authorization", "Token " + String(authToken));
    
    // Create critical gas reading (5% remaining - triggers alert)
    DynamicJsonDocument doc(1024);
    doc["sensor"] = sensorId;
    doc["remaining_gas"] = 1.0; // 1kg remaining out of 20kg = 5% (critical level)
    doc["timestamp"] = getCurrentTimestamp();
    doc["is_alert_triggered"] = true;
    
    String jsonString;
    serializeJson(doc, jsonString);
    
    Serial.println("\n=== SENDING CRITICAL GAS ALERT ===");
    Serial.println("Gas level is critical!");
    Serial.println("Remaining gas: 1.0kg (5%)");
    Serial.println("JSON Data: " + jsonString);
    Serial.println("====================================\n");
    
    int httpResponseCode = http.POST(jsonString);
    
    if (httpResponseCode > 0) {
      String response = http.getString();
      Serial.println("HTTP Response Code: " + String(httpResponseCode));
      Serial.println("Response: " + response);
      
      if (httpResponseCode == 201) {
        Serial.println("✅ CRITICAL GAS ALERT SENT SUCCESSFULLY!");
        Serial.println("Check your Gas Monitor app for the alert!");
        blinkLED(3, 500); // Blink 3 times slow for success
      } else {
        Serial.println("⚠️ Alert sent but got unexpected response code");
        blinkLED(5, 200); // Blink 5 times for warning
      }
    } else {
      Serial.println("❌ Error sending alert: " + String(httpResponseCode));
      blinkLED(10, 100); // Blink 10 times rapidly for error
    }
    
    http.end();
  } else {
    Serial.println("❌ WiFi not connected!");
  }
}



void blinkLED(int times, int delayMs) {
  for (int i = 0; i < times; i++) {
    digitalWrite(ledPin, LOW);
    delay(delayMs);
    digitalWrite(ledPin, HIGH);
    delay(delayMs);
  }
}

String getCurrentTimestamp() {
  // Simple timestamp - in production, use NTP for accurate time
  return String(millis() / 1000);
}


