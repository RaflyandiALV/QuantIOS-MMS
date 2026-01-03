import SwiftUI
import Charts

// MARK: - ROOT VIEW (AUTH & NAVIGATION KEEPER)
struct ContentView: View {
    // Single Source of Truth untuk Data API
    @StateObject var apiService = APIService()
    
    // Status Login Persisten (disimpan di HP)
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false
    
    init() {
        // Konfigurasi Tampilan TabBar Global (Dark Mode Style)
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(red: 0.05, green: 0.05, blue: 0.05, alpha: 1) // Hampir hitam
        
        let itemAppearance = UITabBarItemAppearance()
        itemAppearance.normal.iconColor = UIColor.gray
        itemAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.gray]
        itemAppearance.selected.iconColor = UIColor.cyan
        itemAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.cyan]
        
        appearance.stackedLayoutAppearance = itemAppearance
        appearance.inlineLayoutAppearance = itemAppearance
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some View {
        // Logika Navigasi Utama
        if isLoggedIn {
            MainTabView(isLoggedIn: $isLoggedIn)
                .environmentObject(apiService)
                .preferredColorScheme(.dark)
        } else {
            // Mengambil LoginView dari file AuthViews.swift
            LoginView(isLoggedIn: $isLoggedIn)
                .preferredColorScheme(.dark)
        }
    }
}

// MARK: - MAIN TAB NAVIGATION
struct MainTabView: View {
    @Binding var isLoggedIn: Bool
    @EnvironmentObject var api: APIService
    
    var body: some View {
        TabView {
            // TAB 1: DASHBOARD (Pusat Kendali)
            DashboardView(api: api)
                .tabItem {
                    Label("Dashboard", systemImage: "chart.xyaxis.line")
                }
            
            // TAB 2: SCANNER (Pencari Sinyal)
            ScannerView(api: api)
                .tabItem {
                    Label("Scanner", systemImage: "waveform.path.ecg")
                }
            
            // TAB 3: WATCHLIST (Dari file WatchlistView.swift)
            WatchlistView(api: api)
                .tabItem {
                    Label("Watchlist", systemImage: "eye.fill")
                }
            
            // TAB 4: LOGS (Riwayat Robot)
            BotLogsView(api: api)
                .tabItem {
                    Label("Bot Logs", systemImage: "scroll.fill")
                }
            
            // TAB 5: PROFILE (Dari file AuthViews.swift)
            ProfileView(isLoggedIn: $isLoggedIn)
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle")
                }
        }
        .accentColor(Theme.accent)
        .onAppear {
            // Load data awal background
            api.fetchWatchlist()
            api.fetchLogs()
        }
    }
}

// MARK: - 1. DASHBOARD VIEW (COMPREHENSIVE)
struct DashboardView: View {
    @ObservedObject var api: APIService
    
    // --- STATE CONTROLS ---
    @State private var activeSymbol = "SOL-USD"
    @State private var selectedStrategy = "MOMENTUM"
    @State private var selectedTimeframe = "1d"
    @State private var selectedPeriod = "1y"
    @State private var showMatrix = false
    @State private var refreshID = UUID() // Trigger redraw chart
    
