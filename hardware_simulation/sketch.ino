/*
 * ==============================================================================
 * Green Flow - Smart Agriculture & Precision Irrigation IoT Firmware
 * Target Microcontroller: ESP32 DevKit V4
 *
 * Hardware Pin Connections:
 *   1. DHT22 Sensor (Temperature & Humidity)  : DATA -> GPIO 15, VCC -> 3.3V, GND -> GND
 *   2. Potentiometer (Soil Moisture Sensor)   : SIG  -> GPIO 34 (ADC1), VCC -> 3.3V, GND -> GND
 *   3. 5V Relay Module (Water Pump Switch)    : IN   -> GPIO 23, VCC -> 5V, GND -> GND
 *   4. Indicator LED (Submersible Pump)       : COM  -> 5V, NO -> 220Ω Resistor -> LED Anode -> Cathode -> GND
 *
 * Control Logic:
 *   - Automatic Mode (Threshold-Governed):
 *       Soil Moisture < 30.0%  --> Close Relay (Turn Water Pump ON 💦)
 *       Soil Moisture >= 60.0% --> Open Relay  (Turn Water Pump OFF ⏸️)
 *   - Manual Mode (Operator Remote Override):
 *       Pump is controlled strictly via manual commands received from Firebase Realtime Database.
 *   - Telemetry Sync:
 *       Sensor readings and pump state sent to Firebase via HTTPS REST every 3 seconds.
 * ==============================================================================
 */

#include <WiFi.h>
#include <WiFiClientSecure.h>
#include <HTTPClient.h>
#include <DHT.h>
#include <ArduinoJson.h>

// Wi-Fi Credentials for Wokwi Simulation / Local Gateway AP
const char* WIFI_SSID = "Wokwi-GUEST";
const char* WIFI_PASSWORD = "";

// ==============================================================================
// FIREBASE REALTIME DATABASE CONFIGURATION
// (Set your actual Firebase Database URL or leave as is for local autonomous mode)
// ==============================================================================
const char* FIREBASE_HOST = "https://YOUR_PROJECT_ID-default-rtdb.firebaseio.com";
const char* FIREBASE_AUTH = ""; // Leave empty if read/write rules are public, or enter database secret
const char* FARM_ID = "farm_1";
const char* DEVICE_ID = "dev_1";

// Hardware Pin Definitions
#define DHT_PIN 15
#define DHT_TYPE DHT22
#define SOIL_PIN 34
#define RELAY_PIN 23

// Soil Moisture Thresholds for Automatic Irrigation
const float THRESHOLD_LOW = 30.0;   // Pump turns ON below 30%
const float THRESHOLD_HIGH = 60.0;  // Pump turns OFF at or above 60%

// Timing Intervals
const unsigned long TELEMETRY_INTERVAL_MS = 3000; // 3 seconds
unsigned long lastTelemetryTime = 0;

// System States
bool relayState = false; // true = Pump ON (Relay Closed), false = Pump OFF (Relay Open)
bool autoMode = true;    // true = Automatic Smart Irrigation, false = Manual Control

DHT dht(DHT_PIN, DHT_TYPE);

// Helper: Check if placeholder credentials are in use
bool isPlaceholderConfig() {
  return (strstr(FIREBASE_HOST, "YOUR_PROJECT_ID") != nullptr ||
          strstr(FIREBASE_HOST, "green-flow-smart-agriculture") != nullptr);
}

void setRelay(bool state, const char* reason) {
  if (relayState != state) {
    relayState = state;
    digitalWrite(RELAY_PIN, relayState ? HIGH : LOW);

    Serial.println("=================================================");
    Serial.print("[PUMP RELAY CHANGED] New State: ");
    Serial.print(relayState ? "RUNNING (ON 💦)" : "STOPPED (OFF ⏸️)");
    Serial.print(" | Reason: ");
    Serial.println(reason);
    Serial.println("=================================================");
  }
}

