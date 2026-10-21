//
//  DeleteDogUseCase.swift
//  pawprint
//
//  Created by Natalie Michael on 21/10/2026.
//

import Foundation

struct DeleteDogUseCase {
    let repository: DogRepository

    func execute(_ dog: Dog) throws {
        try repository.delete(dog)
    }
}