    // --- DROPDOWN OPTIONS ---
    let strategies = ["MOMENTUM", "MEAN_REVERSAL", "GRID", "MULTITIMEFRAME"]
    let timeframes = ["1h", "4h", "1d"]
    let periods = ["1mo", "6mo", "1y", "2y", "max"]
    
    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 25) { // Spacing besar agar tidak sesak
                    
                    // ===================================
                    // SECTION A: HEADER & INPUT CONTROL
                    // ===================================
                    VStack(spacing: 15) {
                        // Baris 1: Status & Run Button
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("QUANT DASHBOARD")
                                    .font(.caption).bold()
                                    .foregroundColor(.gray)
                                    .tracking(2)
                                
                                HStack {
                                    Circle()
                                        .fill(api.isLoading ? Color.yellow : Color.green)
                                        .frame(width: 8, height: 8)
                                        .shadow(color: api.isLoading ? .yellow : .green, radius: 4)
                                    Text(api.isLoading ? "PROCESSING..." : "SYSTEM ONLINE")
                                        .font(.caption2).bold()
                                        .foregroundColor(api.isLoading ? .yellow : .green)
                                }
                            }
                            
                            Spacer()
                            
                            Button(action: { run() }) {
                                HStack(spacing: 6) {
                                    Image(systemName: "play.fill")
                                    Text("RUN BACKTEST")
                                }
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.black)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(Theme.accent)
                                .cornerRadius(20)
                                .shadow(color: Theme.accent.opacity(0.4), radius: 8, x: 0, y: 4)
                            }
                        }
                        
                        // Baris 2: Search Input Field
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.gray)
                            
                            TextField("Search Symbol (e.g. BTC-USD, NVDA)", text: $activeSymbol)
                                .foregroundColor(.white)
                                .font(.system(.body, design: .monospaced))
                                .autocapitalization(.allCharacters)
                                .disableAutocorrection(true)
                                .submitLabel(.go)
                                .onSubmit { run() }
                            
                            if !activeSymbol.isEmpty {
                                Button(action: { activeSymbol = "" }) {
                                    Image(systemName: "xmark.circle.fill").foregroundColor(.gray)
                                }
                            }
                        }
                        .padding(12)
                        .background(Theme.cardBackground)
                        .cornerRadius(12)
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Theme.grid, lineWidth: 1))
                        
                        // Baris 3: Horizontal Filter Selectors
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                // Strategy Menu
                                Menu {
                                    ForEach(strategies, id: \.self) { strat in
                                        Button(strat) { selectedStrategy = strat; run() }
                                    }
                                } label: {
                                    FilterChip(icon: "cpu", title: "STRAT", value: selectedStrategy.prefix(4).description, color: .blue)
                                }
                                
                                // Timeframe Menu
                                Menu {
                                    ForEach(timeframes, id: \.self) { tf in
                                        Button(tf.uppercased()) { selectedTimeframe = tf; run() }
                                    }
                                } label: {
                                    FilterChip(icon: "clock", title: "TF", value: selectedTimeframe.uppercased(), color: .white)
                                }
                                
                                // Period Menu
                                Menu {
                                    ForEach(periods, id: \.self) { per in
                                        Button(per.uppercased()) { selectedPeriod = per; run() }
                                    }
                                } label: {
                                    FilterChip(icon: "calendar", title: "RANGE", value: selectedPeriod.uppercased(), color: .white)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                    
                    // ===================================
                    // SECTION B: TRADINGVIEW CHART
                    // ===================================
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Image(systemName: "chart.xyaxis.line")
                                .foregroundColor(Theme.accent)
                            Text("PRICE ACTION")
                                .font(.caption).bold().foregroundColor(.white)
                                .tracking(1)
                            Spacer()
                            Text("\(activeSymbol) • \(selectedTimeframe.uppercased())")
                                .font(.caption).bold().foregroundColor(.gray)
                        }
                        .padding(.horizontal)
                        
                        ZStack {
                            Theme.cardBackground
                                .cornerRadius(12)
                            
                            if !api.chartData.isEmpty {
                                // Menggunakan TradingViewChart dari file eksternal
                                TradingViewChart(symbol: activeSymbol, interval: selectedTimeframe, theme: "dark")
                                    .id(refreshID) // Force refresh saat parameter berubah
                            } else {
                                VStack(spacing: 15) {
                                    if api.isLoading {
                                        ProgressView().tint(Theme.accent)
                                        Text("Fetching Market Data...").font(.caption).foregroundColor(.gray)
                                    } else {
                                        Image(systemName: "chart.bar.xaxis")
                                            .font(.system(size: 40))
                                            .foregroundColor(.gray.opacity(0.3))
                                        Text("No Data Loaded").foregroundColor(.gray)
                                        Button("Load \(activeSymbol)") { run() }
                                            .font(.caption).bold()
                                            .padding(8).background(Color.white.opacity(0.1)).cornerRadius(8)
                                            .foregroundColor(.white)
                                    }
                                }
                            }
                        }
                        .frame(height: 350) // Tinggi ideal untuk chart
                        .cornerRadius(12)
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Theme.grid, lineWidth: 1))
                        .padding(.horizontal)
                    }
                    
                    // ===================================
                    // SECTION C: PERFORMANCE & EQUITY
                    // ===================================
                    if let metrics = api.metrics {
                        VStack(spacing: 20) {
                            
                            // 1. Grid Metrics
                            HStack(spacing: 12) {
                                MetricCard(title: "NET PROFIT", value: String(format: "$%.2f", metrics.net_profit ?? 0.0), isMoney: true)
                                MetricCard(title: "WIN RATE", value: String(format: "%.1f%%", metrics.win_rate ?? 0.0), isMoney: false)
                                MetricCard(title: "TRADES", value: "\(metrics.total_trades ?? 0)", isMoney: false)
                            }
                            .padding(.horizontal)
                            
                            // 2. Equity Curve (Grafik Pertumbuhan)
                            // FITUR INI DIKEMBALIKAN SESUAI REQUEST
                            if !api.equityData.isEmpty {
                                VStack(alignment: .leading, spacing: 10) {
                                    HStack {
                                        Image(systemName: "arrow.up.right.circle.fill")
                                            .foregroundColor(.green)
                                        Text("PORTFOLIO GROWTH")
                                            .font(.caption).bold()
                                            .foregroundColor(.gray)
                                            .tracking(1)
                                        Spacer()
                                        Text("Final: $\(String(format: "%.2f", metrics.final_balance ?? 0.0))")
                                            .font(.caption).bold()
                                            .foregroundColor(.white)
                                    }
                                    
                                    // Menggunakan EquityLineChart dari file ChartViews.swift
                                    EquityLineChart(data: api.equityData)
                                        .frame(height: 180) // Tinggi chart equity
                                        .padding(.vertical, 5)
                                }
                                .padding(16)
                                .background(Theme.cardBackground)
                                .cornerRadius(16)
                                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Theme.grid, lineWidth: 1))
                                .padding(.horizontal)
                            }
                        }
                    }
                    
                    // ===================================
                    // SECTION D: MATRIX BUTTON
                    // ===================================
                    Button(action: { showMatrix.toggle() }) {
                        HStack {
                            ZStack {
                                Circle().fill(Color.blue.opacity(0.2)).frame(width: 36, height: 36)
                                Image(systemName: "square.grid.3x3.fill").foregroundColor(.blue)
                            }
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("STRATEGY MATRIX")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.white)
                                Text("Compare multiple strategies instantly")
                                    .font(.caption).foregroundColor(.gray)
                            }
                            
                            Spacer()
                            Image(systemName: "chevron.right").foregroundColor(.gray)
                        }
                        .padding(12)
                        .background(Theme.cardBackground)
                        .cornerRadius(12)
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Theme.grid, lineWidth: 1))
                    }
                    .padding(.horizontal)
                    .sheet(isPresented: $showMatrix) {
                        StrategyMatrixView(comparisons: api.comparisonMatrix)
                    }
                    
                    // Spacer bawah agar scroll tidak tertutup tab bar
                    Spacer(minLength: 50)
                }
            }
        }
        .onAppear {
            // Auto run jika data kosong
            if api.metrics == nil { run() }
        }
    }
    
    // Fungsi Eksekusi Utama
    func run() {
        // Auto-fix format symbol
        let clean = activeSymbol.uppercased().replacingOccurrences(of: " ", with: "")
        let finalSym = (!clean.contains("-") && !clean.contains("USD")) ? "\(clean)-USD" : clean
        
        if activeSymbol != finalSym { activeSymbol = finalSym }
        
        // Refresh UUID untuk memaksa update chart TradingView
        refreshID = UUID()
        
        // Panggil API
        api.runBacktest(
            symbol: finalSym,
            strategy: selectedStrategy,
            tf: selectedTimeframe,
            period: selectedPeriod
        )
    }
    
    // Helper untuk Chip Filter
    func FilterChip(icon: String, title: String, value: String, color: Color) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption2)
                .foregroundColor(color.opacity(0.8))
            
            VStack(alignment: .leading, spacing: 0) {
                Text(title)
                    .font(.system(size: 8, weight: .bold))
                    .foregroundColor(.gray)
                Text(value)
                    .font(.caption).bold()
                    .foregroundColor(.white)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Theme.cardBackground)
        .cornerRadius(10)
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Theme.grid, lineWidth: 1))
    }
}

