//
//  LottieView.swift
//  pawprint
//
//  Plays a Lottie animation JSON from Resources/Animations on a loop.
//  Lottie is the airbnb/lottie-ios Swift package added to the project.
//

import SwiftUI
import Lottie

struct LottieView: UIViewRepresentable {
    let name: String
    var speed: CGFloat = 1

    func makeUIView(context: Context) -> LottieAnimationView {
        let view = LottieAnimationView(name: name)
        view.contentMode = .scaleAspectFit
        view.loopMode = .loop
        view.backgroundBehavior = .pauseAndRestore   // pause when the app goes to the background
        view.animationSpeed = speed
        view.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        view.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        view.play()
        return view
    }

    func updateUIView(_ view: LottieAnimationView, context: Context) {
        if !view.isAnimationPlaying { view.play() }
    }
}
