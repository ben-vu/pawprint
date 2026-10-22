//
//  FilterChipBar.swift
//  Pawprint
//
//  Horizontally scrolling filter chips, the design from the Learn tab,
//  usable with any list of items. Every chip is at least 44pt tall.
//

import SwiftUI

struct FilterChipBar<Item: Hashable>: View {
    let items: [Item]
    @Binding var selection: Item
    let title: (Item) -> String
    let systemImage: (Item) -> String

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(items, id: \.self) { item in
                    chip(for: item)
                }
            }
            .padding(.horizontal, 16)
        }
        .sensoryFeedback(.selection, trigger: selection)
    }

    private func chip(for item: Item) -> some View {
        let isSelected = selection == item
        return Button {
            selection = item
        } label: {
            Label(title(item), systemImage: systemImage(item))
                .font(PawprintTheme.font(.subheadline, weight: .semibold))
                .lineLimit(1)
                .padding(.horizontal, 14)
                .frame(minHeight: 44)
                .foregroundStyle(isSelected ? PawprintTheme.onAccent : PawprintTheme.textPrimary)
                .background(
                    isSelected ? PawprintTheme.accent : PawprintTheme.surfaceRaised,
                    in: Capsule()
                )
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

#Preview {
    FilterChipBar(items: ["All", "Walk", "Meal"], selection: .constant("All"), title: { $0 }, systemImage: { _ in "pawprint" })
        .padding(.vertical)
        .background(PawprintTheme.background)
}