// MARK: - 2. SCANNER VIEW (WITH NET PROFIT & TRADES)
struct ScannerView: View {
    @ObservedObject var api: APIService
    
    let sectors = ["AI Coins", "Big Cap", "Meme Coins", "DeFi", "Layer 2", "US Tech"]
    // Mapping agar sesuai dengan Backend Python
    let sectorKeys: [String: String] = [
        "AI Coins": "AI_COINS", "Big Cap": "BIG_CAP", "Meme Coins": "MEME_COINS",
        "DeFi": "DEX_DEFI", "Layer 2": "LAYER_2", "US Tech": "US_TECH"
    ]
    
    @State private var selectedSector = "AI Coins"
    
    var body: some View {
        NavigationView {
            ZStack {
                Theme.background.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header Scanner
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Market Opportunity Scanner")
                            .font(.headline).foregroundColor(.gray)
                            .padding(.horizontal)
                        
                        // Horizontal Scroll Selector
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(sectors, id: \.self) { sector in
                                    Button(action: {
                                        selectedSector = sector
                                        let key = sectorKeys[sector] ?? "ALL"
                                        api.runScanner(sector: key)
                                    }) {
                                        Text(sector)
                                            .font(.caption).bold()
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 10)
                                            .background(selectedSector == sector ? Theme.accent : Theme.cardBackground)
                                            .foregroundColor(selectedSector == sector ? .black : .white)
                                            .cornerRadius(20)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 20)
                                                    .stroke(Theme.grid, lineWidth: selectedSector == sector ? 0 : 1)
                                            )
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.bottom, 15)
                    .background(Theme.background)
                    
                    Divider().background(Theme.grid)
                    
                    // List Hasil Scan
                    if api.scanResults.isEmpty {
                        Spacer()
                        VStack(spacing: 15) {
                            if api.isLoading {
                                ProgressView().tint(Theme.accent)
                                Text("Scanning Market...").font(.caption).foregroundColor(.gray)
                            } else {
                                Image(systemName: "waveform.path.ecg")
                                    .font(.system(size: 60))
                                    .foregroundColor(.gray.opacity(0.3))
                                Text("Ready to Scan").font(.headline).foregroundColor(.gray)
                                
                                Button("Scan Now") {
                                    let key = sectorKeys[selectedSector] ?? "ALL"
                                    api.runScanner(sector: key)
                                }
                                .padding(.horizontal, 24)
                                .padding(.vertical, 12)
                                .background(Theme.accent)
                                .cornerRadius(10)
                                .foregroundColor(.black)
                                .font(.headline)
                            }
                        }
                        Spacer()
                    } else {
                        List {
                            ForEach(api.scanResults) { item in
                                ZStack {
                                    Theme.cardBackground
                                    
                                    HStack {
                                        // Kolom Kiri: Info Aset
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(item.symbol)
                                                .font(.headline).bold()
                                                .foregroundColor(.white)
                                            
                                            HStack(spacing: 4) {
                                                Image(systemName: "cpu").font(.caption2).foregroundColor(.blue)
                                                Text(item.recommended_strategy ?? "AUTO")
                                                    .font(.caption).foregroundColor(.gray)
                                            }
                                        }
                                        
                                        Spacer()
                                        
                                        // Kolom Kanan: Statistik
                                        VStack(alignment: .trailing, spacing: 4) {
                                            // Win Rate (Hijau/Kuning)
                                            Text("Win: \(String(format: "%.0f", item.win_rate_est ?? 0))%")
                                                .font(.subheadline).bold()
                                                .foregroundColor((item.win_rate_est ?? 0) >= 60 ? .green : .yellow)
                                            
                                            // Net Profit (Hijau/Merah)
                                            if let net = item.net_profit {
                                                Text("Pnl: \(String(format: "%.0f", net))%")
                                                    .font(.caption).bold()
                                                    .foregroundColor(net >= 0 ? .green : .red)
                                            }
                                            
                                            // Trade Count
                                            if let trades = item.total_trades {
                                                Text("#\(trades) Trds")
                                                    .font(.caption2).foregroundColor(.gray)
                                            }
                                        }
                                        
                                        // Tombol Add (+)
                                        Button(action: {
                                            api.addToWatchlist(symbol: item.symbol)
                                        }) {
                                            Image(systemName: "plus.circle.fill")
                                                .font(.title2)
                                                .foregroundColor(Theme.accent)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                        .padding(.leading, 12)
                                    }
                                    .padding(.vertical, 8)
                                }
                                .listRowBackground(Theme.cardBackground)
                                .listRowSeparatorTint(Theme.grid)
                            }
                        }
                        .listStyle(.plain)
                        .refreshable {
                            let key = sectorKeys[selectedSector] ?? "ALL"
                            api.runScanner(sector: key)
                        }
                    }
                }
            }
            .navigationTitle("Global Scanner")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            // Auto scan saat pertama kali buka tab
            if api.scanResults.isEmpty {
                let key = sectorKeys[selectedSector] ?? "ALL"
                api.runScanner(sector: key)
            }
        }
    }
}

