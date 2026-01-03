import SwiftUI

struct WatchlistView: View {
    @ObservedObject var api: APIService
    @State private var searchText = ""
    @State private var searchResult: String? = nil
    
    var body: some View {
        NavigationView {
            ZStack {
                Theme.background.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // SEARCH BAR AREA
                    VStack(spacing: 12) {
                        HStack {
                            Image(systemName: "magnifyingglass").foregroundColor(.gray)
                            TextField("Search Symbol (e.g. BTC-USD)", text: $searchText)
                                .foregroundColor(.white)
                                .autocapitalization(.allCharacters)
                                .disableAutocorrection(true)
                                .submitLabel(.done)
                                .onSubmit { validateSymbol() }
                            
                            if !searchText.isEmpty {
                                Button(action: { searchText = ""; searchResult = nil }) {
                                    Image(systemName: "xmark.circle.fill").foregroundColor(.gray)
                                }
                            }
                        }
                        .padding()
                        .background(Theme.cardBackground)
                        .cornerRadius(12)
                        
                        // HASIL PENCARIAN & TOMBOL ADD
                        if let result = searchResult {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(result).font(.headline).bold().foregroundColor(.white)
                                    Text("Asset").font(.caption).foregroundColor(.gray)
                                }
                                Spacer()
                                Button(action: { addToWatchlist(symbol: result) }) {
                                    HStack {
                                        Image(systemName: "plus.circle.fill")
                                        Text("ADD")
                                    }
                                    .font(.caption).bold()
                                    .padding(.horizontal, 12).padding(.vertical, 6)
                                    .background(Theme.accent).foregroundColor(.black)
                                    .cornerRadius(20)
                                }
                            }
                            .padding()
                            .background(Color.blue.opacity(0.15))
                            .cornerRadius(12)
                            .transition(.opacity)
                        }
                    }
                    .padding()
                    .background(Theme.background)
                    
                    // LIST WATCHLIST
                    if api.watchlist.isEmpty {
                        Spacer()
                        VStack {
                            Image(systemName: "eye.slash").font(.largeTitle).foregroundColor(.gray)
                            Text("Watchlist Empty").font(.caption).foregroundColor(.gray).padding(.top, 4)
                            Button("Refresh") { api.fetchWatchlist() }.padding().foregroundColor(Theme.accent)
                        }
                        Spacer()
                    } else {
                        ScrollView {
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                                ForEach(api.watchlist) { item in
                                    WatchlistCard(item: item)
                                        .contextMenu {
                                            Button(role: .destructive) {
                                                // Logika delete opsional
                                                // api.deleteItem(item.symbol)
                                            } label: {
                                                Label("Remove", systemImage: "trash")
                                            }
                                        }
                                }
                            }
                            .padding()
                        }
                    }
                }
            }
            .navigationTitle("Smart Watchlist")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear { api.fetchWatchlist() }
        }
    }
    
    func validateSymbol() {
        if !searchText.isEmpty {
            let uppercased = searchText.uppercased()
            if !uppercased.contains("-") && !uppercased.contains("USD") {
                searchResult = "\(uppercased)-USD"
            } else {
                searchResult = uppercased
            }
        }
    }
    
    func addToWatchlist(symbol: String) {
        // GANTI IP DI SINI JIKA PERLU
        guard let url = URL(string: "http://192.168.179.164:8000/api/watchlist") else { return }
        
        let body: [String: Any] = ["symbol": symbol, "mode": "AUTO"]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { _, _, _ in
            DispatchQueue.main.async {
                self.searchText = ""
                self.searchResult = nil
                self.api.fetchWatchlist()
            }
        }.resume()
    }
}

// KARTU WATCHLIST DIPINDAHKAN KE SINI
struct WatchlistCard: View {
    let item: WatchlistItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(item.symbol).font(.headline).foregroundColor(.white)
                Spacer()
                if let strat = item.strategy {
                    Text(strat.prefix(3))
                        .font(.caption2)
                        .padding(4)
                        .background(Color.blue.opacity(0.3))
                        .cornerRadius(4)
                        .foregroundColor(.white)
                }
            }
            
            Text(item.mode == "MANUAL" ? "MANUAL" : "AUTO AI")
                .font(.caption2).fontWeight(.bold)
                .foregroundColor(item.mode == "MANUAL" ? .purple : .green)
            
            if let growth = item.growth_pct {
                Text("\(growth >= 0 ? "+" : "")\(String(format: "%.1f", growth))%")
                    .font(.caption)
                    .foregroundColor(growth >= 0 ? Theme.bull : Theme.bear)
            } else {
                Text("Calculating...")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Theme.cardBackground)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Theme.grid, lineWidth: 1)
        )
    }
}
