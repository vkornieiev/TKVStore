//
//  TransactionProtocol.swift
//  TransactionalStore
//
//  Created by Vladyslav Kornieiev on 03/26/23.
//

/// Transaction interface requirements.
protocol TransactionProtocol: AnyObject {
    var storage: Dictionary<String, String> { get set }
    var requestedUpstreamDeletions: Set<String> { get set }
    
    func getValue(for key: String) -> String?
    func set(_ value: String, for key: String)
    func removeValue(for key: String)
    func getCount(value: String) -> Int
}
