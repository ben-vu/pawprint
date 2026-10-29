import Foundation

/// Localized boundaries for persistent-store failures. Domain validation errors
/// are thrown by use cases; repository failures do not expose raw SwiftData errors.
nonisolated enum RepositoryStorageError: LocalizedError, Equatable {
    case readFailed
    case saveFailed
    case deleteFailed

    var errorDescription: String? {
        switch self {
        case .readFailed: return "Unable to load saved information. Please try again."
        case .saveFailed: return "Unable to save your changes. Please try again."
        case .deleteFailed: return "Unable to delete the item. Please try again."
        }
    }
}
