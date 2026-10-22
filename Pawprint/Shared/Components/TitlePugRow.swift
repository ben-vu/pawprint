//
//  TitlePugRow.swift
//  Pawprint
//
//  Created by Sana Yousefi on 23/10/2026.
//
//  A tab's own pug at the top left of the page, just under the title,
//  flipped so it faces into the page. Whatever comes first on the page
//  (the filter chips, or the first heading) sits to its right.
//

import SwiftUI

struct TitlePugRow<Trailing: View>: View {
    let image: String
    @ViewBuilder var trailing: Trailing

    var body: some View {
        HStack(spacing: 0) {
            Image(image)
                .resizable()
                .scaledToFit()
                .scaleEffect(x: -1)
                .frame(height: 88)
                .accessibilityHidden(true)
            trailing
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

extension TitlePugRow where Trailing == EmptyView {
    init(image: String) {
        self.init(image: image) { EmptyView() }
    }
}

#Preview {
    VStack(alignment: .leading) {
        TitlePugRow(image: "PugRoutine") {
            FilterChipBar(items: ["All", "Walk", "Meal"], selection: .constant("All"), title: { $0 }, systemImage: { _ in "pawprint" })
        }
        TitlePugRow(image: "PugHealth")
    }
    .padding(.leading, 16)
    .background(PawprintTheme.background)
}
