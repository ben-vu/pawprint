// Dependency composition: SwiftData is created only at the application boundary.
import Foundation
import Observation
import SwiftData

@MainActor
@Observable
final class PawprintRepositories {
    let dogs: any DogRepository
    let routines: any RoutineRepository
    let health: any HealthRepository
    let tips: any TipRepository

    init(container: ModelContainer) {
        let context = container.mainContext
        dogs = SwiftDataDogRepository(context: context)
        routines = SwiftDataRoutineRepository(context: context)
        health = SwiftDataHealthRepository(context: context)
        tips = SwiftDataTipRepository(context: context)
    }

    /// In-memory repositories for SwiftUI previews; no live database is accessed.
    static func preview() -> PawprintRepositories {
        let schema = Schema([Dog.self, RoutineTask.self, HealthRecord.self, LearnTip.self])
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: schema, configurations: configuration)
        return PawprintRepositories(container: container)
    }
}

extension Notification.Name {
    static let pawprintDogsDidChange = Notification.Name("pawprintDogsDidChange")
}
