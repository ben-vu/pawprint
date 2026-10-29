//
//  LottieView.swift
//  pawprint
//
//  Plays a Lottie animation JSON from Resources/Animations, on a loop by
//  default or once with a callback when it ends.
//  Lottie is the airbnb/lottie-ios Swift package added to the project.
//

import SwiftUI
import Lottie

struct LottieView: UIViewRepresentable {
    let name: String
    var speed: CGFloat = 1
    var loops = true                    // false plays once then calls onFinished
    var onFinished: (() -> Void)? = nil

    func makeUIView(context: Context) -> LottieAnimationView {
        let view = LottieAnimationView(name: name)
        view.contentMode = .scaleAspectFit
        view.loopMode = loops ? .loop : .playOnce
        view.backgroundBehavior = .pauseAndRestore   // pause when the app goes to the background
        view.animationSpeed = speed
        view.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        view.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        view.play { finished in
            if finished, !loops { onFinished?() }
        }
        return view
    }

    func updateUIView(_ view: LottieAnimationView, context: Context) {
        if loops, !view.isAnimationPlaying { view.play() }
    }
}
