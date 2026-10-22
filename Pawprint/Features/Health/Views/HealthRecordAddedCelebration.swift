//
//  HealthRecordAddedCelebration.swift
//  Pawprint
//
//  Shown after a health record is saved: the pug hands over the record,
//  then the card fades away. Tap anywhere to close it early. With Reduce
//  Motion on it shows a still pug instead.
//

import SwiftUI

struct HealthRecordAddedCelebration: View {
    let onFinished: () -> Void

    static let animationName = "PugHandoff"          // Resources/Animations/PugHandoff.json
    static let aspectRatio: CGFloat = 780.0 / 460.0  // the Lottie file's size

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()

            VStack(spacing: 12) {
                animation
                    .aspectRatio(Self.aspectRatio, contentMode: .fit)
                    .background(PawprintTheme.background)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                Text("Record saved!")
                    .font(PawprintTheme.displayFont(.title3))
                    .foregroundStyle(PawprintTheme.textPrimary)
            }
            .padding(16)
            .background(PawprintTheme.surface, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
            .padding(24)
        }
        .contentShape(Rectangle())
        .onTapGesture(perform: onFinished)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Health record saved")
        .accessibilityHint("Double-tap to close")
        .accessibilityAction { onFinished() }
        .onAppear {
            AccessibilityNotification.Announcement("Health record saved").post()
        }
    }

    @ViewBuilder
    private var animation: some View {
        if reduceMotion {
            Image("PugHappy")
                .resizable()
                .scaledToFit()
                .padding(24)
                .task {
                    try? await Task.sleep(for: .seconds(1.5))
                    onFinished()
                }
        } else {
            LottieView(name: Self.animationName, loops: false) {
                Task {
                    try? await Task.sleep(for: .seconds(0.6))   // hold on the last frame
                    onFinished()
                }
            }
        }
    }
}

#Preview {
    HealthRecordAddedCelebration(onFinished: {})
}
