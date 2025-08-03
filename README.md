<!-- Banner image -->
<p align="center>
  <img src="assets/images/asthmaguard-logo.svg" alt="AsthmaGuard Logo" width="180"/>
</p>

<h1 align="center">AsthmaGuard</h1>

<p align="center">
  <b>Real-time Air Quality Monitoring & Asthma Management</b><br>
  <i>Cross-platform mobile app + custom Arduino hardware</i>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.x-blue?logo=flutter"/>
  <img src="https://img.shields.io/badge/Arduino-Nano%20BLE-green?logo=arduino"/>
  <img src="https://img.shields.io/badge/License-MIT-yellow"/>
</p>

---

## 🚀 Features

### <img src="https://img.icons8.com/color/48/000000/smartphone-tablet.png" width="24"/> Mobile App (Flutter)
- <b>Real-Time Sensor Data:</b> View live readings for <span style="color:#1976d2">PM1.0</span>, <span style="color:#388e3c">PM2.5</span>, <span style="color:#fbc02d">PM10</span>, temperature, humidity, and pressure.
- <b>Emergency Alerts:</b> Automatic notifications (<span style="color:#0288d1">info</span>, <span style="color:#fbc02d">warning</span>, <span style="color:#d32f2f">danger</span>) when thresholds are exceeded.
- <b>In-App Notification Center:</b> All alerts are logged and viewable in a dedicated notifications screen.
- <b>Medication & Symptom Tracking:</b> Log medication usage and asthma symptoms for better health management.
- <b>Health Reports & Tips:</b> Access personalized health reports and curated tips.
- <b>Modern UI:</b> Clean, responsive, and accessible design.
- <b>Bluetooth LE (BLE) Integration:</b> Seamless communication with custom hardware.

### <img src="https://img.icons8.com/color/48/000000/microchip.png" width="24"/> Hardware (Arduino Nano BLE)
- <b>Sensors:</b> PMS5003 (PM1.0, PM2.5, PM10), LPS22HB (temperature, pressure), and optional humidity sensor.
- <b>LCD Display:</b> Cycles through temperature, pressure, and particulate matter values every 3 seconds.
- <b>BLE Service:</b> Streams sensor data to the mobile app in real time.
- <b>Robust Error Handling:</b> Validates sensor data and BLE communication.

---

## 📱 Getting Started

### Prerequisites
- <img src="https://img.icons8.com/color/48/000000/flutter.png" width="20"/> [Flutter](https://flutter.dev/docs/get-started/install) (3.x recommended)
- <img src="https://img.icons8.com/color/48/000000/arduino.png" width="20"/> Arduino IDE (for hardware)
- Android Studio or Xcode (for mobile builds)

### Setup
1. <b>Clone the repository:</b>
   ```sh
   git clone https://github.com/KarikariSamuelZachary/asthmaguard.git
   cd asthmaguardv2
   ```
2. <b>Install dependencies:</b>
   ```sh
   flutter pub get
   ```
3. <b>Configure environment:</b>
   - Copy <code>.env.example</code> to <code>.env</code> and fill in your API keys and endpoints.
4. <b>Build and run:</b>
   - For Android: <code>flutter run</code> or <code>flutter build apk</code>
   - For iOS: <code>flutter run</code> (on Mac)

### Hardware
- Upload <code>bluetooth_connection_integrated.ino</code> to your Arduino Nano BLE.
- Connect PMS5003, LPS22HB, and LCD as per the wiring diagram (see <code>/hardware</code> or project docs).

<p align="center">
  <img src="assets/images/phone_alert.png" alt="Pollution Tracker" width="320"/>
  <img src="assets/images/wellness_journey_vector.jpg" alt="Health Report" width="320"/>
</p>

---

## 🛡️ Emergency Alert System
- Alerts are triggered based on real-time sensor thresholds.
- Three alert levels: <b style="color:#0288d1">Info</b>, <b style="color:#fbc02d">Warning</b>, <b style="color:#d32f2f">Danger</b> (with cooldown to prevent spam).
- Alerts appear both as system notifications and in the app's notification center.

---

## 📂 Project Structure
```text
mobile/                   # Flutter app source code
bluetooth_connection/      # Arduino firmware
assets/                    # Images and static assets
.env.example               # Environment variable template
README.md                  # Project documentation
```

---

## 🤝 Contributing
See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines. All contributions are welcome!

---

## 📄 License
This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.

---

## 🙏 Acknowledgements
- Flutter, Arduino, and the open-source community
- All contributors and testers

---
