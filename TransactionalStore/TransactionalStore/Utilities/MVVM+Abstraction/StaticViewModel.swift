//
//  StaticViewModel.swift
//  TransactionalStore
//
//  Created by Vladyslav Kornieiev on 04/17/23.
//

/// Static ViewModel that can be used as within MVVM View to isolate view state from complex business logic.
/// Use Case: View Previews.
public final class StaticViewModel<ViewEvent, ViewState>: ViewModel, Identifiable {
    public var state: ViewState

    public init(state: ViewState) {
        self.state = state
    }

    public func trigger(_ event: ViewEvent) {}
}

public extension StaticViewModel where ViewState == Void {
    convenience init() {
        self.init(state: ())
    }
}
