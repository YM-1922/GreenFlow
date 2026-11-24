# Green Flow - Smart Irrigation IoT Simulation (ESP32 DevKit)

Complete hardware simulation circuit and Arduino C++ firmware for the **Green Flow** precision irrigation system, configured for the **Wokwi ESP32 Simulator**.

---

## 1. Hardware Pinout & Wiring Specifications

| Component | Pin / Terminal | ESP32 Connection | Description |
| :--- | :--- | :--- | :--- |
| **DHT22** | DATA (SDA) | **GPIO 15** | Digital temperature and air humidity readings |
| **DHT22** | VCC | **3.3V** | Power supply |
| **DHT22** | GND | **GND** | Ground |
| **Potentiometer** | Signal (SIG) | **GPIO 34 (ADC1)** | 12-bit ADC input simulating soil moisture (0–100%) |
| **Potentiometer** | VCC | **3.3V** | Voltage reference |
| **Potentiometer** | GND | **GND** | Ground reference |
| **Relay Module** | IN | **GPIO 23** | Digital control output for pump activation |
| **Relay Module** | VCC | **5V** | Relay coil power |
| **Relay Module** | GND | **GND** | Relay ground |
| **Pump Circuit** | COM | **5V** | Power to relay common switch |
| **Pump Circuit** | NO | **Resistor (220Ω)** | Normally Open switch output to LED anode |
| **Water Pump LED** | Cathode | **GND** | Ground return completing the circuit |

---

## 2. Firmware Features (`sketch.ino`)

1. **Precision Sensor Reading:**
   - Converts 12-bit analog input (`0` to `4095`) to a calibrated percentage `0.0% – 100.0%`.
   - Reads ambient temperature (°C) and relative humidity (%) from the DHT22.

2. **Automatic Irrigation Logic:**
   - **Threshold Low (< 30.0%):** Automatically activates the relay (`GPIO 23 -> HIGH`) and lights the pump LED.
   - **Threshold High (>= 60.0%):** Automatically cuts off the relay (`GPIO 23 -> LOW`) and turns off the pump LED.

3. **Remote Manual Control:**
   - Supports switching between **Automatic** and **Manual** modes via Firebase Realtime Database.
   - In manual mode, direct pump override commands (`ON` / `OFF`) from the cloud take precedence over the moisture threshold.

4. **HTTPS REST Telemetry Sync (Every 3 Seconds):**
   - Transmits JSON telemetry packages every 3000 ms to Firebase Realtime Database using secure HTTPS REST.
   - Handles connection state and informs user if running with placeholder credentials.

5. **Security & Placeholders:**
   - Uses placeholder constants (`FIREBASE_HOST` and `FIREBASE_AUTH`) with no invented credentials.
   - Guarded execution prevents false claims of cloud connectivity until valid credentials are provided and tested.

---

## 3. How to Run in Wokwi Simulator

1. Go to [https://wokwi.com](https://wokwi.com) and create a new **ESP32** project.
2. Replace `diagram.json` with the contents of [hardware_simulation/diagram.json](./diagram.json).
3. Replace the sketch code with the contents of [hardware_simulation/sketch.ino](./sketch.ino).
4. Add the libraries listed in [hardware_simulation/libraries.txt](./libraries.txt) (`DHT sensor library`, `ArduinoJson`, `Adafruit Unified Sensor`).
5. Click **Start Simulation (Play ▶️)**.
6. Open the **Serial Monitor** tab at 115200 baud to view real-time diagnostics.
