//
//  Transaction.swift
//  TransactionalStore
//
//  Created by Vladyslav Kornieiev on 03/26/23.
//

/// Transaction implementation. Reperents every transaction in transactions store.
final class Transaction: TransactionProtocol {
    /// Internal storage, related to specific operation.
    var storage = Dictionary<String, String>()
    /// Keys, requested for deletion based on transaction actions performed,
    /// but absent in current transaction storage.
    var requestedUpstreamDeletions = Set<String>()

    func getValue(for key: String) -> String? {
        storage[key]
    }

    func set(_ value: String, for key: String) {
        storage[key] = value
        // Exclude the key from future delete request if present.
        requestedUpstreamDeletions.remove(key)
    }

    func removeValue(for key: String) {
        storage.removeValue(forKey: key)
        // If key is not presented in current transaction storage -
        // store it to later request to remove from upstream transaction.
        requestedUpstreamDeletions.insert(key)
    }

    func getCount(value: String) -> Int {
        storage.values.filter({ $0 == value }).count
    }
}
