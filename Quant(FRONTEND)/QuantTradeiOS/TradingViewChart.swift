import SwiftUI
import WebKit

struct TradingViewChart: UIViewRepresentable {
    let symbol: String
    let interval: String
    let theme: String // "dark" or "light"

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.isOpaque = false
        webView.backgroundColor = UIColor.clear
        webView.scrollView.backgroundColor = UIColor.clear
        webView.scrollView.isScrollEnabled = false // Matikan scroll agar pas di container
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        let tvInterval: String
        switch interval.lowercased() {
        case "1h": tvInterval = "60"
        case "4h": tvInterval = "240"
        case "1d": tvInterval = "D"
        default: tvInterval = "D"
        }
        
        // Bersihkan simbol (misal BTC-USDT jadi BTCUSDT)
        let cleanSymbol = symbol.replacingOccurrences(of: "-", with: "").uppercased()
        // Default ke BINANCE, bisa disesuaikan
        let tvSymbol = "BINANCE:\(cleanSymbol)"
        
        // CSS diperbaiki agar width & height 100%
        let htmlString = """
        <!DOCTYPE html>
        <html>
        <head>
            <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
            <style>
                html, body { margin: 0; padding: 0; width: 100%; height: 100%; overflow: hidden; background-color: #0d0d0d; }
                .tradingview-widget-container { width: 100%; height: 100%; }
                #tradingview_chart { width: 100%; height: 100%; }
            </style>
        </head>
        <body>
            <div class="tradingview-widget-container">
                <div id="tradingview_chart"></div>
                <script type="text/javascript" src="https://s3.tradingview.com/tv.js"></script>
                <script type="text/javascript">
                new TradingView.widget(
                {
                    "autosize": true,
                    "symbol": "\(tvSymbol)", 
                    "interval": "\(tvInterval)",
                    "timezone": "Asia/Jakarta",
                    "theme": "\(theme)",
                    "style": "1",
                    "locale": "en",
                    "toolbar_bg": "#f1f3f6",
                    "enable_publishing": false,
                    "hide_top_toolbar": false,
                    "hide_legend": false,
                    "save_image": false,
                    "container_id": "tradingview_chart"
                }
                );
                </script>
            </div>
        </body>
        </html>
        """
        webView.loadHTMLString(htmlString, baseURL: nil)
    }
}
