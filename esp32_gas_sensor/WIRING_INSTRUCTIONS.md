# ESP32 Gas Sensor Wiring Instructions

## Components Required

### Main Components
- **ESP32 Development Board** (ESP32-WROOM-32 or similar)
- **MQ Gas Sensor** (MQ-2, MQ-5, or MQ-6 recommended)
  - MQ-2: Detects LPG, propane, hydrogen, methane, smoke
  - MQ-5: Specifically for LPG, natural gas, town gas
  - MQ-6: Specifically for LPG, butane gas
- **Breadboard** (830 points recommended)
- **Jumper Wires** (Male-to-Male and Male-to-Female)

### Status Indicators
- **3x LEDs**: Green (normal), Yellow (warning), Red (critical)
- **3x 220Ω Resistors** (for LEDs)
- **1x Buzzer** (5V active buzzer)

### Power Supply
- **USB Cable** (for ESP32 power and programming)
- **External 5V Power Supply** (optional, for standalone operation)

## Wiring Diagram

```
ESP32 Pin Layout:
                    ┌─────────────────┐
                    │      ESP32      │
                    │                 │
              3V3 ──┤ 3V3         GND ├── GND
              GND ──┤ GND         D23 ├── 
                 ──┤ D0          D22 ├── 
                 ──┤ D1          TXD ├── 
                 ──┤ D2          RXD ├── 
                 ──┤ D3          D21 ├── BUZZER_PIN
                 ──┤ D4          D19 ├── LED_CRITICAL_PIN (Red)
              LED ──┤ D5          D18 ├── LED_WARNING_PIN (Yellow)
                 ──┤ D6          D5  ├── LED_NORMAL_PIN (Green)
                 ──┤ D7          TXD ├── 
                 ──┤ D8          RXD ├── 
                 ──┤ D9          D4  ├── 
                 ──┤ D10         D0  ├── 
                 ──┤ D11         D2  ├── MQ_DIGITAL_PIN
                 ──┤ D12         D15 ├── 
                 ──┤ D13         D13 ├── 
                 ──┤ D14         D12 ├── 
                 ──┤ D15         D14 ├── 
                 ──┤ D16         D27 ├── 
                 ──┤ D17         D26 ├── 
                 ──┤ D18         D25 ├── 
                 ──┤ D19         D33 ├── 
                 ──┤ D21         D32 ├── 
                 ──┤ RXD         D35 ├── 
                 ──┤ TXD         D34 ├── 
                 ──┤ D22         VN  ├── 
                 ──┤ D23         VP  ├── 
                    │                 │
              A0 ──┤ A0 (GPIO36)      ├── MQ_SENSOR_PIN (Analog)
                    └─────────────────┘
```

## Step-by-Step Wiring

### 1. MQ Gas Sensor Connections
```
MQ Sensor → ESP32
VCC       → 5V (or 3.3V)
GND       → GND
A0        → GPIO36 (A0) - Analog output
D0        → GPIO2      - Digital output
```

### 2. LED Status Indicators
```
Green LED (Normal Status):
LED Anode  → GPIO5 (through 220Ω resistor)
LED Cathode → GND

Yellow LED (Warning Status):
LED Anode  → GPIO18 (through 220Ω resistor)
LED Cathode → GND

Red LED (Critical Status):
LED Anode  → GPIO19 (through 220Ω resistor)
LED Cathode → GND
```

### 3. Buzzer Connection
```
Buzzer Positive → GPIO21
Buzzer Negative → GND
```

### 4. Power Connections
```
ESP32 VIN → 5V (if using external power)
ESP32 GND → GND (common ground for all components)
ESP32 3.3V → Can be used for low-power sensors
```

## Breadboard Layout

```
Breadboard Layout (Top View):
     A  B  C  D  E     F  G  H  I  J
  1  +  +  +  +  +     +  +  +  +  +
  2  -  -  -  -  -     -  -  -  -  -
  3     [MQ Sensor]
  4     VCC GND A0 D0
  5      |   |   |  |
  6      |   |   |  └── GPIO2
  7      |   |   └───── GPIO36 (A0)
  8      |   └───────── GND Rail
  9      └───────────── 5V Rail
 10
 11  [Green LED] ──220Ω── GPIO5
 12  [Yellow LED] ─220Ω── GPIO18  
 13  [Red LED] ───220Ω── GPIO19
 14  [Buzzer] ─────────── GPIO21
 15
```

