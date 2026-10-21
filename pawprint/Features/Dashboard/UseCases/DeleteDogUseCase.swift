//
//  DeleteDogUseCase.swift
//  Dashboard feature (Natalie)
//

import Foundation

struct DeleteDogUseCase {
    let repository: DogRepository

    func execute(_ dog: Dog) throws {
        try repository.delete(dog)
    }
}
