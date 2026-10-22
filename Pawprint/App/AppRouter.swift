//
//  AppRouter.swift
//  Pawprint
//
//  Created by Benjamin Vu on 22/10/2026.
//
//  Decides which tab is showing and which guide to open. Widget taps,
//  and the "Read the guide" links in Health, both go through here.
//

import Foundation
import Observation

enum AppTab: Hashable {
    case home, routines, health, learn
}

@MainActor
@Observable
final class AppRouter {
    var selectedTab: AppTab = .home
    /// A guide the Learn tab should open as soon as it can.
    var pendingTipID: String?

    func open(_ link: PawprintDeepLink) {
        switch link {
        case .home:
            selectedTab = .home
        case .routines:
            selectedTab = .routines
        case .health:
            selectedTab = .health
        case .learn(let tipID):
            pendingTipID = tipID
            selectedTab = .learn
        }
    }

    func handle(url: URL) {
        guard let link = PawprintDeepLink(url: url) else { return }
        open(link)
    }
}
