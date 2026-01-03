import Foundation
import Combine

class APIService: ObservableObject {
    // PASTIKAN IP INI SESUAI DENGAN LAPTOP ANDA
    private let baseURL = "http://192.168.114.27:8000/api"
    
    @Published var watchlist: [WatchlistItem] = []
    @Published var chartData: [CandleData] = []
    @Published var equityData: [EquityPoint] = []
    @Published var metrics: TradeMetrics?
    @Published var comparisonMatrix: [StrategyComparison] = []
    @Published var scanResults: [ScanResult] = []
    @Published var tradeLogs: [TradeLog] = []
     
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // MARK: - 1. BACKTEST
    func runBacktest(symbol: String, strategy: String, tf: String, period: String) {
        self.isLoading = true
        let endpoint = "\(baseURL)/run-backtest"
        let body: [String: Any] = [
            "symbol": symbol, "strategy": strategy, "capital": 10000.0,
            "timeframe": tf.lowercased(), "period": period
        ]
        
        print("🚀 Requesting: \(endpoint)")
        
        postRequest(url: endpoint, body: body) { [weak self] (response: BacktestResponse?) in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let res = response {
                    self?.chartData = res.chart_data ?? []
                    self?.equityData = res.equity_curve ?? []
                    self?.metrics = res.metrics
                    
                    // Trigger Comparison setelah backtest sukses
                    self?.runComparison(symbol: symbol, tf: tf, period: period)
                } else {
                    self?.errorMessage = "Gagal memuat data backtest"
                    // Opsi: self?.loadDummyData() // Jika ingin fallback ke dummy
                }
            }
        }
    }
    
    func runComparison(symbol: String, tf: String, period: String) {
        let endpoint = "\(baseURL)/compare-strategies"
        let body: [String: Any] = ["symbol": symbol, "strategy": "MOMENTUM", "capital": 10000.0, "timeframe": tf.lowercased(), "period": period]
        
        postRequest(url: endpoint, body: body) { [weak self] (res: MatrixResponse?) in
            if let res = res {
                self?.comparisonMatrix = res.comparison ?? []
            }
        }
    }
    
    // MARK: - 2. SCANNER
    func runScanner(sector: String) {
        let endpoint = "\(baseURL)/scan-market"
        // Sesuaikan body dengan ScanRequest di Python
        let body: [String: Any] = ["sector": sector, "timeframe": "1d", "period": "1y", "capital": 10000.0]
        
        postRequest(url: endpoint, body: body) { [weak self] (results: [ScanResult]?) in
            if let results = results {
                self?.scanResults = results
            }
        }
    }
    
    // MARK: - 3. LOGS
    func fetchLogs() {
        getRequest(url: "\(baseURL)/logs") { [weak self] (logs: [TradeLog]?) in
            if let logs = logs {
                self?.tradeLogs = logs
            } else {
                print("⚠️ Logs kosong atau gagal decode")
            }
        }
    }
    
    // MARK: - 4. WATCHLIST
    func fetchWatchlist() {
        getRequest(url: "\(baseURL)/watchlist") { [weak self] (items: [WatchlistItem]?) in
            if let items = items { self?.watchlist = items }
        }
    }
    
    func addToWatchlist(symbol: String) {
        let endpoint = "\(baseURL)/watchlist"
        let body: [String: Any] = ["symbol": symbol, "mode": "AUTO"]
        postRequest(url: endpoint, body: body) { [weak self] (_: [WatchlistItem]?) in
            self?.fetchWatchlist()
        }
    }

    // MARK: - NETWORK HELPERS (DEBUG MODE)
    
    private func getRequest<T: Decodable>(url: String, completion: @escaping (T?) -> Void) {
        guard let urlObj = URL(string: url) else { completion(nil); return }
        
        URLSession.shared.dataTask(with: urlObj) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ GET Error: \(error.localizedDescription)")
                    completion(nil)
                    return
                }
                
                guard let data = data else { completion(nil); return }
                
                do {
                    let result = try JSONDecoder().decode(T.self, from: data)
                    completion(result)
                } catch {
                    print("❌ DECODE ERROR (\(url)): \(error)")
                    // PRINT RAW DATA UNTUK DEBUGGING
                    if let str = String(data: data, encoding: .utf8) {
                        print("📄 RAW RESPONSE: \(str)")
                    }
                    completion(nil)
                }
            }
        }.resume()
    }
    
    private func postRequest<T: Decodable>(url: String, body: [String: Any], completion: @escaping (T?) -> Void) {
        guard let urlObj = URL(string: url) else { completion(nil); return }
        
        var request = URLRequest(url: urlObj)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            print("❌ JSON Encode Error")
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ POST Error: \(error.localizedDescription)")
                    completion(nil)
                    return
                }
                
                guard let data = data else { completion(nil); return }
                
                // Cek status code
                if let httpResp = response as? HTTPURLResponse, httpResp.statusCode != 200 {
                    print("❌ Server Error: \(httpResp.statusCode)")
                    if let str = String(data: data, encoding: .utf8) { print("📄 ERR BODY: \(str)") }
                    completion(nil)
                    return
                }
                
                do {
                    let result = try JSONDecoder().decode(T.self, from: data)
                    completion(result)
                } catch {
                    print("❌ DECODE ERROR (\(url)): \(error)")
                    if let str = String(data: data, encoding: .utf8) {
                        // Batasi log jika terlalu panjang
                        print("📄 RAW RESPONSE (Prefix): \(str.prefix(500))...")
                    }
                    completion(nil)
                }
            }
        }.resume()
    }
}
