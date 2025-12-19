//
//  StoreButtonStyle.swift
//
//  Created on 18.12.2025.
//  Copyright © 2025 IGR Soft. All rights reserved.
//

import SwiftUI

/// A custom button style for the developer support store.
///
/// Applies hover effects and uses the configured colors.
public struct StoreButtonStyle: ButtonStyle {
    private let colors: StoreColors
    private let layout: StoreLayoutConstants

    /// Creates a new store button style.
    ///
    /// - Parameters:
    ///   - colors: The color configuration.
    ///   - layout: The layout constants.
    public init(colors: StoreColors, layout: StoreLayoutConstants) {
        self.colors = colors
        self.layout = layout
    }

    public func makeBody(configuration: Configuration) -> some View {
        StoreButtonStyleView(
            colors: colors,
            layout: layout,
            isPressed: configuration.isPressed
        ) {
            configuration.label
        }
    }
}

private struct StoreButtonStyleView<Content: View>: View {
    @Environment(\.isEnabled) private var isEnabled: Bool
    @State private var isHovered = false

    let colors: StoreColors
    let layout: StoreLayoutConstants
    let isPressed: Bool
    let content: () -> Content

    var body: some View {
        content()
            .foregroundColor(isEnabled ? colors.primaryText : colors.secondaryText)
            .background {
                if !isEnabled {
                    RoundedRectangle(cornerRadius: layout.radiusBig)
                        .fill(colors.buttonBackground.opacity(0.5))
                } else {
                    RoundedRectangle(cornerRadius: layout.radiusBig)
                        .fill(isHovered ? colors.buttonHovered : colors.buttonBackground)
                }
            }
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: isPressed)
            .onHover { hovering in
                isHovered = hovering
            }
    }
}

// MARK: - Button Style Extension

extension ButtonStyle where Self == StoreButtonStyle {
    /// A store button style with the default colors and layout.
    public static var store: StoreButtonStyle {
        StoreButtonStyle(colors: .default, layout: .default)
    }

    /// A store button style with custom colors and layout.
    ///
    /// - Parameters:
    ///   - colors: The color configuration.
    ///   - layout: The layout constants.
    public static func store(colors: StoreColors, layout: StoreLayoutConstants) -> StoreButtonStyle {
        StoreButtonStyle(colors: colors, layout: layout)
    }
}
