import Foundation
import Testing
@testable import Pawprint

struct RepositoryStorageErrorTests {
    @Test func dataAccessErrorsHaveSafeUserFacingMessages() {
        #expect(RepositoryStorageError.readFailed.localizedDescription.contains("load"))
        #expect(RepositoryStorageError.saveFailed.localizedDescription.contains("save"))
        #expect(RepositoryStorageError.deleteFailed.localizedDescription.contains("delete"))
        #expect(RepositoryStorageError.readFailed != RepositoryStorageError.saveFailed)
    }
}
