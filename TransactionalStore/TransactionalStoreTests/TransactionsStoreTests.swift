//
//  TransactionalStoreTests.swift
//  TransactionalStoreTests
//
//  Created by Vladyslav Kornieiev on 03/25/23.
//

import XCTest
@testable import TransactionalStore

final class TransactionalStoreTests: XCTestCase {

    var sut: TransactionalStore!
    var concurentQueue = DispatchQueue(label: "TransactionalStoreTests.queue", attributes: .concurrent)
    
    override func setUp() {
        sut = TransactionalStore()
    }

    func test_perform_GET_and_SET_operation() {
        expectValueToBe(nil, for: "key")
        sut.perfrom(.set(key: "key", value: "value"))
        expectValueToBe("value", for: "key")
    }
    
    func test_perform_successful_DELETE_after_SET_operation() {
        sut.perfrom(.set(key: "key", value: "value"))
        expectValueToBe("value", for: "key")
        sut.perfrom(.delete(key: "key"))
        expectValueToBe(nil, for: "key")
    }
    
    func test_Nested_Transaction_Overrides_Record() {
        sut.perfrom(.set(key: "key", value: "value"))
        sut.perfrom(.begin)
        sut.perfrom(.set(key: "key", value: "value1"))
        expectCommitToBe(true)
        expectValueToBe("value1", for: "key")
    }
    
    func test_Nested_Transaction_Deletes_Record() {
        sut.perfrom(.set(key: "key", value: "value"))
        sut.perfrom(.begin)
        sut.perfrom(.delete(key: "key"))
        expectCommitToBe(true)
        expectValueToBe(nil, for: "key")
    }
    
    func test_Nested_Transaction_Creates_NEW_Record() {
        expectValueToBe(nil, for: "key")
        sut.perfrom(.begin)
        sut.perfrom(.set(key: "key", value: "value"))
        expectCommitToBe(true)
        expectValueToBe("value", for: "key")
    }
    
    func test_Nested_Transaction_Discards_New_Record_WHEN_Rollback() {
        expectValueToBe(nil, for: "key")
        sut.perfrom(.begin)
        sut.perfrom(.set(key: "key", value: "value"))
        expectValueToBe("value", for: "key")
        expectRollbackToBe(true)
        expectValueToBe(nil, for: "key")
    }
    
    func test_Nested_Transaction_Discards_Override_Record_WHEN_Rollback() {
        sut.perfrom(.set(key: "key", value: "value"))
        expectValueToBe("value", for: "key")
        sut.perfrom(.begin)
        sut.perfrom(.set(key: "key", value: "value1"))
        expectValueToBe("value1", for: "key")
        expectRollbackToBe(true)
        expectValueToBe("value", for: "key")
    }
    
    func test_Nested_Transaction_Discards_Deletion_Record_WHEN_Rollback() {
        sut.perfrom(.set(key: "key", value: "value"))
        expectValueToBe("value", for: "key")
        sut.perfrom(.begin)
        sut.perfrom(.delete(key: "key"))
        expectValueToBe(nil, for: "key")
        expectRollbackToBe(true)
        expectValueToBe("value", for: "key")
    }
    
    func test_Perform_Multiple_Opations_IN_Multiple_Transactions() {
        sut.perfrom(.set(key: "key", value: "value"))
        expectCountToBe(1, for: "value")
        sut.perfrom(.set(key: "key1", value: "value"))
        expectCountToBe(2, for: "value")
        sut.perfrom(.delete(key: "key"))
        expectCountToBe(1, for: "value")
        sut.perfrom(.begin)
        sut.perfrom(.set(key: "key2", value: "value"))
        expectCountToBe(2, for: "value")
        sut.perfrom(.begin)
        sut.perfrom(.delete(key: "key"))
        expectCountToBe(1, for: "value")
        expectRollbackToBe(true)
        expectCountToBe(2, for: "value")
        expectCommitToBe(true)
        expectCountToBe(2, for: "value")
        expectValueToBe(nil, for: "key")
        expectCommitToBe(false)
        sut.perfrom(.set(key: "key1", value: "value1"))
        sut.perfrom(.set(key: "key2", value: "value1"))
        expectCountToBe(0, for: "value")
        expectRollbackToBe(false)
    }
    
    func test_Override_AND_Remove_Value_From_Nested_Transaction() {
        sut.perfrom(.set(key: "foo", value: "123"))
        sut.perfrom(.begin)
        sut.perfrom(.set(key: "foo", value: "456"))
        sut.perfrom(.delete(key: "foo"))
        expectCommitToBe(true)
        expectValueToBe(nil, for: "foo")
    }
    
    private func expectValueToBe(_ expectedValue: String?, for key: String) {
        let expectation = expectation(description: "TransactionalStoreTestsExpectation")
        sut.perfrom(.get(key: key, result: { result in
            // Verify
            switch result {
            case let .success(value):
                XCTAssertEqual(expectedValue, value)
            case .failure:
                XCTAssertTrue(expectedValue == nil)
            }
            expectation.fulfill()
        }))
        waitForExpectations(timeout: 1)
    }
    
    private func expectCountToBe(_ expectedCount: Int, for value: String) {
        let expectation = expectation(description: "TransactionalStoreTestsExpectation")
        sut.perfrom(.count(value: value, result: { result in
            // Verify
            XCTAssertEqual(expectedCount, result)
            expectation.fulfill()
        }))
        waitForExpectations(timeout: 1)
    }
    
    private func expectCommitToBe(_ success: Bool) {
        let expectation = expectation(description: "TransactionalStoreTestsExpectation")
        sut.perfrom(.commit(result: { result in
            // Verify
            switch result {
            case let .success(value):
                XCTAssertEqual(success, value)
            case .failure:
                XCTAssertTrue(success == false)
            }
            expectation.fulfill()
        }))
        waitForExpectations(timeout: 1)
    }
    
    private func expectRollbackToBe(_ success: Bool) {
        let expectation = expectation(description: "TransactionalStoreTestsExpectation")
        sut.perfrom(.rollback(result: { result in
            // Verify
            switch result {
            case let .success(value):
                XCTAssertEqual(success, value)
            case .failure:
                XCTAssertTrue(success == false)
            }
            expectation.fulfill()
        }))
        waitForExpectations(timeout: 1)
    }
}

extension TransactionalStoreError: Equatable {
    public static func == (lhs: TransactionalStoreError, rhs: TransactionalStoreError) -> Bool {
        switch (lhs, rhs) {
        case (let .valueNotFound(lhsKey), let .valueNotFound(rhsKey)):
            return lhsKey == rhsKey
        case (.nothingToCommit, .nothingToCommit):
            return true
        case (.nothingToDiscard, .nothingToDiscard):
            return true
        default:
            return false
        }
    }
}
