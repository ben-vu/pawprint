//
//  TipDetailView.swift
//  Pawprint
//
//  Created by Benjamin Vu on 21/10/2026.
//
//  A full beginner guide: key points first, then the explanation.
//

import SwiftUI

struct TipDetailView: View {
    let tip: LearnTip
    let viewModel: LearnViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                header

                if !tip.keyPoints.isEmpty {
                    keyPointsCard
                }

                ForEach(Array(tip.paragraphs.enumerated()), id: \.offset) { _, paragraph in
                    Text(paragraph)
                        .font(PawprintTheme.font(.body))
                        .foregroundStyle(PawprintTheme.textPrimary)
                        .lineSpacing(4)
                }

                Text("This is general guidance for healthy dogs. Your vet knows your dog best, so ask them if you are unsure.")
                    .font(PawprintTheme.font(.footnote))
                    .foregroundStyle(PawprintTheme.textSecondary)
                    .padding(.top, 8)
            }
            .padding(16)
        }
        .background(PawprintTheme.background.ignoresSafeArea())
        .navigationTitle(tip.learnCategory.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                ShareLink(item: "\(tip.title)\n\n\(tip.summary)") {
                    Image(systemName: "square.and.arrow.up")
                }
                .accessibilityLabel("Share \(tip.title)")

                Button {
                    viewModel.toggleBookmark(tip)
                } label: {
                    Image(systemName: tip.isBookmarked ? "bookmark.fill" : "bookmark")
                }
                .accessibilityLabel(tip.isBookmarked ? "Remove bookmark" : "Bookmark this guide")
                .sensoryFeedback(.selection, trigger: tip.isBookmarked)
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Label(tip.learnCategory.title, systemImage: tip.learnCategory.systemImage)
                    .font(PawprintTheme.font(.subheadline, weight: .semibold))
                    .foregroundStyle(PawprintTheme.accent)
                Text("\(tip.readingMinutes) min read")
                    .font(PawprintTheme.font(.subheadline))
                    .foregroundStyle(PawprintTheme.textSecondary)
            }

            Text(tip.title)
                .font(PawprintTheme.displayFont(.title))
                .foregroundStyle(PawprintTheme.accentDeep)
                .accessibilityAddTraits(.isHeader)

            Text(tip.summary)
                .font(PawprintTheme.font(.headline, weight: .semibold))
                .foregroundStyle(PawprintTheme.textSecondary)
        }
    }

    private var keyPointsCard: some View {
        PawprintCard {
            VStack(alignment: .leading, spacing: 10) {
                Text("Key points")
                    .font(PawprintTheme.font(.headline, weight: .bold))
                    .foregroundStyle(PawprintTheme.textPrimary)
                    .accessibilityAddTraits(.isHeader)

                ForEach(tip.keyPoints, id: \.self) { point in
                    HStack(alignment: .firstTextBaseline, spacing: 10) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(PawprintTheme.success)
                            .accessibilityHidden(true)
                        Text(point)
                            .font(PawprintTheme.font(.subheadline))
                            .foregroundStyle(PawprintTheme.textPrimary)
                    }
                }
            }
        }
    }
}

#Preview {
    let repositories = PawprintRepositories.preview()
    try? SeedTipsUseCase(repository: repositories.tips).execute()
    let viewModel = LearnViewModel(repository: repositories.tips)
    viewModel.load()
    return NavigationStack {
        if let tip = viewModel.tips.first {
            TipDetailView(tip: tip, viewModel: viewModel)
        }
    }
    .environment(repositories)
}
