//
//  AddHealthRecordView.swift
//  Health feature (Alik)
//

import SwiftUI
import SwiftData

struct AddHealthRecordView: View {
    @Environment(\.dismiss) var dismiss
    @Bindable var viewModel: HealthViewModel
    
    @State var title = ""
    @State var date = Date()
    @State var hasDueDate = false
    @State var nextDueDate = Date()
    @State var notes = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section("What happened?") {
                    TextField("e.g. rabies vaccine, canine distemper shot", text: $title)
                    DatePicker("Date Given", selection: $date, in: ...Date(), displayedComponents: .date)
                }
                
                Section("Next Due Date") {
                    Toggle("Schedule a follow-up appointment?", isOn: $hasDueDate)
                        .tint(PawprintTheme.accent)
                    if hasDueDate {
                        DatePicker("Next Due", selection: $nextDueDate, in: Date()..., displayedComponents: .date)
                    }
                }
                
                Section("Notes") {
                    TextField("Any extra details", text: $notes, axis: .vertical)
                }
            }
            .navigationTitle("Add Health Record")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        viewModel.addAHealthRecord(
                            title: title,
                            date: date,
                            nextDueDate: hasDueDate ? nextDueDate : nil,
                            notes: notes
                        )
                        dismiss()
                    }
                    .fontWeight(.bold)
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Dog.self, HealthRecord.self, configurations: config)
    let repo = SwiftDataHealthRepository(context: container.mainContext)
    
    let sampleDog = Dog(name: "Buddy", breed: "Labrador", ageYears: 3, weightKg: 25.0)
    let viewModel = HealthViewModel(repository: repo, dog: sampleDog)
    
    AddHealthRecordView(viewModel: viewModel)
}
