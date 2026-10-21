//
//  PawprintCard.swift
//  pawprint
//
//  Created by Natalie Michael on 21/10/2026.
//
//  Wrap any content in the standard cream card. Add more shared
//  components to this folder, anything used by two or more features.
//

import SwiftUI

struct PawprintCard<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        content
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(PawprintTheme.surface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(PawprintTheme.border.opacity(0.55), lineWidth: 1)
            )
    }
}

#Preview {
    PawprintCard {
        Text("Hello").foregroundStyle(PawprintTheme.textPrimary)
    }
    .padding()
    .background(PawprintTheme.background)
}
