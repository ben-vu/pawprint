//
//  PawprintWidgetBundle.swift
//  PawprintWidget
//
//  Created by Benjamin Vu on 22/10/2026.
//
//  Every widget Pawprint offers: Upcoming (routines and health follow-ups)
//  and Care tip (a Learn guide a day).
//

import WidgetKit
import SwiftUI

@main
struct PawprintWidgetBundle: WidgetBundle {
    var body: some Widget {
        PawprintWidget()
        PawprintTipWidget()
    }
}
