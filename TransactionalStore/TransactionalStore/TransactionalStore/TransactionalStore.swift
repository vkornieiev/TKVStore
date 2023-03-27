//
//  TransactionalStore.swift
//  TransactionalStore
//
//  Created by Vladyslav Kornieiev on 03/25/23.
//

import Foundation

/// Transaction Store implementation.
final class TransactionalStore: TransactionalStoreProtocol {
    /// Operation stack item representative (Linked List).
    private final class TransactionStackItem {
        let transaction: TransactionProtocol
        let next: TransactionStackItem?
        
        init(_ transaction: TransactionProtocol = Transaction(), next: TransactionStackItem? = nil) {
            self.transaction = transaction
            self.next = next
        }
    }

    private struct Constants {
        static let operationQueueLabel = "com.vkornieiev.transactionalstore.opearationqueue"
    }

    private let operationQueue: DispatchQueue
    private let resultQueue: DispatchQueue
    private var transactionsStack = TransactionStackItem()

    /// Parameters:
    /// `resultQueue: DispatchQueue`: a queue on chich the result will be execured. `Main` by default.
    init(resultQueue: DispatchQueue = .main) {
        self.resultQueue = resultQueue
        // A queue on which operations and transactions are performed.
        // The queue is defined as concurent and all sensitive operations are
        // performed under `barrier` protection to avoid data corrupttion and race conditions.
        self.operationQueue = DispatchQueue(label: Constants.operationQueueLabel,
                                            attributes: .concurrent)
    }

    /// Performs requested operation with the given type.
    func perfrom(_ operation: TransactionalStoreOperation) {
        // All sensitive operations are performed on the same queue under `barrier` protection
        // to avoid data corrupttion and race conditions.
        // Result is dispatched on Result queue (that is `Main` by default).
        switch operation {
        case let .get(key, result):
            operationQueue.async { [weak self] in
                guard let self = self else { return }
                let resultValue: Result<String, any Error>
                if let value = self.getValue(for: key) {
                    resultValue = .success(value)
                } else {
                    resultValue = .failure(TransactionalStoreError.valueNotFound(key: key))
                }
                self.resultQueue.async {
                    result(resultValue)
                }
            }

        case let .set(key, value):
            operationQueue.async(flags: .barrier) { [weak self] in
                guard let self = self else { return }
                self.set(value, for: key)
            }

        case let .delete(key):
            operationQueue.async(flags: .barrier) { [weak self] in
                guard let self = self else { return }
                self.removeValue(for: key)
            }

        case let .count(value, result):
            operationQueue.async { [weak self] in
                guard let self = self else { return }
                let count = self.getCount(value: value)
                self.resultQueue.async {
                    result(count)
                }
            }

        case .begin:
            operationQueue.async(flags: .barrier) { [weak self] in
                guard let self = self else { return }
                self.begin()
            }

        case let .commit(result):
            operationQueue.async(flags: .barrier) { [weak self] in
                guard let self = self else { return }
                let resultValue: Result<Bool, any Error>
                if self.commit() {
                    resultValue = .success(true)
                } else {
                    resultValue = .failure(TransactionalStoreError.nothingToCommit)
                }
                self.resultQueue.async {
                    result(resultValue)
                }
            }

        case let .rollback(result):
            operationQueue.async(flags: .barrier) { [weak self] in
                guard let self = self else { return }
                let resultValue: Result<Bool, any Error>
                if self.rollback() {
                    resultValue = .success(true)
                } else {
                    resultValue = .failure(TransactionalStoreError.nothingToDiscard)
                }
                self.resultQueue.async {
                    result(resultValue)
                }
            }
        }
    }

    /// Starts new transaction, link previous as pending (next) transaction.
    private func begin() {
        let transaction = Transaction()
        let item = TransactionStackItem(transaction, next: transactionsStack)
        transactionsStack = item
    }

    /// Commits the oprations from the active (top level) transaction and closes it.
    private func commit() -> Bool {
        let activeTransaction = transactionsStack
        if let next = transactionsStack.next {
            // 1. Try to remove all key-value pairs according `requestedUpstreamDeletions` set
            //    from the upstream upon the current transaction close.
            var pendingKeysToRemove = Set<String>()
            for keyToRemove in activeTransaction.transaction.requestedUpstreamDeletions {
                let res = next.transaction.storage.removeValue(forKey: keyToRemove)
                if res == nil {
                    pendingKeysToRemove.insert(keyToRemove)
                }
            }
            // 2. Merge current transaction storage with the upstream.
            //    The merge priority is set to the current transaction, meaning that all upstream
            //    duplications will be replaced with current transaction values.
            next.transaction.storage.merge(activeTransaction.transaction.storage, uniquingKeysWith: { $1 })
            // 3. Pass still pending items to remove to the upstream if exist for future deletion.
            next.transaction.requestedUpstreamDeletions = pendingKeysToRemove
            // 4. Finalize and release current top transaction by replacing it with next one (upstream).
            transactionsStack = next
            return true
        }
        return false
    }

    /// Reverts all oprations from the active (top level) transaction and closes the transaction.
    private func rollback() -> Bool {
        if let next = transactionsStack.next {
            // Finalize and release current top transaction by replacing it with next one (upstream).
            // No any other actions applied meaning that all the released transaciton actions will be lost.
            transactionsStack = next
            return true
        }
        return false
    }

    /// Returns the value globally by the `key` provided globally, according to the current transaction stack state.
    private func getValue(for key: String) -> String? {
        if let value = transactionsStack.transaction.getValue(for: key) {
            // 1. Return the value from the top transaction item if value is already overriden.
            return value
        } else if let globalValue = transactionsStack.next?.transaction.getValue(for: key),
                  transactionsStack.transaction.requestedUpstreamDeletions.contains(key) == false {
            // 2. Otherwise - try to find the value mooving upstream the transactions queue.
            return globalValue
        } else {
            // 3. Return `nil` if nothing found in a result.
            return nil
        }
    }

    /// Sets the `value` globally according to the `key` specified.
    private func set(_ value: String, for key: String) {
        // Set the value to the current (top) transaction.
        transactionsStack.transaction.set(value, for: key)
    }

    /// Removes the `value` globally if exists according to the `key` specified.
    private func removeValue(for key: String) {
        // Remove value from current (top) transaction.
        // If doesn't exist - it will be added to posponed deletion collection.
        transactionsStack.transaction.removeValue(for: key)
    }

    // Gets the could of `value` specified globally.
    private func getCount(value: String) -> Int {
        // 1. If no upstream available (current transaction is the only one) -
        //    just request count from it's storage.
        guard let backStackStorage = transactionsStack.next?.transaction.storage else {
            return transactionsStack.transaction.getCount(value: value)
        }
        // 2. Otherwise - count all values from the upstream by unique keys
        //    (to avoid possible duplicates between transactions).
        return backStackStorage
            .filter({ !transactionsStack.transaction.requestedUpstreamDeletions.contains($0.key) })
            .merging(transactionsStack.transaction.storage,
                     uniquingKeysWith: { $1 })
            .values
            .filter({ $0 == value })
            .count
    }
}
