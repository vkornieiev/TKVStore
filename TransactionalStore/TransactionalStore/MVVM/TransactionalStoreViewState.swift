//
//  TransactionalStoreViewState.swift
//  TransactionalStore
//
//  Created by Vladyslav Kornieiev on 03/27/23.
//

import SwiftUI

/// TransactionalStore View view state to represent all the data affecting view appearance.
struct TransactionalStoreViewState {
    var key: String = ""
    var value: String = ""
    var consoleOutput = [OutputConsoleItem]()
    var storageNestingLevel: Int = .zero
    var showConfirmDialog: Bool = false

    struct OutputConsoleItem: Identifiable {
        let id = UUID()
        let text: String
        let isError: Bool
        let color: Color
    }
}
