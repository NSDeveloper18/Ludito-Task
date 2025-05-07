//
//  BottomViewModifier.swift
//  Ludito Task
//
//  Created by Shakhzod Botirov on 07/05/25.
//

import Foundation
import SwiftUI

struct BottomViewModifier: ViewModifier {
    @State private var sheetHeight: CGFloat = .zero
    @State private var selectedDetent: PresentationDetent = .medium

    func body(content: Content) -> some View {
        content
            .overlay {
                GeometryReader { geometry in
                    Color.clear.preference(key: InnerHeightPreferenceKey.self, value: geometry.size.height)
                }
            }
            .onPreferenceChange(InnerHeightPreferenceKey.self) { newHeight in
                sheetHeight = newHeight
                selectedDetent = .height(sheetHeight)
            }
            .presentationDetents([.height(sheetHeight)], selection: $selectedDetent)
    }
}

struct InnerHeightPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = .zero
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
