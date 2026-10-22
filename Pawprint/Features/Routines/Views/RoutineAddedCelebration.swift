//
//  RoutineAddedCelebration.swift
//  Routines feature (Sana)
//
//  Shown after a new routine is saved: the pug carries a note to the
//  corkboard and pins it up, then the card fades away. Tap anywhere to
//  close it early.
//

import SwiftUI
import UIKit
import ImageIO

struct RoutineAddedCelebration: View {
    let onFinished: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()

            VStack(spacing: 12) {
                PinNoteAnimation(onFinished: onFinished)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                Text("Routine added!")
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
        .accessibilityLabel("Routine added")
        .accessibilityHint("Double-tap to close")
        .accessibilityAction { onFinished() }
        .onAppear {
            AccessibilityNotification.Announcement("Routine added").post()
        }
    }
}

/// Plays the PugPinNote GIF once, one frame at a time, so only the frame on
/// screen is in memory. With Reduce Motion on it shows the pinned note as a
/// still instead.
private struct PinNoteAnimation: View {
    let onFinished: () -> Void

    static let assetName = "PugPinNote"
    /// The note is pinned and the pug has gone. Later frames reset the board for looping.
    static let lastFrame = 119
    static let aspectRatio: CGFloat = 700.0 / 460.0

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var frame: UIImage?

    var body: some View {
        ZStack {
            PawprintTheme.background
            if let frame {
                Image(uiImage: frame)
                    .resizable()
                    .scaledToFit()
            }
        }
        .aspectRatio(Self.aspectRatio, contentMode: .fit)
        .task { await play() }
    }

    private func play() async {
        guard let data = NSDataAsset(name: Self.assetName)?.data,
              let source = CGImageSourceCreateWithData(data as CFData, nil)
        else {
            onFinished()
            return
        }
        let last = min(Self.lastFrame, CGImageSourceGetCount(source) - 1)
        let frames = reduceMotion ? [last] : Array(0...last)

        do {
            for index in frames {
                if let image = CGImageSourceCreateImageAtIndex(source, index, nil) {
                    frame = UIImage(cgImage: image)
                }
                if !reduceMotion {
                    try await Task.sleep(for: .seconds(GIFDecoder.delay(at: index, in: source)))
                }
            }
            try await Task.sleep(for: .seconds(reduceMotion ? 1.5 : 0.8))   // hold on the pinned note
        } catch {
            return   // view went away (e.g. tapped to close), so stop quietly
        }
        onFinished()
    }
}

#Preview {
    RoutineAddedCelebration(onFinished: {})
}
