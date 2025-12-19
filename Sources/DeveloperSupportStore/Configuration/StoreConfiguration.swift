//
//  StoreConfiguration.swift
//
//  Created on 18.12.2025.
//  Copyright © 2025 IGR Soft. All rights reserved.
//

import Foundation
import SwiftUI

/// Main configuration protocol for the DeveloperSupportStore package.
///
/// Implement this protocol to provide your app's product IDs, URLs, and optionally
/// customize colors, typography, and layout constants.
///
/// Example:
/// ```swift
/// struct MyStoreConfiguration: StoreConfigurationProtocol {
///     var subscriptionIds: [String] { ["com.example.subscription"] }
///     var inAppPurchaseIds: [String] { ["com.example.tip1", "com.example.tip2"] }
///     var privacyPolicyURL: URL { URL(string: "https://example.com/privacy")! }
///     var termsOfUseURL: URL { URL(string: "https://example.com/terms")! }
///     // colors, typography, layout use defaults
/// }
/// ```
public protocol StoreConfigurationProtocol: Sendable {
    // MARK: - Products (Required)

    /// Subscription product identifiers.
    var subscriptionIds: [String] { get }

    /// In-app purchase (one-time) product identifiers.
    var inAppPurchaseIds: [String] { get }

    // MARK: - URLs (Required)

    /// Privacy policy URL displayed in the store footer.
    var privacyPolicyURL: URL { get }

    /// Terms of use URL displayed in the store footer.
    var termsOfUseURL: URL { get }

    // MARK: - Appearance (Optional - have defaults)

    /// Color configuration for the store views.
    var colors: StoreColors { get }

    /// Typography configuration for the store views.
    var typography: StoreTypography { get }

    /// Layout constants for spacing, padding, and corner radius.
    var layout: StoreLayoutConstants { get }
}

// MARK: - Default Implementations

extension StoreConfigurationProtocol {
    /// All product identifiers (subscriptions + in-app purchases).
    public var allProductIds: [String] {
        subscriptionIds + inAppPurchaseIds
    }

    /// Default colors based on the original Colir app design.
    public var colors: StoreColors { .default }

    /// Default typography based on the original Colir app design.
    public var typography: StoreTypography { .default }

    /// Default layout constants based on the original Colir app design.
    public var layout: StoreLayoutConstants { .default }
}
