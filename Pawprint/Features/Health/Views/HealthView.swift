//
//  HealthView.swift
//  Health feature (Alik)
//
//  Placeholder entry view. Replace the
// body, keep the name.


import SwiftUI
import SwiftData

struct HealthView: View {
    @Environment(\.modelContext) var context
    @State var viewModel: HealthViewModel?
    @State var showingAddSheet = false
    
    let dog: Dog
    
    var body: some View {
        ZStack {
            PawprintTheme.background.ignoresSafeArea()
            
            if let viewModel = viewModel {
                if viewModel.records.isEmpty {
                    ContentUnavailableView(
                        "No Health Records",
                        systemImage: "heart.text.square",
                        description: Text("Tap the + button to add a vaccination for \(dog.name).")
                    )
                } else {
                    List {
                        if !viewModel.overdueRecords.isEmpty {
                            Section("Overdue Treatments") {
                                ForEach(viewModel.overdueRecords) { record in
                                    Text(record.title)
                                        .foregroundStyle(.red)
                                        .fontWeight(.semibold)
                                }
                            }
                        }
                        
                        Section("History") {
                            ForEach(viewModel.records) { record in
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(record.title)
                                        .font(.headline)
                                    
                                    Text(record.date, style: .date)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                    
                                    if let dueDate = record.nextDueDate {
                                        Text("Due: \(dueDate, style: .date)")
                                            .font(.caption)
                                            .foregroundStyle(dueDate < Date() ? .red : PawprintTheme.accent)
                                    }
                                }
                                .padding(.vertical, 4)
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        viewModel.deleteRecord(record)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                            }
                        }
                    }
                    .scrollContentBackground(.hidden)
                }
            } else {
                ProgressView()
            }
        }
        .navigationTitle("\(dog.name)'s Health Record")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingAddSheet = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .onAppear {
            if viewModel == nil {
                let repo = SwiftDataHealthRepository(context: context)
                viewModel = HealthViewModel(repository: repo, dog: dog)
                viewModel?.load()
            }
        }
        .sheet(isPresented: $showingAddSheet) {
            if let viewModel = viewModel {
                AddHealthRecordView(viewModel: viewModel)
            }
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Dog.self, HealthRecord.self, configurations: config)
    let sampleDog = Dog(name: "Buddy", breed: "Labrador", ageYears: 3, weightKg: 25.0)
    
    return NavigationStack {
        HealthView(dog: sampleDog)
    }
    .modelContainer(container)
}