// MARK: - 3. BOT LOGS VIEW (INTEGRATED)
struct BotLogsView: View {
    @ObservedObject var api: APIService
    
    var body: some View {
        NavigationView {
            ZStack {
                Theme.background.ignoresSafeArea()
                
                if api.tradeLogs.isEmpty {
                    VStack(spacing: 15) {
                        Image(systemName: "scroll")
                            .font(.system(size: 60))
                            .foregroundColor(.gray.opacity(0.3))
                        Text("No Trading Logs Yet").foregroundColor(.gray)
                        Button("Refresh Logs") { api.fetchLogs() }
                            .padding()
                            .background(Theme.cardBackground)
                            .cornerRadius(8)
                            .foregroundColor(.white)
                    }
                } else {
                    List(api.tradeLogs) { log in
                        HStack {
                            VStack(alignment: .leading, spacing: 6) {
                                Text(log.symbol)
                                    .font(.headline).bold()
                                    .foregroundColor(.white)
                                HStack {
                                    Image(systemName: "clock").font(.caption2)
                                    Text(log.dateFormatted).font(.caption)
                                }
                                .foregroundColor(.gray)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 6) {
                                // Badge Action (BUY/SELL)
                                Text(log.action)
                                    .font(.system(size: 12, weight: .black))
                                    .foregroundColor(log.action == "BUY" ? .black : .white)
                                    .padding(.vertical, 4)
                                    .padding(.horizontal, 10)
                                    .background(log.action == "BUY" ? Theme.bull : Theme.bear)
                                    .cornerRadius(6)
                                
                                Text("$\(String(format: "%.2f", log.price))")
                                    .font(.subheadline).monospacedDigit()
                                    .foregroundColor(.white)
                            }
                        }
                        .listRowBackground(Theme.cardBackground)
                        .listRowSeparatorTint(Theme.grid)
                    }
                    .listStyle(.plain)
                    .refreshable {
                        api.fetchLogs()
                    }
                }
            }
            .navigationTitle("Live Bot Logs")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear { api.fetchLogs() }
        }
    }
}

