import SwiftUI
import Charts

// MARK: - Advanced Interactive Chart (TradingView Style)
struct FinancialCandleChart: View {
    let candles: [CandleData]
    let timeframe: String // Wajib tahu timeframe agar zoom pas
    
    // State untuk Zoom & Scroll
    @State private var visibleCandles: Double = 40 // Default 40 candle terlihat
    
    // Hitung detik per candle untuk skala X yang akurat
    var intervalSeconds: Double {
        switch timeframe.lowercased() {
        case "15m": return 900
        case "1h": return 3600
        case "4h": return 14400
        case "1d": return 86400
        default: return 86400
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // CHART UTAMA
            Chart {
                ForEach(candles) { candle in
                    let date = candle.date
                    
                    // Body (Open - Close)
                    BarMark(
                        x: .value("Time", date),
                        yStart: .value("Open", candle.open),
                        yEnd: .value("Close", candle.close),
                        width: .fixed(10) // Lebar fix agar tidak gepeng
                    )
                    .foregroundStyle(candle.close >= candle.open ? Theme.bull : Theme.bear)
                    
                    // Wick (High - Low)
                    RuleMark(
                        x: .value("Time", date),
                        yStart: .value("Low", candle.low),
                        yEnd: .value("High", candle.high)
                    )
                    .foregroundStyle(candle.close >= candle.open ? Theme.bull : Theme.bear)
                    .lineStyle(StrokeStyle(lineWidth: 1))
                }
            }
            .chartScrollableAxes(.horizontal) // Scroll Horizontal Aktif!
            // RUMUS AJAIB: Menentukan lebar scroll area berdasarkan jumlah candle visible * detik per candle
            .chartXVisibleDomain(length: intervalSeconds * visibleCandles)
            .chartYScale(domain: .automatic(includesZero: false))
            .chartXAxis {
                AxisMarks(values: .stride(by: .day, count: timeframe == "1d" ? 5 : 1)) { value in
                    AxisTick()
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [2, 4]))
                    AxisValueLabel(format: .dateTime.day().month(), centered: true)
                        .foregroundStyle(Color.gray)
                }
            }
            .chartYAxis {
                AxisMarks(position: .trailing) {
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                    AxisValueLabel().foregroundStyle(Color.white)
                }
            }
            .frame(height: 320)
            .background(Theme.cardBackground)
            .cornerRadius(12)
            .padding(.bottom, 4)
            
            // ZOOM CONTROLS (Manual Zoom karena gesture agak kompleks di SwiftUI Chart standar)
            HStack {
                Text("Zoom View:").font(.caption).foregroundColor(.gray)
                
                Button(action: { visibleCandles = min(visibleCandles + 10, 100) }) { // Zoom Out
                    Image(systemName: "minus.magnifyingglass")
                        .padding(6).background(Theme.cardBackground).cornerRadius(6)
                }
                
                Button(action: { visibleCandles = max(visibleCandles - 10, 10) }) { // Zoom In
                    Image(systemName: "plus.magnifyingglass")
                        .padding(6).background(Theme.cardBackground).cornerRadius(6)
                }
                
                Spacer()
                Text("\(Int(visibleCandles)) Bars").font(.caption).foregroundColor(.gray)
            }
            .foregroundColor(.white)
        }
    }
}

// MARK: - Equity Curve Chart (Fixed Scaling)
struct EquityLineChart: View {
    let data: [EquityPoint]
    
    var body: some View {
        // Ambil Min dan Max agar grafik "penuh" (tidak gepeng di atas)
        let minValue = data.map { $0.value }.min() ?? 0
        let maxValue = data.map { $0.value }.max() ?? 100
        
        Chart(data) { point in
            let date = Date(timeIntervalSince1970: TimeInterval(point.time))
            
            // Area Gradient
            AreaMark(
                x: .value("Time", date),
                yStart: .value("Base", minValue), // Mulai dari nilai terendah, bukan 0
                yEnd: .value("Equity", point.value)
            )
            .foregroundStyle(
                LinearGradient(
                    colors: [Theme.accent.opacity(0.3), Theme.accent.opacity(0.0)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            
            // Line Utama
            LineMark(
                x: .value("Time", date),
                y: .value("Equity", point.value)
            )
            .foregroundStyle(Theme.accent)
            .lineStyle(StrokeStyle(lineWidth: 2))
        }
        .chartYScale(domain: minValue...maxValue) // Skala dinamis
        .chartXAxis(.hidden)
        .chartYAxis(.hidden)
        .frame(height: 100)
        .background(Theme.cardBackground)
        .cornerRadius(12)
    }
}
