//
//  SuggestBreedsUseCase.swift
//  Dashboard feature (Natalie)
//
//  Matches what the user has typed so far against the breed library.
//  Pure logic, no repository, so it is cheap to call on every keystroke.
//

import Foundation

struct SuggestBreedsUseCase {
    var breeds: [String] = BreedLibrary.common
    var limit = 3

    /// Breeds whose name, or any word in it, starts with the query. Empty when
    /// nothing has been typed or the query already matches a breed exactly.
    func execute(query: String) -> [String] {
        let typed = query.trimmingCharacters(in: .whitespaces).lowercased()
        guard !typed.isEmpty else { return [] }
        guard !breeds.contains(where: { $0.lowercased() == typed }) else { return [] }

        return breeds
            .filter { breed in
                breed.lowercased().split(separator: " ").contains { $0.hasPrefix(typed) }
                    || breed.lowercased().hasPrefix(typed)
            }
            .prefix(limit)
            .map { $0 }
    }
}
