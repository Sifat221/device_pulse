# Device Pulse 📱

A Flutter Android application that collects real-time device and health data and enables instant peer-to-peer sharing over the same Wi-Fi network using native platform capabilities.

---

## 🚀 Features

* 📊 Live device dashboard (real sensor data)
* 🔋 Battery monitoring (level, temperature, health)
* 👣 Step counter + Activity detection (Walking / Still)
* 📶 Wi-Fi info (SSID, RSSI, IP Address)
* 📡 Cellular info (Carrier, SIM state, Signal dBm)
* 📱 Device information (Model, Android version, name)
* 🔍 Automatic device discovery (NSD)
* 📤 One-tap data sharing over local Wi-Fi
* 📥 Receive and store data locally
* 💾 Persistent storage using Hive

---

## 🧠 Tech Stack

* Flutter (UI)
* Kotlin (Native Android)
* MethodChannel (Flutter ↔ Native)
* NSD (Network Service Discovery)
* TCP Socket (Data transfer)
* Hive (Local storage)

---

## 📱 User Flow

1. App launches → loads real-time device data
2. User taps **"Share My Pulse"**
3. App scans nearby devices automatically
4. Device list appears
5. User taps a device → sends data instantly
6. Receiver device stores data locally

---

## ⚙️ Requirements

* Android device (recommended for real sensor data)
* Same Wi-Fi network for both devices

---

## 📸 Screens

* Dashboard Screen (Live Data)
* Nearby Devices List
* Received Data Screen

---

## 🛠 Setup

```bash
flutter pub get
flutter run
```

---

## ⚠️ Notes

* Some data (carrier/signal) may not work properly on emulator
* Real device recommended for full functionality

---

## 📬 Submission

This project was built as part of a Flutter developer technical assessment.

---

