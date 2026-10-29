//
//  RootView.swift
//  Pawprint
//
//  Created by Natalie Michael on 20/10/2026.
//
//  Decides what the user sees first: the launch animation, then either
//  onboarding (first run) or the main tab bar.
//

import SwiftUI

struct RootView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var isLaunching = true

    var body: some View {
        ZStack {
            if isLaunching {
                LaunchView {
                    withAnimation(.easeInOut(duration: 0.45)) { isLaunching = false }
                }
                .transition(.opacity)
            } else if hasCompletedOnboarding {
                MainTabView()
                    .transition(.opacity)
            } else {
                OnboardingView {
                    withAnimation(.easeInOut(duration: 0.35)) { hasCompletedOnboarding = true }
                }
                .transition(.move(edge: .trailing).combined(with: .opacity))
            }
        }
    }
}

#Preview {
    RootView()
        .environment(PawprintRepositories.preview())
}
