//
//  View+AutoScrollable.swift
//  TransactionalStore
//
//  Created by Vladyslav Kornieiev on 03/27/23.
//

import SwiftUI

/// View Modifier that allows to embed the content with `ScrollView` when it doesn't fit the screen.
struct OverflowContentViewModifier: ViewModifier {
    @State private var contentOverflow: Bool = false

    func body(content: Content) -> some View {
        GeometryReader { geometry in
            content
                .background(
                    GeometryReader {
                        Color.clear.preference(key: ViewHeightKey.self,
                                               value: $0.frame(in: .local).size.height)
                    }
                )
                .wrappedInScrollView(when: contentOverflow)
                .onPreferenceChange(ViewHeightKey.self) {
                    self.contentOverflow = $0 > geometry.size.height
                }
        }
    }

    private struct ViewHeightKey: PreferenceKey {
        static var defaultValue: CGFloat { 0 }
        static func reduce(value: inout Value, nextValue: () -> Value) {
            value = value + nextValue()
        }
    }
}

extension View {
    @ViewBuilder
    func wrappedInScrollView(when condition: Bool) -> some View {
        if condition {
            ScrollView { self }
        } else {
            self
        }
    }
}

extension View {
    /// Applies modifier to a view automatically embedding in `ScrollView` if content doesn't fit screen.
    @ViewBuilder
    func scrollOnOverflow(_ enabled: Bool = true) -> some View {
        if enabled {
            modifier(OverflowContentViewModifier())
        } else {
            self
        }
    }
}
