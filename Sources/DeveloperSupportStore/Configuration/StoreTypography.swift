//
//  StoreTypography.swift
//
//  Created on 18.12.2025.
//  Copyright © 2025 IGR Soft. All rights reserved.
//

import SwiftUI

/// Typography configuration for the store views.
///
/// Provides all font styles used in the DeveloperSupportStoreView.
/// Use `.default` for the original Colir app typography, or create
/// a custom instance to match your app's design system.
public struct StoreTypography: Sendable {
    /// Large headline font (section titles).
    public let headlineLarge: Font

    /// Medium headline font (card titles).
    public let headlineMedium: Font

    /// Small headline font (prices, subtitles).
    public let headlineSmall: Font

    /// Medium body font (descriptions).
    public let bodyMedium: Font

    /// Small body font (secondary descriptions).
    public let bodySmall: Font

    /// Medium label font (divider text).
    public let labelMedium: Font

    /// Small label font (footer links, captions).
    public let labelSmall: Font

    /// Creates a new typography configuration.
    ///
    /// - Parameters:
    ///   - headlineLarge: Large headline font.
    ///   - headlineMedium: Medium headline font.
    ///   - headlineSmall: Small headline font.
    ///   - bodyMedium: Medium body font.
    ///   - bodySmall: Small body font.
    ///   - labelMedium: Medium label font.
    ///   - labelSmall: Small label font.
    public init(
        headlineLarge: Font,
        headlineMedium: Font,
        headlineSmall: Font,
        bodyMedium: Font,
        bodySmall: Font,
        labelMedium: Font,
        labelSmall: Font
    ) {
        self.headlineLarge = headlineLarge
        self.headlineMedium = headlineMedium
        self.headlineSmall = headlineSmall
        self.bodyMedium = bodyMedium
        self.bodySmall = bodySmall
        self.labelMedium = labelMedium
        self.labelSmall = labelSmall
    }

    /// Default typography from the original Colir app design.
    public static let `default` = StoreTypography(
        headlineLarge: .system(size: 20, weight: .semibold),
        headlineMedium: .system(size: 17, weight: .semibold),
        headlineSmall: .system(size: 15, weight: .semibold),
        bodyMedium: .system(size: 13, weight: .regular),
        bodySmall: .system(size: 11, weight: .regular),
        labelMedium: .system(size: 11, weight: .medium),
        labelSmall: .system(size: 10, weight: .regular)
    )
}
