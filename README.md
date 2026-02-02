# QuantIOS - Native Mobile Trading Companion 📱

![Platform](https://img.shields.io/badge/Platform-iOS-lightgrey?style=for-the-badge&logo=apple)
![Swift](https://img.shields.io/badge/Swift-5.0-orange?style=for-the-badge&logo=swift)
![SwiftUI](https://img.shields.io/badge/Framework-SwiftUI-blue?style=for-the-badge)
![Status](https://img.shields.io/badge/Status-Beta-yellow?style=for-the-badge)

**QuantIOS** is a native iOS application built entirely with **SwiftUI**, designed to provide on-the-go monitoring for the QuantWeb ecosystem. It connects seamlessly to the QuantWeb Python backend to visualize real-time asset prices, monitor active trading bots, and review portfolio performance directly from your iPhone.

## 🌟 Key Features

* **Live Watchlist:** Real-time price updates for crypto assets (BTC, ETH, SOL) fetched from the central API.
* **Interactive Mobile Charts:** Native candlestick charting optimized for touch interfaces.
* **Bot Monitoring:** View the status (Active/Idle) of your running algorithms.
* **Seamless Integration:** Utilizes `URLSession` and `Combine` for efficient networking with the FastAPI backend.

## 🛠️ Tech Stack

* **Language:** Swift
* **UI Framework:** SwiftUI
* **Architecture:** MVVM (Model-View-ViewModel)
* **Networking:** REST API Integration (Consuming QuantWeb Endpoints)

---

## 🚀 How to Run

### Prerequisites
* Mac with **Xcode 14+** installed.
* **QuantWeb Backend** running locally (or deployed).

### Step-by-Step Guide

1.  **Ensure the Backend is Running:**
    The app requires the API to fetch data. Make sure your Python FastAPI server is running (usually on port `8000`).

2.  **Open Project in Xcode:**
    Double-click on `QuantTradeiOS.xcodeproj`.

3.  **Configure API Endpoint:**
    * Navigate to `QuantTradeiOS/APIService.swift` (or where your URL constant is defined).
    * Update the `baseURL` variable.
    * *Important:* If running on a Simulator, `http://127.0.0.1:8000` works. If running on a physical iPhone, use your Mac's Local IP address (e.g., `http://192.168.1.5:8000`).

4.  **Build and Run:**
    * Select your target simulator (e.g., iPhone 15 Pro).
    * Press `Cmd + R` or click the Play button.

---

## 📸 Screenshots

*(Place your screenshots here)*

## 👤 Author

**Raflyandi Alviansyah**
