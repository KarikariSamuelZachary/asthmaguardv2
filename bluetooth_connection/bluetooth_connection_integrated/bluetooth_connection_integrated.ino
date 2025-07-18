#include <ArduinoBLE.h>
#include <Arduino_LPS22HB.h>

#define BUFFER_SIZE 20

// Use standard-conforming UUIDs
BLEService sensorService("00000000-5EC4-4083-81CD-A10B8D5CF6EC");
BLECharacteristic tempChar("00000001-5EC4-4083-81CD-A10B8D5CF6EC", BLERead | BLENotify, BUFFER_SIZE, false);
BLECharacteristic pressureChar("00000002-5EC4-4083-81CD-A10B8D5CF6EC", BLERead | BLENotify, BUFFER_SIZE, false);
// Add new characteristics for PM2.5 and PM10
BLECharacteristic pm25Char("00000003-5EC4-4083-81CD-A10B8D5CF6EC", BLERead | BLENotify, BUFFER_SIZE, false);
BLECharacteristic pm10Char("00000004-5EC4-4083-81CD-A10B8D5CF6EC", BLERead | BLENotify, BUFFER_SIZE, false);

// Variables to track previous values
float oldTemperature = 0;
float oldPressure = 0;
int oldPM25 = 0;
int oldPM10 = 0;
long previousMillis = 0;
long previousPMSMillis = 0;

// Variables for PMS5003 readings
uint16_t pm1_0_ATM = 0;
uint16_t pm2_5_ATM = 0;
uint16_t pm10_ATM = 0;
bool newPMSData = false;

void setup() {
  Serial.begin(9600);
  Serial1.begin(9600);  // Hardware serial for PMS5003 (RX0/TX1)
  
  // Wait for serial monitor to open, but not in production
  // while (!Serial);
  
  Serial.println("Starting AsthmaGuard sensor hub...");
  Serial.println("Initializing PMS5003 air quality sensor...");

  if (!BLE.begin()) {
    Serial.println("Starting BLE failed!");
    while (1);
  }

  if (!BARO.begin()) {
    Serial.println("Failed to initialize LPS22HB!");
    while (1);
  }

  // Set both local name (for advertising) and device name (for connection)
  BLE.setLocalName("AsthmaGuard");
  BLE.setDeviceName("AsthmaGuard");
  BLE.setAdvertisedService(sensorService);

  // Add characteristics to service
  sensorService.addCharacteristic(tempChar);
  sensorService.addCharacteristic(pressureChar);
  sensorService.addCharacteristic(pm25Char);
  sensorService.addCharacteristic(pm10Char);
  BLE.addService(sensorService);

  // Initialize with default values
  tempChar.writeValue("0.0");
  pressureChar.writeValue("0.0");
  pm25Char.writeValue("0");
  pm10Char.writeValue("0");

  // Start advertising
  BLE.advertise();
  Serial.println("BLE device is now advertising as 'AsthmaGuard'");
  
  // Initialize built-in LED to indicate connection status
  pinMode(LED_BUILTIN, OUTPUT);
}

void loop() {
  // Always check for PMS5003 data regardless of BLE connection
  readPMSdata();
  
  // Handle BLE connection
  BLEDevice central = BLE.central();
  if (central) {
    Serial.print("Connected to central: ");
    Serial.println(central.address());
    digitalWrite(LED_BUILTIN, HIGH); // Turn on LED when connected
    
    while (central.connected()) {
      // Always check for PMS5003 data
      readPMSdata();
      
      long currentMillis = millis();
      // Update BLE values every 200ms for responsive UI
      if (currentMillis - previousMillis >= 200) {
        previousMillis = currentMillis;
        updateSensorValues();
      }
    }
    
    digitalWrite(LED_BUILTIN, LOW); // Turn off LED when disconnected
    Serial.println("Disconnected from central");
  }
}

// Function to read data from PMS5003 sensor
void readPMSdata() {
  long currentMillis = millis();
  
  // Only attempt to read PMS data every 1 second to avoid overwhelming Serial1
  if (currentMillis - previousPMSMillis < 1000) {
    return;
  }
  
  previousPMSMillis = currentMillis;
  
  if (Serial1.available() >= 32) {  // Wait until a full 32-byte frame is available
    if (Serial1.read() == 0x42 && Serial1.read() == 0x4D) {
      uint8_t buffer[30];
      Serial1.readBytes(buffer, 30);

      // Simple checksum validation
      uint16_t checksum = 0x42 + 0x4D;
      for (int i = 0; i < 28; i++) {
        checksum += buffer[i];
      }
      
      uint16_t receivedChecksum = (buffer[28] << 8) | buffer[29];
      
      if (checksum == receivedChecksum) {
        // Parse the data
        pm1_0_ATM  = (buffer[6] << 8) | buffer[7];
        pm2_5_ATM  = (buffer[8] << 8) | buffer[9];
        pm10_ATM   = (buffer[10] << 8) | buffer[11];
        
        newPMSData = true;
        
        Serial.print("PM1.0: ");
        Serial.print(pm1_0_ATM);
        Serial.print(" µg/m³, PM2.5: ");
        Serial.print(pm2_5_ATM);
        Serial.print(" µg/m³, PM10: ");
        Serial.print(pm10_ATM);
        Serial.println(" µg/m³");
      } else {
        Serial.println("PMS5003 checksum error");
      }
    }
  }
}

// Separate function to update sensor values for BLE
void updateSensorValues() {
  // Update temperature and pressure from LPS22HB sensor
  float temperature = BARO.readTemperature();
  float pressure = BARO.readPressure();

  // Only update if values have changed (reduces BLE traffic)
  if (temperature != oldTemperature) {
    char tempBuffer[BUFFER_SIZE];
    int ret = snprintf(tempBuffer, sizeof tempBuffer, "%.2f", temperature);
    if (ret >= 0) {
      tempChar.writeValue(tempBuffer);
      oldTemperature = temperature;
      Serial.print("Temperature: ");
      Serial.print(tempBuffer);
      Serial.println(" °C");
    }
  }

  if (pressure != oldPressure) {
    char pressureBuffer[BUFFER_SIZE];
    int ret = snprintf(pressureBuffer, sizeof pressureBuffer, "%.2f", pressure);
    if (ret >= 0) {
      pressureChar.writeValue(pressureBuffer);
      oldPressure = pressure;
      Serial.print("Pressure: ");
      Serial.print(pressureBuffer);
      Serial.println(" hPa");
    }
  }
  
  // Update PM2.5 and PM10 values if we have new data
  if (newPMSData) {
    if (pm2_5_ATM != oldPM25) {
      char pm25Buffer[BUFFER_SIZE];
      int ret = snprintf(pm25Buffer, sizeof pm25Buffer, "%d", pm2_5_ATM);
      if (ret >= 0) {
        pm25Char.writeValue(pm25Buffer);
        oldPM25 = pm2_5_ATM;
      }
    }
    
    if (pm10_ATM != oldPM10) {
      char pm10Buffer[BUFFER_SIZE];
      int ret = snprintf(pm10Buffer, sizeof pm10Buffer, "%d", pm10_ATM);
      if (ret >= 0) {
        pm10Char.writeValue(pm10Buffer);
        oldPM10 = pm10_ATM;
      }
    }
    
    newPMSData = false;
  }
}
