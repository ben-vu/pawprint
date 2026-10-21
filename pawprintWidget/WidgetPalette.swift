//
//  WidgetPalette.swift
//  pawprintWidget
//
//  Created by Benjamin Vu on 21/10/2026.
//

import SwiftUI
import UIKit

enum WidgetPalette {
    static let background    = dynamic(light: 0xF5EEE5, dark: 0x2A2521)
    static let textPrimary   = dynamic(light: 0x2C303B, dark: 0xF5EEE5)
    static let textSecondary = dynamic(light: 0x6F675C, dark: 0xC9BBAA)
    static let accent        = dynamic(light: 0x7A5E54, dark: 0xD9B8A6)
    static let success       = dynamic(light: 0x5F7050, dark: 0xA3B88C)
    static let danger        = dynamic(light: 0xB5544A, dark: 0xE08A80)

    private static func dynamic(light: UInt32, dark: UInt32) -> Color {
        Color(uiColor: UIColor { traits in
            let hex = traits.userInterfaceStyle == .dark ? dark : light
            return UIColor(
                red: CGFloat((hex >> 16) & 0xFF) / 255,
                green: CGFloat((hex >> 8) & 0xFF) / 255,
                blue: CGFloat(hex & 0xFF) / 255,
                alpha: 1
            )
        })
    }
}
