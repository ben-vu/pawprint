//
//  LaunchView.swift
//  Pawprint
//
//  Created by Natalie Michael on 21/10/2026.
//
//  Opening animation. The pug rises from below the wordmark, the letters
//  stamp in one at a time, then the whole thing hands over to RootView.
//  Timing uses Swift concurrency so the sequence reads top to bottom.
//

import SwiftUI

struct LaunchView: View {
    let onFinished: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var pugOffset: CGFloat = 90
    @State private var pugOpacity: Double = 0
    @State private var visibleLetters = 0
    @State private var taglineOpacity: Double = 0

    private let letters = Array("PAWPRINT")

    var body: some View {
        ZStack {
            PawprintTheme.background.ignoresSafeArea()

            VStack(spacing: 18) {
                Image("PugMain")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 170)
                    .offset(y: pugOffset)
                    .opacity(pugOpacity)
                    .accessibilityHidden(true)

                HStack(spacing: 1) {
                    ForEach(letters.indices, id: \.self) { index in
                        Text(String(letters[index]))
                            .font(PawprintTheme.displayFont(.largeTitle))
                            .foregroundStyle(index < 3 ? PawprintTheme.accentDeep : PawprintTheme.accent)
                            .opacity(index < visibleLetters ? 1 : 0)
                            .scaleEffect(index < visibleLetters ? 1 : 1.4)
                    }
                }
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("Pawprint")

                Text("Every day, a good dog day.")
                    .font(PawprintTheme.font(.subheadline, weight: .semibold))
                    .foregroundStyle(PawprintTheme.textSecondary)
                    .opacity(taglineOpacity)
            }
            .padding(.horizontal, 24)
        }
        .task { await runSequence() }
    }

    private func runSequence() async {
        if reduceMotion {
            pugOffset = 0
            pugOpacity = 1
            visibleLetters = letters.count
            taglineOpacity = 1
            try? await Task.sleep(for: .seconds(1.1))
            onFinished()
            return
        }

        withAnimation(.spring(duration: 0.7, bounce: 0.35)) {
            pugOffset = 0
            pugOpacity = 1
        }
        try? await Task.sleep(for: .milliseconds(350))

        for _ in letters {
            withAnimation(.spring(duration: 0.28, bounce: 0.5)) {
                visibleLetters += 1
            }
            try? await Task.sleep(for: .milliseconds(70))
        }

        withAnimation(.easeOut(duration: 0.4)) { taglineOpacity = 1 }
        try? await Task.sleep(for: .milliseconds(900))
        onFinished()
    }
}

#Preview {
    LaunchView {}
}
