//
//  DomainError.swift
//  pawprint
//
//  Created by Natalie Michael on 21/10/2026.
//
//  Every feature's error enum adopts this so views can show errors the
//  same way everywhere. Example:
//
//  enum DogError: DomainError {
//      case emptyName
//      var errorDescription: String? { "Please give your dog a name." }
//  }
//

import Foundation

protocol DomainError: LocalizedError, Equatable {}