void printSerialDiagnostics(float temp, float hum, float soil) {
  Serial.println("-------------------------------------------------");
  Serial.println("  [Green Flow IoT Node Telemetry - Every 3s]     ");
  Serial.print("  Soil Moisture : ");
  Serial.print(soil, 1);
  Serial.print("% ");
  if (soil < THRESHOLD_LOW) {
    Serial.println("(DRY - Needs Water 🚨)");
  } else if (soil >= THRESHOLD_HIGH) {
    Serial.println("(OPTIMAL / MOIST ✅)");
  } else {
    Serial.println("(NORMAL 🌿)");
  }

  Serial.print("  Temperature   : ");
  Serial.print(temp, 1);
  Serial.println(" °C");

  Serial.print("  Air Humidity  : ");
  Serial.print(hum, 1);
  Serial.println(" %");

  Serial.print("  Pump Relay    : ");
  Serial.println(relayState ? "ACTIVE [ON 💦] (GPIO 23)" : "STANDBY [OFF ⏸️] (GPIO 23)");

  Serial.print("  Control Mode  : ");
  Serial.println(autoMode ? "AUTOMATIC (Threshold Governed)" : "MANUAL (Cloud Remote Override)");
  Serial.println("-------------------------------------------------");
}

void sendTelemetryToFirebase(float temp, float hum, float soil) {
  WiFiClientSecure client;
  client.setInsecure(); // Required for ESP32 HTTPS REST without bundled root CA

  HTTPClient https;
  String host = String(FIREBASE_HOST);
  if (host.endsWith("/")) {
    host = host.substring(0, host.length() - 1);
  }

  String url = host + "/telemetry/" + FARM_ID + "/" + DEVICE_ID + ".json";
  if (strlen(FIREBASE_AUTH) > 0 && strstr(FIREBASE_AUTH, "YOUR_") == nullptr) {
    url += "?auth=" + String(FIREBASE_AUTH);
  }

  if (https.begin(client, url)) {
    https.addHeader("Content-Type", "application/json");

    StaticJsonDocument<256> doc;
    doc["soilMoisture"] = round(soil * 10) / 10.0;
    doc["temperature"] = round(temp * 10) / 10.0;
    doc["humidity"] = round(hum * 10) / 10.0;
    doc["pumpStatus"] = relayState;
    doc["autoMode"] = autoMode;
    doc["deviceStatus"] = "online";
    doc["timestamp"] = millis();

    String requestBody;
    serializeJson(doc, requestBody);

    int httpResponseCode = https.PUT(requestBody);
    if (httpResponseCode > 0) {
      Serial.print("[Cloud Sync] Telemetry sent successfully. HTTP Code: ");
      Serial.println(httpResponseCode);
    } else {
      Serial.print("[Cloud Sync] Telemetry send failed. Error: ");
      Serial.println(https.errorToString(httpResponseCode));
    }
    https.end();
  }
}

void fetchManualCommandsFromFirebase() {
  WiFiClientSecure client;
  client.setInsecure();

  HTTPClient https;
  String host = String(FIREBASE_HOST);
  if (host.endsWith("/")) {
    host = host.substring(0, host.length() - 1);
  }

  String url = host + "/control/" + FARM_ID + "/" + DEVICE_ID + ".json";
  if (strlen(FIREBASE_AUTH) > 0 && strstr(FIREBASE_AUTH, "YOUR_") == nullptr) {
    url += "?auth=" + String(FIREBASE_AUTH);
  }

  if (https.begin(client, url)) {
    int httpResponseCode = https.GET();
    if (httpResponseCode == HTTP_CODE_OK) {
      String response = https.getString();
      StaticJsonDocument<256> doc;
      DeserializationError error = deserializeJson(doc, response);

      if (!error && !doc.isNull()) {
        // Update Auto / Manual mode
        if (doc.containsKey("autoMode")) {
          bool newAuto = doc["autoMode"].as<bool>();
          if (newAuto != autoMode) {
            autoMode = newAuto;
            Serial.print("[Cloud Command] Mode changed to: ");
            Serial.println(autoMode ? "AUTOMATIC" : "MANUAL");
          }
        }

        // In Manual mode: follow pump command
        if (!autoMode) {
          bool newPumpState = relayState;
          if (doc.containsKey("pumpCommand")) {
            String cmd = doc["pumpCommand"].as<String>();
            newPumpState = (cmd.equalsIgnoreCase("ON") || cmd.equalsIgnoreCase("TRUE") || cmd == "1");
          } else if (doc.containsKey("pumpStatus")) {
            newPumpState = doc["pumpStatus"].as<bool>();
          }
          setRelay(newPumpState, "Manual Remote Command from Firebase");
        }
      }
    }
    https.end();
  }
}

