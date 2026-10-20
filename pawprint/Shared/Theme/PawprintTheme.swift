//
//  PawprintTheme.swift
//  pawprint
//
//  Single source of truth for colours and fonts. Every colour has a light
//  and a dark value so Dark Mode works without extra code in views.
//  Use these instead of Color.white, Color.black or hex strings in views.
//

import SwiftUI

enum PawprintTheme {
    // Backgrounds
    static let background = Color(light: "#E6DBCF", dark: "#1F1B17")
    static let surface    = Color(light: "#F5EEE5", dark: "#2A2521")
    static let surfaceRaised = Color(light: "#EADFD2", dark: "#352E29")
    static let border     = Color(light: "#B0A99C", dark: "#4A423B")

    // Text
    static let textPrimary   = Color(light: "#2C303B", dark: "#F5EEE5")
    static let textSecondary = Color(light: "#6F675C", dark: "#C9BBAA")

    // Brand
    static let accent     = Color(light: "#7A5E54", dark: "#D9B8A6")
    static let accentDeep = Color(light: "#534B3E", dark: "#EADFD2")
    static let onAccent   = Color(light: "#FFF0E2", dark: "#1F1B17")

    // Status
    static let success = Color(light: "#7E8F6A", dark: "#A3B88C")
    static let warning = Color(light: "#C9A24C", dark: "#E0C070")
    static let danger  = Color(light: "#B5544A", dark: "#E08A80")

    /// Heavy condensed heading font. Scales with Dynamic Type.
    static func displayFont(_ style: Font.TextStyle = .largeTitle) -> Font {
        .system(style, design: .default, weight: .black).width(.condensed)
    }
}

extension Color {
    /// A colour that switches automatically between Light and Dark Mode.
    init(light: String, dark: String) {
        self.init(uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark ? UIColor(hex: dark) : UIColor(hex: light)
        })
    }
}

extension UIColor {
    convenience init(hex: String) {
        var value: UInt64 = 0
        Scanner(string: hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))).scanHexInt64(&value)
        self.init(
            red: CGFloat((value >> 16) & 0xFF) / 255,
            green: CGFloat((value >> 8) & 0xFF) / 255,
            blue: CGFloat(value & 0xFF) / 255,
            alpha: 1
        )
    }
}
