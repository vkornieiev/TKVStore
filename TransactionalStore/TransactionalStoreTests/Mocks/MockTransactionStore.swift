//
//  MockTransactionalStore.swift
//  TransactionalStoreTests
//
//  Created by Vladyslav Kornieiev on 03/27/23.
//

@testable import TransactionalStore

final class MockTransactionalStore: TransactionalStoreProtocol {
    var calledOperation: TransactionalStoreOperation?
    var calledOperationsCount: Int = 0
    
    var testValue: String = ""
    var testValueCount: Int = 0
    
    func perfrom(_ operation: TransactionalStoreOperation) {
        calledOperation = operation
        calledOperationsCount += 1
        
        switch operation {
        case .get(_, result: let result):
            result(.success(testValue))
        case .count(_, result: let result):
            result(testValueCount)
        case let .commit(result):
            result(.success(true))
        case let .rollback(result):
            result(.success(true))
        case .set, .delete, .begin:
            break
        }
    }
}

extension TransactionalStoreOperation: Equatable {
    public static func == (lhs: TransactionalStoreOperation,
                           rhs: TransactionalStoreOperation) -> Bool {
        switch (lhs, rhs) {
        case (let .get(lhsKey, _), let .get(rhsKey, _)):
            return lhsKey == rhsKey
        case (let .set(lhsKey, lhsValue), let .set(rhsKey, rhsValue)):
            return lhsKey == rhsKey && lhsValue == rhsValue
        case (let .delete(lhsKey), let .delete(rhsKey)):
            return lhsKey == rhsKey
        case (let .count(lhsValue, _), let .count(rhsValue, _)):
            return lhsValue == rhsValue
        case (.begin, .begin):
            return true
        case (.commit, .commit):
            return true
        case (.rollback, .rollback):
            return true
        default:
            return false
        }
    }
}
