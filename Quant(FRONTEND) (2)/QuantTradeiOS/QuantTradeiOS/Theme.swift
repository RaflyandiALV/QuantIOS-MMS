//
//  Theme.swift
//  QuantTradeiOS
//
//  Created by welan ale zeni on 07/12/25.
//

import SwiftUI

struct Theme {
    // Background Colors
    static let background = Color(hex: "#121212")       // Hitam pekat background utama
    static let cardBackground = Color(hex: "#1E1E1E")   // Abu gelap untuk kartu/panel
    
    // Trading Colors (Mirip TradingView)
    static let bull = Color(hex: "#26a69a") // Hijau Candlestick
    static let bear = Color(hex: "#ef5350") // Merah Candlestick
    static let text = Color(hex: "#D1D4DC") // Putih keabuan untuk teks
    static let grid = Color(hex: "#2A2E39") // Garis grid tipis
    
    // Accent
    static let accent = Color(hex: "#2962FF") // Biru untuk tombol/link
}

// Extension agar bisa pakai Hex Color dengan mudah
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