// MARK: - HELPER COMPONENTS
// (Komponen kecil didefinisikan di sini untuk kemudahan)

struct MetricCard: View {
    let title: String
    let value: String
    let isMoney: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.gray)
                .textCase(.uppercase)
                .tracking(1)
            
            Text(value)
                .font(.title3).bold()
                .foregroundColor(isMoney ? (value.contains("-") ? Theme.bear : Theme.bull) : .white)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Theme.cardBackground)
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Theme.grid, lineWidth: 1))
    }
}

struct StrategyMatrixView: View {
    let comparisons: [StrategyComparison]
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Theme.background.ignoresSafeArea()
                
                if comparisons.isEmpty {
                    VStack {
                        ProgressView().tint(.white)
                        Text("Calculating Strategy Matrix...").font(.caption).foregroundColor(.gray).padding()
                    }
                } else {
                    List(comparisons) { comp in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(comp.strategy)
                                    .font(.headline).bold()
                                    .foregroundColor(.white)
                                Text("\(comp.trades ?? 0) Trades Executed")
                                    .font(.caption).foregroundColor(.gray)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing) {
                                Text("$\(String(format: "%.0f", comp.net_profit ?? 0.0))")
                                    .font(.headline).bold()
                                    .foregroundColor((comp.net_profit ?? 0) > 0 ? Theme.bull : Theme.bear)
                                Text("Win Rate: \(String(format: "%.1f", comp.win_rate ?? 0.0))%")
                                    .font(.caption).foregroundColor(.gray)
                            }
                        }
                        .listRowBackground(Theme.cardBackground)
                        .listRowSeparatorTint(Theme.grid)
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Strategy Comparison")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }.foregroundColor(Theme.accent)
                }
            }
        }
    }
}
