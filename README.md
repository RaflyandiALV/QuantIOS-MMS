# QuantIOS - Native Mobile Quantitative Analysis 📱

![Platform](https://img.shields.io/badge/Platform-iOS-000000?style=for-the-badge&logo=apple)
![Swift](https://img.shields.io/badge/Language-Swift_5-F05138?style=for-the-badge&logo=swift)
![SwiftUI](https://img.shields.io/badge/UI-SwiftUI-007AFF?style=for-the-badge&logo=swift)
![Architecture](https://img.shields.io/badge/Architecture-MVVM-purple?style=for-the-badge)

**QuantIOS** is a native iOS application designed for high-level quantitative trading analysis. It bridges complex Python-based trading logic (Backend) with a responsive, elegant mobile interface built in SwiftUI.

Unlike typical cloud-heavy systems, this project utilizes an efficient **File-Based Database Architecture (JSON & CSV)**, enabling fast local data processing and portable data structures.

---

## 📸 App Gallery

*(Please upload your 9 Portrait Screenshots here)*

<div align="center">
  <img src="https://placehold.co/300x600/png?text=1+Login" width="200" />
  <img src="https://placehold.co/300x600/png?text=2+Home" width="200" />
  <img src="https://placehold.co/300x600/png?text=3+Watchlist" width="200" />
  <img src="https://placehold.co/300x600/png?text=4+Chart+View" width="200" />
</div>
<br>
<div align="center">
  <img src="https://placehold.co/300x600/png?text=5+Strategy" width="200" />
  <img src="https://placehold.co/300x600/png?text=6+Logs" width="200" />
  <img src="https://placehold.co/300x600/png?text=7+Settings" width="200" />
  <img src="https://placehold.co/300x600/png?text=8+Metrics" width="200" />
  <img src="https://placehold.co/300x600/png?text=9+Profile" width="200" />
</div>

---

## 🛠️ Tech Stack

| Layer | Technology | Role |
| :--- | :--- | :--- |
| **Mobile Frontend** | **SwiftUI** | Modern, gesture-driven native iOS interface. |
| **Backend API** | **FastAPI (Python)** | REST API bridging market data to the iOS app. |
| **Database** | **JSON & CSV** | `watchlist.json` for config, `trades_log.csv` for history. |
| **Data Analysis** | **Pandas & Pandas_TA** | Calculating technical indicators (SMA, Bollinger Bands). |
| **Persistence** | **Core Data** | Offline storage for user sessions and preferences. |
| **Networking** | **URLSession** | Handling async data communication. |

---

## 🌟 Key Features

1.  **Real-time Watchlist:** Synchronizes favorite coins directly to `watchlist.json` on the server.
2.  **Technical Strategy Engine:** Executes Momentum, Mean Reversal, and Grid strategies via `strategy_core.py`.
3.  **iOS Native Charts:** Visualizes price action using Swift Charts and TradingView integration.
4.  **Trade Logging:** Auto-records every simulation into CSV files for long-term performance analysis.
5.  **Biometric Auth:** Secure access using native iOS FaceID/TouchID.

---

## 🏗️ System Architecture

1.  **Python Engine** fetches market data via Yahoo Finance API.
2.  Analysis results are stored in **JSON** and served via **FastAPI**.
3.  **Swift Frontend** fetches data via `APIService.swift`.
4.  Data is parsed into **Swift Models** (`Models.swift`) and rendered via **SwiftUI**.

---

## 📂 Database Structure (File-Based)

* `watchlist.json`: Stores strategy config per coin (Symbol, Mode, Timeframe).
* `trades_log.csv`: Records transaction details (Entry Price, TP, SL, PnL).
* `summary_metrics.json`: Stores cumulative statistics (Win Rate, Total Profit).

---

## 💻 How to Run

### A. Backend Setup (Python)
1.  Navigate to backend folder: `cd Quant-Backend/backend`
2.  Install dependencies:
    ```bash
    pip install -r requirements.txt
    ```
3.  **Run Local Server (Important):**
    ```bash
    python -m uvicorn main:app --reload --host 0.0.0.0 --port 8000
    ```
    > **Note:** Ensure your IPv4 address in `APIService.swift` matches your machine's local IP (check via `ipconfig` on Windows or `ifconfig` on Mac).

### B. Frontend Setup (iOS)
1.  Open `QuantTradeiOS.xcodeproj` in **Xcode**.
2.  Open `APIService.swift` and verify the `baseURL` matches your server's IP.
3.  Select a Simulator (e.g., iPhone 15) and press **Run (Cmd + R)**.

---

## ⚠️ Learning Outcomes & Troubleshooting

* **Data Parsing:** Successfully handled complex type conversion between Python Dictionaries and Swift Decodable Models.
* **Concurrency:** Managed asynchronous calls in iOS to ensure the UI remains buttery smooth while fetching heavy market data.
* **File Handling:** Engineered race-condition-safe JSON reading/writing mechanisms in the backend.

## 👤 Author
**Raflyandi Alviansyah**
