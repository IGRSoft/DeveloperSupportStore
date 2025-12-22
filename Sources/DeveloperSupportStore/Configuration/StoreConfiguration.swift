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
/// Implement this protocol to provide your app's URLs and optionally
/// customize colors, typography, and layout constants.
///
/// Product IDs are managed automatically via `Products.plist` in your app bundle.
/// StoreHelper reads this file and provides product collections.
///
/// Example:
/// ```swift
/// struct MyStoreConfiguration: StoreConfigurationProtocol {
///     var privacyPolicyURL: URL { URL(string: "https://example.com/privacy")! }
///     var termsOfUseURL: URL { URL(string: "https://example.com/terms")! }
///     // colors, typography, layout use defaults
/// }
/// ```
///
/// Your app must include a `Products.plist` file with the following format:
/// ```xml
/// <dict>
///     <key>Products</key>
///     <array>
///         <string>com.example.tip.small</string>
///         <string>com.example.tip.large</string>
///     </array>
///     <key>Subscriptions</key>
///     <array>
///         <dict>
///             <key>Group</key>
///             <string>support</string>
///             <key>Products</key>
///             <array>
///                 <string>com.example.subscription.monthly</string>
///             </array>
///         </dict>
///     </array>
/// </dict>
/// ```
public protocol StoreConfigurationProtocol: Sendable {
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

    /// Whether logging is enabled.
    ///
    /// When `false`, all internal logging (os.log) is disabled.
    /// Defaults to `true`.
    var isLoggingEnabled: Bool { get }
}

// MARK: - Default Implementations

public extension StoreConfigurationProtocol {
    /// Default colors based on the original Colir app design.
    var colors: StoreColors { .default }

    /// Default typography based on the original Colir app design.
    var typography: StoreTypography { .default }

    /// Default layout constants based on the original Colir app design.
    var layout: StoreLayoutConstants { .default }

    /// Default: logging is disabled.
    var isLoggingEnabled: Bool { false }
}
