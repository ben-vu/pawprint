//
//  PawprintFontsTests.swift
//  PawprintTests
//
//  Created by Natalie Michael on 20/10/2026.
//

import Testing
import UIKit
import SwiftUI
@testable import Pawprint

@MainActor
struct PawprintFontsTests {

    @Test func bundledNunitoLoadsAtEveryWeight() {
        PawprintFonts.registerAll()
        for weight in ["Nunito-Regular", "Nunito-SemiBold", "Nunito-Bold", "Nunito-Black"] {
            #expect(UIFont(name: weight, size: 17) != nil, "\(weight) did not register")
        }
    }

    @Test func textStylesKeepAppleSizes() {
        #expect(PawprintFonts.baseSize(for: .body) == 17)
        #expect(PawprintFonts.baseSize(for: .largeTitle) == 34)
        #expect(PawprintFonts.name(for: .black) == "Nunito-Black")
        #expect(PawprintFonts.name(for: .regular) == "Nunito-Regular")
    }
}
