//
//  StoreColors.swift
//
//  Created on 18.12.2025.
//  Copyright © 2025 IGR Soft. All rights reserved.
//

import SwiftUI

#if canImport(AppKit)
import AppKit
#endif

/// Color configuration for the store views.
///
/// Provides all colors used in the DeveloperSupportStoreView.
/// Use `.default` for the original Colir app color scheme, or create
/// a custom instance to match your app's design.
public struct StoreColors: Sendable {
    /// Primary text color.
    public let primaryText: Color

    /// Secondary text color (for descriptions, captions).
    public let secondaryText: Color

    /// Secondary background color (for cards, containers).
    public let secondaryBackground: Color

    /// Accent color for selected/highlighted elements (heart icon, subscription card border).
    public let selectedView: Color

    /// Button background color.
    public let buttonBackground: Color

    /// Button background color when hovered.
    public let buttonHovered: Color

    /// Creates a new color configuration.
    ///
    /// - Parameters:
    ///   - primaryText: Primary text color.
    ///   - secondaryText: Secondary text color.
    ///   - secondaryBackground: Secondary background color for cards.
    ///   - selectedView: Accent color for highlights.
    ///   - buttonBackground: Button background color.
    ///   - buttonHovered: Button hover state color.
    public init(
        primaryText: Color,
        secondaryText: Color,
        secondaryBackground: Color,
        selectedView: Color,
        buttonBackground: Color,
        buttonHovered: Color
    ) {
        self.primaryText = primaryText
        self.secondaryText = secondaryText
        self.secondaryBackground = secondaryBackground
        self.selectedView = selectedView
        self.buttonBackground = buttonBackground
        self.buttonHovered = buttonHovered
    }

    /// Default colors from the original Colir app design.
    public static let `default` = StoreColors(
        primaryText: .white,
        secondaryText: Color(white: 156.0 / 255.0),
        secondaryBackground: Color(
            light: Color(white: 169.0 / 255.0),
            dark: Color(white: 64.0 / 255.0)
        ),
        selectedView: Color(
            red: 97.0 / 255.0,
            green: 197.0 / 255.0,
            blue: 85.0 / 255.0
        ),
        buttonBackground: Color(white: 81.0 / 255.0),
        buttonHovered: Color(
            light: Color.black.opacity(0.5),
            dark: Color.white.opacity(0.51)
        )
    )
}

// MARK: - Color Extension for Light/Dark Mode

extension Color {
    /// Creates a color that adapts to light and dark appearance modes.
    ///
    /// - Parameters:
    ///   - light: Color to use in light mode.
    ///   - dark: Color to use in dark mode.
    init(light: Color, dark: Color) {
        #if canImport(AppKit)
        self.init(nsColor: NSColor(name: nil) { appearance in
            appearance.bestMatch(from: [.darkAqua, .vibrantDark]) != nil
                ? NSColor(dark)
                : NSColor(light)
        })
        #else
        self.init(uiColor: UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(dark)
                : UIColor(light)
        })
        #endif
    }
}
