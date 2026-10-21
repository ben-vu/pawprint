//
//  HomeView.swift
//  pawprint
//
//  Created by Natalie Michael on 21/10/2026.
//
//  Home tab: greeting card with the dog, today's progress ring and
//  today's routine tasks.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var context
    @State private var viewModel: DashboardViewModel?
    @State private var showProfile = false

    var body: some View {
        NavigationStack {
            ZStack {
                PawprintTheme.background.ignoresSafeArea()
                if let viewModel {
                    ScrollView {
                        VStack(spacing: 18) {
                            heroCard(viewModel)
                            progressCard(viewModel)
                            todaySection(viewModel)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                    }
                    .refreshable { viewModel.load() }
                }
            }
            .navigationTitle("Home")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showProfile = true
                    } label: {
                        DogAvatarView(photoData: viewModel?.dog?.photoData, size: 34)
                    }
                    .accessibilityLabel("Dog profile")
                    .disabled(viewModel?.dog == nil)
                }
            }
            .sheet(isPresented: $showProfile, onDismiss: { viewModel?.load() }) {
                if let dog = viewModel?.dog {
                    DogProfileView(dog: dog)
                }
            }
        }
        .task {
            if viewModel == nil {
                viewModel = DashboardViewModel(
                    dogs: SwiftDataDogRepository(context: context),
                    routines: SwiftDataRoutineRepository(context: context)
                )
            }
            viewModel?.load()
        }
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
                    Text(dog.breed.isEmpty ? "Good dog" : dog.breed)
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

            if vm.todaysTasks.isEmpty {
                PawprintCard {
                    PugEmptyState(
                        image: "PugLying",
                        title: "Nothing scheduled yet",
                        message: "Add a walk or a meal in the Routines tab and it will show up here."
                    )
                }
            } else {
                VStack(spacing: 10) {
                    ForEach(vm.todaysTasks) { task in
                        taskRow(task)
                    }
                }
            }
        }
    }

    private func taskRow(_ task: RoutineTask) -> some View {
        PawprintCard {
            HStack(spacing: 14) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(PawprintTheme.font(.title3))
                    .foregroundStyle(task.isCompleted ? PawprintTheme.success : PawprintTheme.border)
                    .accessibilityHidden(true)
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
        .accessibilityElement(children: .combine)
        .accessibilityValue(task.isCompleted ? "Done" : "Not done yet")
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
        .modelContainer(for: [Dog.self, RoutineTask.self], inMemory: true)
}
