//
//  TransactionalStoreApp.swift
//  TransactionalStore
//
//  Created by Vladyslav Kornieiev on 03/27/23.
//

import SwiftUI

@main
struct TransactionalStoreApp: App {
    var body: some Scene {
        WindowGroup {
            TransactionalStoreView(viewModel: TransactionalStoreViewModel())
        }
    }
}
