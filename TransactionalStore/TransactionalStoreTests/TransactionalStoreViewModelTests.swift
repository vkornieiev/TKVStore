//
//  TransactionalStoreViewModelTests.swift
//  TransactionalStoreTests
//
//  Created by Vladyslav Kornieiev on 03/27/23.
//

import XCTest
@testable import TransactionalStore

final class TransactionalStoreViewModelTests: XCTestCase {
    var sut: TransactionalStoreViewModel!
    var transactionalStorageMock: MockTransactionalStore!
    
    override func setUp() {
        transactionalStorageMock = MockTransactionalStore()
        sut = TransactionalStoreViewModel(transactionStorage: transactionalStorageMock)
    }

    func test_GET_ActionCalled_And_InputFields_NOT_Empty() {
        // When
        let key = "key"
        let value = "value"
        transactionalStorageMock.testValue = value
        sut.state.key = key
        
        // Then
        sut.trigger(.onGetAction)
        
        // Verify
        XCTAssertEqual(transactionalStorageMock.calledOperation, .get(key: key, result: {_ in}))
        XCTAssertEqual(transactionalStorageMock.calledOperationsCount, 1)
        XCTAssertTrue(sut.state.consoleOutput.contains(where: {$0.text == value }))
    }
    
    func test_GET_ActionCalled_And_InputFields_Empty() {
        // When
        let key = ""
        sut.state.key = key
        
        // Then
        sut.trigger(.onGetAction)
        
        // Verify
        XCTAssertEqual(transactionalStorageMock.calledOperation, nil)
        XCTAssertEqual(transactionalStorageMock.calledOperationsCount, 0)
        XCTAssertTrue(sut.state.consoleOutput.contains(where: {$0.isError == true }))
    }
    
    func test_SET_ActionCalled_And_InputFields_NOT_Empty() {
        // When
        let key = "key"
        let value = "value"
        sut.state.key = key
        sut.state.value = value
        
        // Then
        sut.trigger(.onSetAction)
        
        // Verify
        XCTAssertEqual(transactionalStorageMock.calledOperation, .set(key: key, value: value))
        XCTAssertEqual(transactionalStorageMock.calledOperationsCount, 1)
        // Expect error output - 1 Key is requred
        XCTAssertEqual(sut.state.consoleOutput.count, 1)
    }
    
    func test_SET_ActionCalled_And_InputFields_Empty() {
        // When
        let key = ""
        let value = ""
        sut.state.key = key
        sut.state.value = value
        
        // Then
        sut.trigger(.onSetAction)
        
        // Verify
        XCTAssertEqual(transactionalStorageMock.calledOperation, nil)
        XCTAssertEqual(transactionalStorageMock.calledOperationsCount, 0)
        // Expect errors output - 2 : Key is requred, Value is required.
        XCTAssertEqual(sut.state.consoleOutput.count, 2)
    }
    
    /* Other events can be covered with the same manner.
     
    func test_DELETE_ActionCalled_And_InputFields_NOT_Empty() {
    }
    
    func test_DELETE_ActionCalled_And_InputFields_Empty() {
    }
    
    func test_COUNT_ActionCalled_And_InputFields_NOT_Empty() {
    }
    
    func test_COUNT_ActionCalled_And_InputFields_Empty() {
    }
    
    func test_BEGIN_ActionCalled_And_InputFields_NOT_Empty() {
    }
    
    func test_BEGIN_ActionCalled_And_InputFields_Empty() {
    }
    
    func test_COMMIT_ActionCalled_And_InputFields_NOT_Empty() {
    }
    
    func test_COMMIT_ActionCalled_And_InputFields_Empty() {
    }
    
    func test_ROLLBACK_ActionCalled_And_InputFields_NOT_Empty() {
    }
    
    func test_ROLLBACK_ActionCalled_And_InputFields_Empty() {
    }
    
    func test_Clear_Console_ActionCalled() {
    }
     
    */
}
