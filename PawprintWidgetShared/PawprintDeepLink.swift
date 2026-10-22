//
//  PawprintDeepLink.swift
//  PawprintWidgetShared
//
//  Created by Benjamin Vu on 22/10/2026.
//
//  The links a widget tap opens: pawprint://routines, pawprint://health,
//  pawprint://learn or pawprint://learn/<guide-id>. The widget builds them
//  and the app reads them, so both sides use this one type.
//

import Foundation

nonisolated enum PawprintDeepLink: Equatable, Sendable {
    case home
    case routines
    case health
    case learn(tipID: String?)

    static let scheme = "pawprint"

    var url: URL {
        var components = URLComponents()
        components.scheme = Self.scheme
        switch self {
        case .home:
            components.host = "home"
        case .routines:
            components.host = "routines"
        case .health:
            components.host = "health"
        case .learn(let tipID):
            components.host = "learn"
            if let tipID { components.path = "/" + tipID }
        }
        return components.url ?? URL(fileURLWithPath: "/")
    }

    init?(url: URL) {
        guard url.scheme == Self.scheme, let host = url.host(percentEncoded: false) else { return nil }
        switch host {
        case "home":
            self = .home
        case "routines":
            self = .routines
        case "health":
            self = .health
        case "learn":
            let id = url.pathComponents.dropFirst().first
            self = .learn(tipID: id)
        default:
            return nil
        }
    }
}
