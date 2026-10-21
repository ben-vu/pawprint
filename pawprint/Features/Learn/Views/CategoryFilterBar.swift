//
//  CategoryFilterBar.swift
//  Pawprint
//
//  Created by Benjamin Vu on 21/10/2026.
//
//  Horizontally scrolling chips: All, Saved, then one per category.
//  Every chip is at least 44pt tall.
//

import SwiftUI

struct CategoryFilterBar: View {
    @Binding var selection: LearnFilter

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(LearnFilter.allFilters) { filter in
                    chip(for: filter)
                }
            }
            .padding(.horizontal, 16)
        }
        .sensoryFeedback(.selection, trigger: selection)
    }

    private func chip(for filter: LearnFilter) -> some View {
        let isSelected = selection == filter
        return Button {
            selection = filter
        } label: {
            Label(filter.title, systemImage: filter.systemImage)
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
    CategoryFilterBar(selection: .constant(.all))
        .padding(.vertical)
        .background(PawprintTheme.background)
}
