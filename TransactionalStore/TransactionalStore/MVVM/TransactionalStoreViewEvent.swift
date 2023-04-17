//
//  TransactionalStoreViewEvent.swift
//  TransactionalStore
//
//  Created by Vladyslav Kornieiev on 03/26/23.
//

/// List of TransactionalStoreView events
enum TransactionalStoreViewEvent {
    case onGetAction
    case onSetAction
    case onDeleteAction
    case onCountAction
    case onBeginAction
    case onCommitAction
    case onRollbackActionTapped
    case onConfirmOperationAction
    case onClearConsoleAction
    case onDismissKeyboard
}
