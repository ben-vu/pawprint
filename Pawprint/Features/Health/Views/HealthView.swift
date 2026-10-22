//
//  HealthView.swift
//  Health feature (Alik)
//
//  Placeholder entry view. Replace the
// body, keep the name.


import SwiftUI
import SwiftData

struct HealthView: View {
    @Environment(\.modelContext) private var context

    var body: some View {
        NavigationStack {
            ZStack {
                PawprintTheme.background.ignoresSafeArea()
                Text("Health")
                    .font(PawprintTheme.displayFont())
                    .foregroundStyle(PawprintTheme.accentDeep)
            }
            .navigationTitle("Health")
        }
    }
}

#Preview {
    HealthView()
        .modelContainer(for: HealthRecord.self, inMemory: true)
}
