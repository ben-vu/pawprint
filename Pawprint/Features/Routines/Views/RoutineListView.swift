//
//  RoutineListView.swift
//  Pawprint
//
//  Created by Sana Yousefi on 22/10/2026.
//
//  Routines tab: overdue, today and upcoming tasks. Tap the circle to
//  tick a task off (or untick it), tap the row to edit, swipe left to
//  delete, + to add a new routine.
//

import SwiftUI

struct RoutineListView: View {
    @Environment(PawprintRepositories.self) private var repositories
    @AppStorage(ActiveDogSelection.storageKey) private var selectedDogID = ""
    @State private var dogs: [Dog] = []
    @State private var viewModel: RoutineViewModel?
    @State private var showAdd = false
    @State private var editing: RoutineTask?
    @State private var completeFeedback = 0
    @State private var justAdded = false          // set by the add sheet, read when it closes
    @State private var showCelebration = false

    var body: some View {
        NavigationStack {
            ZStack {
                PawprintTheme.background.ignoresSafeArea()
                if let viewModel {
                    if viewModel.isEmpty {
                        emptyState
                    } else {
                        list(viewModel)
                    }
                }
            }
            .navigationTitle("Routines")
            .toolbarTitleDisplayMode(.inlineLarge)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    ToolbarCircleButton(systemImage: "plus", label: "Add routine") { showAdd = true }
                }
                .sharedBackgroundVisibility(.hidden)
            }
            .sheet(isPresented: $showAdd, onDismiss: {
                viewModel?.load()
                if justAdded {
                    justAdded = false
                    withAnimation { showCelebration = true }   // after the sheet has gone, so it isn't hidden
                }
            }) {
                AddRoutineView(onAdded: { justAdded = true })
            }
            .sheet(item: $editing, onDismiss: { viewModel?.load() }) { task in
                AddRoutineView(task: task)
            }
        }
        .overlay {
            if showCelebration {
                RoutineAddedCelebration {
                    withAnimation { showCelebration = false }
                }
                .transition(.opacity)
            }
        }
        .task {
            if viewModel == nil {
                viewModel = RoutineViewModel(
                    repository: repositories.routines,
                    notifications: UserNotificationService.shared
                )
            }
            viewModel?.load()
            reloadDogs()
        }
        .onChange(of: selectedDogID) {
            viewModel?.load()
            reloadDogs()
        }
        .onReceive(NotificationCenter.default.publisher(for: .pawprintDogsDidChange)) { _ in reloadDogs() }
        // Tasks ticked off in the widget while the app was closed.
        .onReceive(NotificationCenter.default.publisher(for: .widgetCompletionsApplied)) { _ in
            viewModel?.load()
        }
        .sensoryFeedback(.success, trigger: completeFeedback)
        .tint(PawprintTheme.accent)
    }

    private func reloadDogs() {
        do { dogs = try repositories.dogs.fetchAll() }
        catch { viewModel?.errorMessage = error.localizedDescription }
    }

    /// Which dog's routines these are, for the empty state. Switch dogs from the Home tab.
    private var activeDogName: String {
        ActiveDogUseCase().activeDog(in: dogs, selectedID: UUID(uuidString: selectedDogID))?.name ?? ""
    }

    private var emptyState: some View {
        ScrollView {
            TitlePugRow(image: "PugRoutine")
                .padding(.leading, 20)   // lines up with the card
            PawprintCard {
                VStack(spacing: 14) {
                    PugEmptyState(
                        image: "PugLying",
                        animation: "SleepyPug",
                        title: activeDogName.isEmpty ? "No routines yet" : "\(activeDogName) has no routines yet",
                        message: "Add walks, meals and medication so nothing gets forgotten."
                    )
                    PrimaryButton(title: "Add a routine") { showAdd = true }
                }
            }
            .padding(20)
        }
    }

    private func list(_ vm: RoutineViewModel) -> some View {
        @Bindable var vm = vm
        return PugAtBottom { pugInList in
            List {
                let hasChips = vm.availableCategories.count > 1
                // Without chips the first heading sits beside the pug instead, so its section leaves it out.
                let headingBesidePug = hasChips ? nil : firstSectionTitle(vm)
                // Scrolls with the list, like Learn's chips, so the title bar doesn't sit over it.
                TitlePugRow(image: "PugRoutine") {
                    if hasChips {
                        FilterChipBar(
                            items: [nil] + vm.availableCategories.map { Optional($0) },
                            selection: $vm.categoryFilter,
                            title: { $0?.name ?? "All" },
                            systemImage: { $0?.systemImage ?? "list.bullet" }
                        )
                    } else if let headingBesidePug {
                        sectionHeader(headingBesidePug)
                            .padding(.leading, 12)
                            .padding(.bottom, 10)
                            .frame(maxHeight: .infinity, alignment: .bottom)
                    }
                }
                .padding(.leading, 16)
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: hasChips ? 14 : 4, trailing: 0))   // 14 = Learn's gap to its first card
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
                if let error = vm.errorMessage {
                    Label(error, systemImage: "exclamationmark.circle.fill")
                        .font(PawprintTheme.font(.footnote, weight: .semibold))
                        .foregroundStyle(PawprintTheme.danger)
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                }
                section("Overdue", tasks: vm.overdue, showsDate: true, showsHeader: headingBesidePug != "Overdue", vm: vm)
                section("Today", tasks: vm.todays, showsDate: false, showsHeader: headingBesidePug != "Today", vm: vm)
                section("Upcoming", tasks: vm.upcoming, showsDate: true, showsHeader: headingBesidePug != "Upcoming", vm: vm)
                if pugInList {
                    BottomPug()
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .contentMargins(.top, 0, for: .scrollContent)   // list starts right under the chips, like Learn
            .refreshable { vm.load() }
        }
    }

    @ViewBuilder
    private func section(_ title: String, tasks: [RoutineTask], showsDate: Bool, showsHeader: Bool, vm: RoutineViewModel) -> some View {
        if !tasks.isEmpty {
            Section {
                ForEach(tasks) { task in
                    RoutineRow(task: task, showsDate: showsDate, isOverdue: title == "Overdue") {
                        if task.isCompleted {
                            vm.uncomplete(task)
                        } else {
                            vm.complete(task)
                            completeFeedback += 1
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture { editing = task }
                    .accessibilityAction(named: "Edit") { editing = task }
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 5, leading: 16, bottom: 5, trailing: 16))   // same side inset as Learn's cards
                    .swipeActions {
                        Button(role: .destructive) {
                            vm.delete(task)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            } header: {
                if showsHeader {
                    sectionHeader(title)
                }
            }
        }
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title.uppercased())
            .font(PawprintTheme.font(.caption, weight: .heavy))
            .tracking(1)
            .foregroundStyle(title == "Overdue" ? PawprintTheme.danger : PawprintTheme.textSecondary)
    }

    /// The heading of the first section that has tasks, in list order.
    private func firstSectionTitle(_ vm: RoutineViewModel) -> String? {
        [("Overdue", vm.overdue), ("Today", vm.todays), ("Upcoming", vm.upcoming)]
            .first { !$0.1.isEmpty }?.0
    }
}

private struct RoutineRow: View {
    let task: RoutineTask
    let showsDate: Bool
    let isOverdue: Bool
    let onToggle: () -> Void

    var body: some View {
        PawprintCard {
            HStack(spacing: 14) {
                Button(action: onToggle) {
                    Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                        .font(PawprintTheme.font(.title2))
                        .foregroundStyle(task.isCompleted ? PawprintTheme.success : PawprintTheme.border)
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(task.isCompleted ? "Mark \(task.title) as not done" : "Mark \(task.title) as done")

                VStack(alignment: .leading, spacing: 3) {
                    Text(task.title)
                        .font(PawprintTheme.font(.body, weight: .semibold))
                        .foregroundStyle(PawprintTheme.textPrimary)
                        .strikethrough(task.isCompleted, color: PawprintTheme.textSecondary)
                    HStack(spacing: 6) {
                        Text(showsDate
                             ? task.dueDate.formatted(.dateTime.weekday(.abbreviated).day().month(.abbreviated).hour().minute())
                             : task.dueDate.formatted(date: .omitted, time: .shortened))
                            .foregroundStyle(isOverdue ? PawprintTheme.danger : PawprintTheme.textSecondary)
                        if task.recurrence != .once {
                            HStack(spacing: 3) {
                                Image(systemName: "repeat")
                                Text(task.repeatSummary)
                            }
                        }
                        if task.remindMe {
                            Image(systemName: "bell.fill")
                                .accessibilityLabel("Reminder on")
                        }
                    }
                    .font(PawprintTheme.font(.footnote))
                    .foregroundStyle(PawprintTheme.textSecondary)
                }

                Spacer(minLength: 0)

                Image(systemName: task.category.systemImage)
                    .font(PawprintTheme.font(.subheadline, weight: .semibold))
                    .foregroundStyle(PawprintTheme.accent)
                    .frame(minWidth: 44, minHeight: 44)
                    .background(PawprintTheme.surfaceRaised, in: Circle())
                    .accessibilityLabel(task.category.name)
            }
        }
        .opacity(task.isCompleted ? 0.7 : 1)
    }
}

#Preview {
    RoutineListView()
        .environment(PawprintRepositories.preview())
}
