//
//  AnimatedImageView.swift
//  pawprint
//
//  Plays an animated GIF stored as a data set in the asset catalogue.
//  SwiftUI's Image only shows the first frame of a GIF, so this wraps
//  a UIImageView, which animates GIFs natively. When Reduce Motion is
//  on it shows a single still frame instead.
//

import SwiftUI
import UIKit
import ImageIO
import UniformTypeIdentifiers

struct AnimatedImageView: View {
    let name: String                                          // data set name in Assets.xcassets
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        AnimatedImageRepresentable(name: name, isAnimated: !reduceMotion)
            .accessibilityHidden(true)
    }
}

private struct AnimatedImageRepresentable: UIViewRepresentable {
    let name: String
    let isAnimated: Bool

    func makeUIView(context: Context) -> UIImageView {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.clipsToBounds = true
        view.setContentHuggingPriority(.defaultLow, for: .horizontal)   // let SwiftUI decide the size
        view.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        view.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        return view
    }

    func updateUIView(_ view: UIImageView, context: Context) {
        guard view.image == nil, let asset = NSDataAsset(name: name) else { return }
        view.image = isAnimated ? GIFDecoder.animatedImage(from: asset.data)
                                : UIImage(data: asset.data)
    }
}

private enum GIFDecoder {
    // Builds a UIImage that cycles through every frame of the GIF using the
    // delay stored in the file, so the speed matches the original.
    static func animatedImage(from data: Data) -> UIImage? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else { return nil }
        let count = CGImageSourceGetCount(source)
        guard count > 1 else { return UIImage(data: data) }

        var frames: [UIImage] = []
        var total: TimeInterval = 0
        for index in 0..<count {
            guard let cgImage = CGImageSourceCreateImageAtIndex(source, index, nil) else { continue }
            frames.append(UIImage(cgImage: cgImage))
            total += delay(at: index, in: source)
        }
        return UIImage.animatedImage(with: frames, duration: total)
    }

    private static func delay(at index: Int, in source: CGImageSource) -> TimeInterval {
        let fallback: TimeInterval = 0.1
        guard
            let properties = CGImageSourceCopyPropertiesAtIndex(source, index, nil) as? [CFString: Any],
            let gif = properties[kCGImagePropertyGIFDictionary] as? [CFString: Any]
        else { return fallback }
        let unclamped = gif[kCGImagePropertyGIFUnclampedDelayTime] as? TimeInterval
        let clamped = gif[kCGImagePropertyGIFDelayTime] as? TimeInterval
        let value = unclamped ?? clamped ?? fallback
        return value < 0.02 ? fallback : value                  // browsers treat tiny delays as 100ms
    }
}
