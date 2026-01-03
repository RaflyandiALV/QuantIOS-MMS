import Foundation

// MARK: - Core Data Models

struct CandleData: Identifiable, Codable {
    var id: UUID { UUID() }
    let time: Int
    let open: Double
    let high: Double
    let low: Double
    let close: Double
    
    var date: Date { Date(timeIntervalSince1970: TimeInterval(time)) }
}

struct WatchlistItem: Identifiable, Codable {
    var id: String { symbol }
    let symbol: String
    let mode: String?
    let strategy: String?
    let growth_pct: Double?
}

// MARK: - API Responses

struct BacktestResponse: Codable {
    let status: String?
    let chart_data: [CandleData]?
    let equity_curve: [EquityPoint]?
    let metrics: TradeMetrics?
    let comparison: [StrategyComparison]?
}

struct MatrixResponse: Codable {
    let symbol: String?
    let comparison: [StrategyComparison]?
}

struct EquityPoint: Identifiable, Codable {
    var id: Int { time }
    let time: Int
    let value: Double
}

// MEMBUAT SEMUA FIELD METRICS OPTIONAL AGAR TIDAK CRASH
struct TradeMetrics: Codable {
    let net_profit: Double?
    let win_rate: Double?
    let total_trades: Int?
    let sharpe_ratio: Double?
    let final_balance: Double?
    let max_drawdown: Double?
}

struct StrategyComparison: Identifiable, Codable {
    var id: String { strategy }
    let strategy: String
    let net_profit: Double?
    let win_rate: Double?
    let trades: Int?
}

struct ScanResult: Identifiable, Codable {
    var id: String { symbol }
    let symbol: String
    let sector: String?
    let recommended_strategy: String?
    let win_rate_est: Double?
    let net_profit: Double?     // Pastikan nama key sama dengan JSON backend
    let total_trades: Int?
    let score: Int?
}

struct TradeLog: Identifiable, Codable {
    let id: Int
    let time: Int
    let symbol: String
    let action: String
    let price: Double
    let qty: Double?
    let pnl: Double?
    let status: String?
    
    var dateFormatted: String {
        let date = Date(timeIntervalSince1970: TimeInterval(time))
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM HH:mm"
        return formatter.string(from: date)
    }
}
