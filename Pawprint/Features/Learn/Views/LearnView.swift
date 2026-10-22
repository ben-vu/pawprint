//
//  LearnView.swift
//  Pawprint
//
//  Created by Benjamin Vu on 21/10/2026.
//
//  Entry view for the Learn tab: search, category chips and a list of
//  beginner guides. All logic lives in LearnViewModel.
//

import SwiftUI
import SwiftData

struct LearnView: View {
    @Environment(\.modelContext) private var context
    @Environment(AppRouter.self) private var router: AppRouter?
    @State private var viewModel: LearnViewModel?
    @State private var path: [LearnTip] = []

    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                PawprintTheme.background.ignoresSafeArea()
                if let viewModel {
                    LearnContentView(viewModel: viewModel)
                } else {
                    ProgressView()
                }
            }
            .navigationTitle("Learn")
            .toolbarTitleDisplayMode(.inlineLarge)
            .navigationDestination(for: LearnTip.self) { tip in
                if let viewModel {
                    TipDetailView(tip: tip, viewModel: viewModel)
                }
            }
        }
        .task {
            guard viewModel == nil else { return }
            let model = LearnViewModel(repository: SwiftDataTipRepository(context: context))
            model.load()
            viewModel = model
            openPendingGuide()
        }
        .onChange(of: router?.pendingTipID) { openPendingGuide() }
    }

    /// Opens the guide a widget or the Health tab asked for.
    private func openPendingGuide() {
        guard let router, let id = router.pendingTipID, let viewModel else { return }
        router.pendingTipID = nil
        if let tip = viewModel.tip(withContentID: id) {
            viewModel.selectedFilter = .all
            viewModel.searchText = ""
            viewModel.refresh()
            path = [tip]
        }
    }
}

private struct LearnContentView: View {
    @Bindable var viewModel: LearnViewModel

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 14) {
                CategoryFilterBar(selection: $viewModel.selectedFilter)

                if viewModel.tips.isEmpty {
                    emptyState
                } else {
                    ForEach(viewModel.tips) { tip in
                        TipCardView(tip: tip) {
                            viewModel.toggleBookmark(tip)
                        }
                    }
                }
            }
            .padding(.bottom, 24)
        }
        .scrollDismissesKeyboard(.interactively)
        .searchable(text: $viewModel.searchText, prompt: "Search tips and guides")
        .onChange(of: viewModel.searchText) { viewModel.refresh() }
        .onChange(of: viewModel.selectedFilter) { viewModel.refresh() }
        .alert("Something went wrong", isPresented: errorIsShowing) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }

    @ViewBuilder
    private var emptyState: some View {
        if !viewModel.searchText.isEmpty {
            ContentUnavailableView.search(text: viewModel.searchText)
        } else if viewModel.selectedFilter == .bookmarked {
            ContentUnavailableView(
                "No saved tips yet",
                systemImage: "bookmark",
                description: Text("Tap the bookmark on any guide to keep it here for later.")
            )
        } else {
            ContentUnavailableView(
                "No tips here yet",
                systemImage: "book.closed",
                description: Text("Check back soon for new guides.")
            )
        }
    }

    private var errorIsShowing: Binding<Bool> {
        Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )
    }
}

#Preview {
    LearnView()
        .modelContainer(for: LearnTip.self, inMemory: true)
}
