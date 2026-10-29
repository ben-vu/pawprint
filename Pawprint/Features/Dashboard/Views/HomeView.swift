//
//  HomeView.swift
//  Pawprint
//
//  Created by Natalie Michael on 21/10/2026.
//
//  Home tab: greeting card with the dog, today's progress ring and
//  today's routine tasks. Tap the circle on a task to tick it off (or
//  untick it).
//

import SwiftUI

struct HomeView: View {
    @Environment(PawprintRepositories.self) private var repositories
    @AppStorage(ActiveDogSelection.storageKey) private var selectedDogID = ""
    @State private var viewModel: DashboardViewModel?
    @State private var completeFeedback = 0

    var body: some View {
        NavigationStack {
            ZStack {
                PawprintTheme.background.ignoresSafeArea()
                if let viewModel {
                    PugAtBottom { pugInList in
                        ScrollView {
                            VStack(spacing: 18) {
                                heroCard(viewModel)
                                progressCard(viewModel)
                                todaySection(viewModel)
                                if pugInList { BottomPug() }
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                        }
                        .refreshable { viewModel.load() }
                    }
                }
            }
            .navigationTitle("Home")
            .toolbarTitleDisplayMode(.inlineLarge)   // title level with the toolbar, no empty band above it
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    DogSwitcherMenu()
                }
                .sharedBackgroundVisibility(.hidden)
            }
            .onChange(of: selectedDogID) { viewModel?.load() }
        }
        .task {
            if viewModel == nil {
                viewModel = DashboardViewModel(
                    dogs: repositories.dogs,
                    routines: repositories.routines,
                    notifications: UserNotificationService.shared
                )
            }
            viewModel?.load()
        }
        // Tasks ticked off in the widget while the app was closed.
        .onReceive(NotificationCenter.default.publisher(for: .widgetCompletionsApplied)) { _ in
            viewModel?.load()
        }
        .sensoryFeedback(.success, trigger: completeFeedback)
    }

    private func heroCard(_ vm: DashboardViewModel) -> some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(alignment: .leading, spacing: 6) {
                Text(vm.greeting.uppercased())
                    .font(PawprintTheme.font(.caption, weight: .heavy))
                    .tracking(1)
                    .foregroundStyle(PawprintTheme.textSecondary)
                Text(vm.dog?.name ?? "Your dog")
                    .font(PawprintTheme.displayFont(.largeTitle))
                    .foregroundStyle(PawprintTheme.accentDeep)
                    .lineLimit(2)
                    .minimumScaleFactor(0.7)
                if let dog = vm.dog {
                    Text(dog.breedDescription)
                        .font(PawprintTheme.font(.subheadline, weight: .semibold))
                        .foregroundStyle(PawprintTheme.textSecondary)
                }
                Text(vm.progress.isAllDone ? "Everything's done. Treat time." : "Let's make today a good one.")
                    .font(PawprintTheme.font(.footnote, weight: .semibold))
                    .foregroundStyle(PawprintTheme.accent)
                    .padding(.top, 4)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(20)
            .padding(.trailing, 120)

            Image(vm.progress.isAllDone ? "PugHappy" : "PugMain")
                .resizable()
                .scaledToFit()
                .frame(height: 120)
                .padding(.trailing, 12)
                .padding(.bottom, 6)
                .accessibilityHidden(true)
        }
        .frame(maxWidth: .infinity, minHeight: 160)
        .background(PawprintTheme.surface, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 22, style: .continuous).stroke(PawprintTheme.border.opacity(0.5), lineWidth: 1))
        .accessibilityElement(children: .combine)
    }

    private func progressCard(_ vm: DashboardViewModel) -> some View {
        PawprintCard {
            HStack(spacing: 18) {
                ProgressRingView(progress: vm.progress)
                    .frame(width: 84, height: 84)
                VStack(alignment: .leading, spacing: 4) {
                    Text("Today's activities")
                        .font(PawprintTheme.font(.headline, weight: .semibold))
                        .foregroundStyle(PawprintTheme.textPrimary)
                    Text(progressMessage(vm.progress))
                        .font(PawprintTheme.font(.subheadline))
                        .foregroundStyle(PawprintTheme.textSecondary)
                }
                Spacer(minLength: 0)
            }
        }
    }

    private func todaySection(_ vm: DashboardViewModel) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("TODAY")
                .font(PawprintTheme.font(.caption, weight: .heavy))
                .tracking(1)
                .foregroundStyle(PawprintTheme.textSecondary)
                .padding(.horizontal, 4)

            if let error = vm.errorMessage {
                Label(error, systemImage: "exclamationmark.circle.fill")
                    .font(PawprintTheme.font(.footnote, weight: .semibold))
                    .foregroundStyle(PawprintTheme.danger)
                    .padding(.horizontal, 4)
            }

            if vm.todaysTasks.isEmpty {
                PawprintCard {
                    PugEmptyState(
                        image: "PugLying",
                        animation: "SleepyPug",
                        title: "Nothing scheduled yet",
                        message: "Add a walk or a meal in the Routines tab and it will show up here."
                    )
                }
            } else {
                VStack(spacing: 10) {
                    ForEach(vm.todaysTasks) { task in
                        taskRow(task, vm: vm)
                    }
                }
            }
        }
    }

    private func taskRow(_ task: RoutineTask, vm: DashboardViewModel) -> some View {
        PawprintCard {
            HStack(spacing: 14) {
                Button {
                    if task.isCompleted {
                        vm.uncomplete(task)
                    } else {
                        vm.complete(task)
                        completeFeedback += 1
                    }
                } label: {
                    Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                        .font(PawprintTheme.font(.title2))
                        .foregroundStyle(task.isCompleted ? PawprintTheme.success : PawprintTheme.border)
                        .frame(width: 44, height: 44)   // full-size tap target, same as the Routines tab
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(task.isCompleted ? "Mark \(task.title) as not done" : "Mark \(task.title) as done")

                VStack(alignment: .leading, spacing: 2) {
                    Text(task.title)
                        .font(PawprintTheme.font(.body, weight: .semibold))
                        .foregroundStyle(PawprintTheme.textPrimary)
                        .strikethrough(task.isCompleted, color: PawprintTheme.textSecondary)
                    Text(task.dueDate, style: .time)
                        .font(PawprintTheme.font(.footnote))
                        .foregroundStyle(PawprintTheme.textSecondary)
                }
                Spacer(minLength: 0)
            }
        }
        .opacity(task.isCompleted ? 0.7 : 1)
    }

    private func progressMessage(_ p: TodayProgress) -> String {
        switch (p.total, p.completed) {
        case (0, _): return "No activities planned for today."
        case let (t, c) where c == t: return "All \(t) done. Nice work."
        case let (t, c): return "\(t - c) left to go."
        }
    }
}

#Preview {
    HomeView()
        .environment(PawprintRepositories.preview())
}
