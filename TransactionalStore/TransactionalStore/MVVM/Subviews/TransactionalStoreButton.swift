//
//  TransactionalStoreButton.swift
//  TransactionalStore
//
//  Created by Vladyslav Kornieiev on 03/26/23.
//

import SwiftUI

struct TransactionalStoreButton: View {
    let title: String
    let color: Color
    let enabled: Bool
    let action: () -> Void
    
    init(title: String, color: Color, enabled: Bool = true, action: @escaping () -> Void) {
        self.title = title
        self.color = color
        self.enabled = enabled
        self.action = action
    }
    
    var body: some View {
        Button {
            action()
        } label: {
            Text(title)
                .fontWeight(.bold)
                .foregroundColor(Color.white)
                .frame(maxWidth: .infinity)
                .frame(height: 40)
        }
        .disabled(!enabled)
        .background(color.opacity(enabled ? 1 : 0.5))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
