//
//  TipCardView.swift
//  Pawprint
//
//  Created by Benjamin Vu on 21/10/2026.
//
//  One row in the Learn list. Tapping the card opens the guide; the
//  bookmark button sits on top as its own 44x44pt control.
//

import SwiftUI

struct TipCardView: View {
    let tip: LearnTip
    let onToggleBookmark: () -> Void

    var body: some View {
        NavigationLink(value: tip) {
            PawprintCard {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 6) {
                        Label(tip.learnCategory.title, systemImage: tip.learnCategory.systemImage)
                            .font(PawprintTheme.font(.caption, weight: .semibold))
                            .foregroundStyle(PawprintTheme.accent)
                        Text("\(tip.readingMinutes) min read")
                            .font(PawprintTheme.font(.caption))
                            .foregroundStyle(PawprintTheme.textSecondary)
                        Spacer(minLength: 44)
                    }

                    Text(tip.title)
                        .font(PawprintTheme.font(.headline, weight: .bold))
                        .foregroundStyle(PawprintTheme.textPrimary)
                        .multilineTextAlignment(.leading)

                    Text(tip.summary)
                        .font(PawprintTheme.font(.subheadline))
                        .foregroundStyle(PawprintTheme.textSecondary)
                        .lineLimit(3)
                        .multilineTextAlignment(.leading)
                }
            }
        }
        .buttonStyle(.plain)
        .overlay(alignment: .topTrailing) {
            bookmarkButton
        }
        .padding(.horizontal, 16)
    }

    private var bookmarkButton: some View {
        Button(action: onToggleBookmark) {
            Image(systemName: tip.isBookmarked ? "bookmark.fill" : "bookmark")
                .font(.title3)
                .foregroundStyle(PawprintTheme.accent)
                .frame(width: 44, height: 44)
        }
        .buttonStyle(.plain)
        .padding(.top, 4)
        .padding(.trailing, 4)
        .accessibilityLabel(tip.isBookmarked ? "Remove bookmark for \(tip.title)" : "Bookmark \(tip.title)")
        .sensoryFeedback(.selection, trigger: tip.isBookmarked)
    }
}
