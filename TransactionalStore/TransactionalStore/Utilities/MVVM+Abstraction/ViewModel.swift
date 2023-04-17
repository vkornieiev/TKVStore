//
//  ViewModel.swift
//  TransactionalStore
//
//  Created by Vladyslav Kornieiev on 04/17/23.
//

import Combine

/// Convenient way to ensure that all ViewModel's have a view state and handle view events properly.
public protocol ViewModel: ObservableObject where ObjectWillChangePublisher == ObservableObjectPublisher {
    associatedtype ViewEvent
    associatedtype ViewState
    
    var state: ViewState { get set }
    func trigger(_ event: ViewEvent)
}

public extension ViewModel where ViewEvent == Void {
    func trigger(_ event: ViewEvent) {}
}

public extension ViewModel where ViewEvent == Never {
    func trigger(_ event: ViewEvent) {}
}

public extension ViewModel where ViewState == Void {
    var state: ViewState { Void() }
}
