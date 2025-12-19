//
//  StoreLayoutConstants.swift
//
//  Created on 18.12.2025.
//  Copyright © 2025 IGR Soft. All rights reserved.
//

import Foundation

/// Layout constants for spacing, padding, and corner radius in the store views.
///
/// Use `.default` for the original Colir app layout, or create
/// a custom instance to match your app's design system.
public struct StoreLayoutConstants: Sendable {
    // MARK: - Spacing

    /// Default spacing between elements.
    public let spacingDefault: CGFloat

    /// Small spacing for tight layouts.
    public let spacingSmall: CGFloat

    /// Height spacing for larger gaps.
    public let spacingHeight: CGFloat

    // MARK: - Padding

    /// Default padding.
    public let paddingDefault: CGFloat

    /// Small padding.
    public let paddingSmall: CGFloat

    /// Big padding for outer containers.
    public let paddingBig: CGFloat

    /// Thin padding for minimal spacing.
    public let paddingThin: CGFloat

    // MARK: - Corner Radius

    /// Default corner radius for cards and containers.
    public let radiusDefault: CGFloat

    /// Thin corner radius for small elements.
    public let radiusThin: CGFloat

    /// Big corner radius for buttons.
    public let radiusBig: CGFloat

    /// Creates a new layout constants configuration.
    ///
    /// All parameters have default values matching the original Colir app design.
    public init(
        spacingDefault: CGFloat = 8,
        spacingSmall: CGFloat = 4,
        spacingHeight: CGFloat = 16,
        paddingDefault: CGFloat = 16,
        paddingSmall: CGFloat = 8,
        paddingBig: CGFloat = 24,
        paddingThin: CGFloat = 4,
        radiusDefault: CGFloat = 16,
        radiusThin: CGFloat = 4,
        radiusBig: CGFloat = 24
    ) {
        self.spacingDefault = spacingDefault
        self.spacingSmall = spacingSmall
        self.spacingHeight = spacingHeight
        self.paddingDefault = paddingDefault
        self.paddingSmall = paddingSmall
        self.paddingBig = paddingBig
        self.paddingThin = paddingThin
        self.radiusDefault = radiusDefault
        self.radiusThin = radiusThin
        self.radiusBig = radiusBig
    }

    /// Default layout constants from the original Colir app design.
    public static let `default` = StoreLayoutConstants()
}