## Configuration Steps

### 1. Arduino IDE Setup
1. Install ESP32 board package:
   - File → Preferences → Additional Board Manager URLs
   - Add: `https://dl.espressif.com/dl/package_esp32_index.json`
   - Tools → Board → Boards Manager → Search "ESP32" → Install

2. Install required libraries:
   - Tools → Manage Libraries
   - Install: `ArduinoJson` by Benoit Blanchon
   - Install: `WiFi` (usually pre-installed)
   - Install: `HTTPClient` (usually pre-installed)

### 2. Code Configuration
Update these values in the Arduino code:

```cpp
// WiFi Configuration
const char* ssid = "YOUR_WIFI_SSID";           // Your WiFi network name
const char* password = "YOUR_WIFI_PASSWORD";   // Your WiFi password

// API Configuration  
const char* api_base_url = "http://192.168.1.100:8000/api";  // Your server IP
const char* auth_token = "972e4539789c26414553c450b2994111b7ebccae";  // Your auth token
const int sensor_id = 13;                     // Your sensor ID from database
```

### 3. Gas Sensor Calibration
The MQ sensors need calibration for accurate readings:

1. **Warm-up Period**: Let sensor run for 24-48 hours for best accuracy
2. **Clean Air Calibration**: Note the baseline reading in clean air
3. **Test Gas Calibration**: Use known gas concentrations to calibrate
4. **Adjust Thresholds**: Modify these values based on your testing:

```cpp
const int GAS_NORMAL_THRESHOLD = 300;     // Adjust based on baseline
const int GAS_WARNING_THRESHOLD = 800;    // Adjust based on testing
const int GAS_CRITICAL_THRESHOLD = 1500;  // Adjust based on safety requirements
```

## Testing Procedure

### 1. Initial Setup Test
1. Upload code to ESP32
2. Open Serial Monitor (115200 baud)
3. Verify WiFi connection
4. Check LED test sequence
5. Confirm sensor warm-up period

### 2. Sensor Response Test
1. Monitor baseline readings in clean air
2. Introduce small amount of test gas (lighter gas, cooking gas)
3. Verify readings increase appropriately
4. Check LED status changes
5. Confirm buzzer activation at critical levels

### 3. API Integration Test
1. Monitor Serial output for HTTP requests
2. Check backend logs for received data
3. Verify email notifications are sent
4. Confirm data appears in web dashboard

## Safety Considerations

⚠️ **IMPORTANT SAFETY NOTES:**

1. **Ventilation**: Always test in well-ventilated areas
2. **Fire Safety**: Keep away from open flames during gas testing
3. **Sensor Placement**: Install away from cooking areas to avoid false alarms
4. **Power Supply**: Use stable power supply for continuous operation
5. **Regular Calibration**: Recalibrate sensors every 6 months

## Troubleshooting

### Common Issues:

**WiFi Connection Problems:**
- Check SSID/password spelling
- Verify signal strength
- Try different WiFi channels

**Sensor Reading Issues:**
- Check wiring connections
- Verify power supply voltage
- Allow proper warm-up time
- Calibrate in clean air first

**API Communication Problems:**
- Verify server URL and port
- Check authentication token
- Confirm sensor ID exists in database
- Monitor network connectivity

**False Alarms:**
- Recalibrate sensor thresholds
- Check for cooking/cleaning chemical interference
- Verify sensor placement location

## Maintenance

### Regular Maintenance:
- **Monthly**: Check LED indicators and buzzer
- **Quarterly**: Clean sensor housing
- **Semi-annually**: Recalibrate thresholds
- **Annually**: Replace sensor if readings become unreliable

### Sensor Lifespan:
- MQ sensors typically last 2-5 years
- Performance may degrade over time
- Replace if baseline readings drift significantly
