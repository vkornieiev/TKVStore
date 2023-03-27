//
//  TransactionalStoreError.swift
//  TransactionalStore
//
//  Created by Vladyslav Kornieiev on 03/26/23.
//

import Foundation

/// TransactionalStore errors enumerations with user friendly description.
enum TransactionalStoreError: LocalizedError {
    case valueNotFound(key: String)
    case nothingToCommit
    case nothingToDiscard

    var errorDescription: String? {
        switch self {
        case let .valueNotFound(key):
            return "No record is found for key '\(key)'."
        case .nothingToCommit:
            return "Nothing to commit. No transaction(s) pending."
        case .nothingToDiscard:
            return "Nothing to discard. No transaction(s) pending."
        }
    }
}
