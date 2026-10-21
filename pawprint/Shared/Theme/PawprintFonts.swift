//
//  PawprintFonts.swift
//  pawprint
//
//  Loads the bundled Nunito font (SIL Open Font Licence, see Resources/Fonts)
//  and maps SwiftUI text styles and weights onto it. Registering at launch
//  means no Info.plist entry is needed, and the widget can call the same
//  function from its own bundle.
//

import SwiftUI
import UIKit
import CoreText

enum PawprintFonts {
    static let family = "Nunito"

    /// Call once at launch, before any view is drawn.
    static func registerAll(in bundle: Bundle = .main) {
        guard let url = bundle.url(forResource: "Nunito-Variable", withExtension: "ttf") else {
            assertionFailure("Nunito-Variable.ttf is missing from the bundle")
            return
        }
        var error: Unmanaged<CFError>?
        CTFontManagerRegisterFontsForURL(url as CFURL, .process, &error)   // already-registered is not an error for us
    }

    /// Gives navigation titles and tab labels the same font as the rest of the app.
    static func applyAppearance() {
        let nav = UINavigationBar.appearance()
        nav.largeTitleTextAttributes = [.font: uiFont(.largeTitle, weight: .black)]
        nav.titleTextAttributes = [.font: uiFont(.headline, weight: .bold)]
        UITabBarItem.appearance().setTitleTextAttributes([.font: uiFont(.caption2, weight: .semibold)], for: .normal)
    }

    /// PostScript name of the named instance inside the variable font.
    static func name(for weight: Font.Weight) -> String {
        switch weight {
        case .black: "Nunito-Black"
        case .heavy: "Nunito-ExtraBold"
        case .bold: "Nunito-Bold"
        case .semibold: "Nunito-SemiBold"
        case .medium: "Nunito-Medium"
        case .light: "Nunito-Light"
        case .ultraLight, .thin: "Nunito-ExtraLight"
        default: "Nunito-Regular"
        }
    }

    /// Apple's default point size for each text style, so Nunito sits at the same size the system font would.
    static func baseSize(for style: Font.TextStyle) -> CGFloat {
        switch style {
        case .largeTitle: 34
        case .title: 28
        case .title2: 22
        case .title3: 20
        case .headline, .body: 17
        case .callout: 16
        case .subheadline: 15
        case .footnote: 13
        case .caption: 12
        case .caption2: 11
        @unknown default: 17
        }
    }

    /// UIKit version, scaled with Dynamic Type, for appearance proxies.
    static func uiFont(_ style: Font.TextStyle, weight: Font.Weight) -> UIFont {
        let base = UIFont(name: name(for: weight), size: baseSize(for: style))
            ?? .systemFont(ofSize: baseSize(for: style))
        return UIFontMetrics(forTextStyle: uiStyle(style)).scaledFont(for: base)
    }

    private static func uiStyle(_ style: Font.TextStyle) -> UIFont.TextStyle {
        switch style {
        case .largeTitle: .largeTitle
        case .title: .title1
        case .title2: .title2
        case .title3: .title3
        case .headline: .headline
        case .callout: .callout
        case .subheadline: .subheadline
        case .footnote: .footnote
        case .caption: .caption1
        case .caption2: .caption2
        default: .body
        }
    }
}