void setup() {
  Serial.begin(115200);
  delay(1000);

  Serial.println("\n*************************************************");
  Serial.println("  Green Flow - Smart Irrigation IoT Node (ESP32)  ");
  Serial.println("*************************************************");

  // Configure Pins
  pinMode(RELAY_PIN, OUTPUT);
  digitalWrite(RELAY_PIN, LOW); // Safe default: Pump OFF
  relayState = false;

  pinMode(SOIL_PIN, INPUT);

  // Initialize Sensors
  dht.begin();
  Serial.println("[Hardware] DHT22 sensor initialized on GPIO 15.");
  Serial.println("[Hardware] Soil moisture potentiometer on GPIO 34 (ADC1).");
  Serial.println("[Hardware] Pump relay initialized on GPIO 23 (Active HIGH).");

  // Connect to Wi-Fi
  Serial.print("[Wi-Fi] Connecting to: ");
  Serial.println(WIFI_SSID);
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);

  int attempts = 0;
  while (WiFi.status() != WL_CONNECTED && attempts < 20) {
    delay(500);
    Serial.print(".");
    attempts++;
  }

  if (WiFi.status() == WL_CONNECTED) {
    Serial.println("\n[Wi-Fi] Connected successfully!");
    Serial.print("[Wi-Fi] IP Address: ");
    Serial.println(WiFi.localIP());
  } else {
    Serial.println("\n[Wi-Fi] Not connected. Running in autonomous offline mode.");
  }

  if (isPlaceholderConfig()) {
    Serial.println("[Notice] Running in Autonomous Smart Irrigation mode (<30% ON, >=60% OFF).");
    Serial.println("         To enable live Firebase sync, set your database URL in FIREBASE_HOST.");
  }
}

void loop() {
  unsigned long currentMillis = millis();

  // 1. Read Soil Moisture (12-bit ADC: 0 to 4095 mapped to 0% to 100%)
  int rawAnalog = analogRead(SOIL_PIN);
  float soilMoisture = (rawAnalog / 4095.0) * 100.0;

  // 2. Read Ambient Temperature and Humidity from DHT22
  float temperature = dht.readTemperature();
  float humidity = dht.readHumidity();

  if (isnan(temperature)) temperature = 28.0; // fallback if sensor read fails
  if (isnan(humidity)) humidity = 55.0;

  // 3. Evaluate Irrigation Logic
  if (autoMode) {
    // AUTOMATIC MODE: Strictly governed by thresholds
    if (soilMoisture < THRESHOLD_LOW) {
      setRelay(true, "Automatic Mode: Soil Moisture < 30.0%");
    } else if (soilMoisture >= THRESHOLD_HIGH) {
      setRelay(false, "Automatic Mode: Soil Moisture >= 60.0%");
    }
  } else {
    // MANUAL MODE: Emergency drought protection override (<30% ON, >=60% OFF)
    if (soilMoisture < THRESHOLD_LOW && !relayState) {
      setRelay(true, "Manual Mode Emergency: Soil Moisture < 30.0% (Drought Protection)");
    } else if (soilMoisture >= THRESHOLD_HIGH && relayState) {
      setRelay(false, "Manual Mode Target Reached: Soil Moisture >= 60.0%");
    }
  }

  // 4. Periodic HTTPS REST Telemetry & Command Fetching (every 3 seconds)
  if (currentMillis - lastTelemetryTime >= TELEMETRY_INTERVAL_MS) {
    lastTelemetryTime = currentMillis;

    // Print Detailed Diagnostics to Serial Monitor
    printSerialDiagnostics(temperature, humidity, soilMoisture);

    // Synchronize with Firebase Realtime Database
    if (WiFi.status() == WL_CONNECTED && !isPlaceholderConfig()) {
      sendTelemetryToFirebase(temperature, humidity, soilMoisture);
      fetchManualCommandsFromFirebase();
    } else if (isPlaceholderConfig()) {
      Serial.println("[Telemetry Sync] Autonomous Local Mode (Smart Irrigation Active: <30% ON, >=60% OFF).");
    }
  }

  delay(150);
}
