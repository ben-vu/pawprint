//
//  AppearanceSetting.swift
//  Pawprint
//
//  Created by Benjamin Vu on 29/10/2026.
//
//  The user's Light / Dark / System choice. Stored in UserDefaults and
//  applied once at the app root with `.preferredColorScheme`. Every
//  PawprintTheme colour already has a light and a dark value, so no view
//  needs to change.
//

import SwiftUI

enum AppearanceSetting: String, CaseIterable, Identifiable {
    case system, light, dark

    static let storageKey = "appearanceSetting"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .system: "System"
        case .light:  "Light"
        case .dark:   "Dark"
        }
    }

    var systemImage: String {
        switch self {
        case .system: "circle.lefthalf.filled"
        case .light:  "sun.max"
        case .dark:   "moon"
        }
    }

    /// `nil` means follow the device setting.
    var colorScheme: ColorScheme? {
        switch self {
        case .system: nil
        case .light:  .light
        case .dark:   .dark
        }
    }
}
