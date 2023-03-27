//
//  TransactionalStoreProtocol.swift
//  TransactionalStore
//
//  Created by Vladyslav Kornieiev on 03/26/23.
//

/*
    NOTE: TransactionalStoreOperation can be easily extended with generic
          arguments type to support different key/value types
          (key should conform `Hashable`, value: Any)
 */

/// TransactionalStore interface requirements.
protocol TransactionalStoreProtocol {
    func perfrom(_ operation: TransactionalStoreOperation)
}

/// TransactionalStore possible operations enumeration requirements.
enum TransactionalStoreOperation {
    case get(key: String, result: (Result<String, any Error>) -> Void)
    case set(key: String, value: String)
    case delete(key: String)
    case count(value: String, result: (Int) -> Void)
    case begin
    case commit(result: (Result<Bool, any Error>) -> Void)
    case rollback(result: (Result<Bool, any Error>) -> Void)
}
