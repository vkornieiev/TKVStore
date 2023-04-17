//
//  Color+Random.swift
//  TransactionalStore
//
//  Created by Vladyslav Kornieiev on 03/27/23.
//

import SwiftUI

extension Color {
    /// Returs random color.
    static var random: Color {
        return Color(red: .random(in: 0...1),
                     green: .random(in: 0...1),
                     blue: .random(in: 0...1))
    }

    /// Returs random list of color with the size specified.
    static func randomList(_ of: Int) -> [Color] {
        (0..<of).map { _ in Color.random }
    }
}
