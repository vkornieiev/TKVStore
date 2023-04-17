//
//  TransactionalStoreViewModel.swift
//  TransactionalStore
//
//  Created by Vladyslav Kornieiev on 03/26/23.
//

import Combine
import SwiftUI

final class TransactionalStoreViewModel: ViewModel {
    typealias ViewEvent = TransactionalStoreViewEvent
    typealias ViewState = TransactionalStoreViewState
    
    /// ViewState to update UI based on view model business logic.
    @Published var state = ViewState()
    /// A delayed action that should be perfoormed on alert confirm.
    private var confirmedAlertAction: (() -> Void)?
    /// Key-Value based transaction storage.
    private let transactionStorage: TransactionalStoreProtocol

    /// Random color to highlight output console and nested operations inticator.
    private var consoleOutputColor: Color {
        state.colors[state.storageNestingLevel % state.colors.count]
    }

    init(transactionStorage: TransactionalStoreProtocol = TransactionalStore()) {
        self.transactionStorage = transactionStorage
    }

    /// View events that are triggered by View and handled by ViewModel.
    /// This iplementation can be enchanced in future to be extracted to protocol as a requirement for each ViewModel
    func trigger(_ event: ViewEvent) {
        switch event {
        case .onGetAction:
            guard verifyInputData(key: true, value: false) == true else { return }
            self.addConsoleMessage("GET '\(state.key)'")
            transactionStorage.perfrom(.get(key: state.key, result: { [weak self] result in
                guard let self = self else { return }
                switch result {
                case let .success(value):
                    self.addConsoleMessage(value)
                case let .failure(error):
                    self.addConsoleMessage(error.localizedDescription, isError: true)
                }
                self.clearInputFields()
            }))

        case .onSetAction:
            guard verifyInputData(key: true, value: true) == true else { return }
            self.addConsoleMessage("SET '\(state.key)' '\(state.value)'")
            transactionStorage.perfrom(.set(key: state.key, value: state.value))
            clearInputFields()

        case .onDeleteAction:
            guard verifyInputData(key: true, value: false) == true else { return }
            let key = self.state.key
            confirmedAlertAction = { [weak self] in
                guard let self = self else { return }
                self.addConsoleMessage("DELETE '\(key)'")
                self.transactionStorage.perfrom(.delete(key: key))
                self.clearInputFields()
                self.confirmedAlertAction = nil
            }
            state.showConfirmDialog = true

        case .onCountAction:
            guard verifyInputData(key: false, value: true) == true else { return }
            self.addConsoleMessage("COUNT '\(state.value)'")
            transactionStorage.perfrom(.count(value: state.value, result: { [weak self] count in
                guard let self = self else { return }
                self.clearInputFields()
                self.addConsoleMessage("\(count)")
            }))

        case .onBeginAction:
            transactionStorage.perfrom(.begin)
            state.storageNestingLevel += 1
            addConsoleMessage("BEGIN")

        case .onCommitAction:
            confirmedAlertAction = { [weak self] in
                guard let self = self else { return }
                self.addConsoleMessage("COMMIT")
                self.transactionStorage.perfrom(.commit(result: { [weak self] result in
                    guard let self = self else { return }
                    switch result {
                    case .success:
                            self.addConsoleMessage("Commited successfully")
                            self.state.storageNestingLevel -= 1
                    case let .failure(error):
                        self.addConsoleMessage(error.localizedDescription, isError: true)
                    }
                    self.confirmedAlertAction = nil
                }))
            }
            state.showConfirmDialog = true

        case .onRollbackActionTapped:
            confirmedAlertAction = { [weak self] in
                guard let self = self else { return }
                self.addConsoleMessage("ROLLBACK")
                self.transactionStorage.perfrom(.rollback(result: { [weak self] result in
                    guard let self = self else { return }
                    switch result {
                    case .success:
                            self.addConsoleMessage("Discarded successfully")
                            self.state.storageNestingLevel -= 1
                    case let .failure(error):
                        self.addConsoleMessage(error.localizedDescription, isError: true)
                    }
                    self.confirmedAlertAction = nil
                }))
            }
            state.showConfirmDialog = true
        
        case .onConfirmOperationAction:
            confirmedAlertAction?()
            
        case .onClearConsoleAction:
            state.consoleOutput.removeAll()
            
        case .onDismissKeyboard:
            dismissKeyboard()
        }
    }

    /// Add a message to interactive console to display in the app.
    private func addConsoleMessage(_ message: String, isError: Bool = false) {
        state.consoleOutput.append(.init(text: message, isError: isError, color: consoleOutputColor))
    }

    /// Input data validator (key, value textfields).
    private func verifyInputData(key: Bool, value: Bool) -> Bool {
        var isValid = true
        if key && state.key.isEmpty {
            addConsoleMessage("Key is required", isError: true)
            isValid = false
        }
        if value && state.value.isEmpty {
            addConsoleMessage("Value is required", isError: true)
            isValid = false
        }
        return isValid
    }

    /// Dismis keayborad globally. (The simplest solution, compared to `focusState`)
    private func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                        to: nil, from: nil, for: nil)
    }

    /// Clear input fields after any storage operation is performed.
    private func clearInputFields() {
        state.key = ""
        state.value = ""
    }
}
