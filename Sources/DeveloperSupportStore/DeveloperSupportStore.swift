//
//  DeveloperSupportStore.swift
//
//  Created on 18.12.2025.
//  Copyright © 2025 IGR Soft. All rights reserved.
//

/// DeveloperSupportStore - A configurable SwiftUI view for in-app purchases and subscriptions.
///
/// ## Overview
///
/// DeveloperSupportStore provides a complete, customizable UI for displaying
/// in-app purchases and subscriptions in your app. It uses StoreHelper under
/// the hood for App Store interactions.
///
/// ## Quick Start
///
/// 1. Create a configuration conforming to `StoreConfigurationProtocol`:
///
/// ```swift
/// struct MyStoreConfiguration: StoreConfigurationProtocol {
///     var subscriptionIds: [String] { ["com.example.subscription"] }
///     var inAppPurchaseIds: [String] { ["com.example.tip1", "com.example.tip2"] }
///     var privacyPolicyURL: URL { URL(string: "https://example.com/privacy")! }
///     var termsOfUseURL: URL { URL(string: "https://example.com/terms")! }
/// }
/// ```
///
/// 2. Present the store view:
///
/// ```swift
/// DeveloperSupportStoreView(
///     configuration: MyStoreConfiguration(),
///     onPurchaseSuccess: { productId in
///         // Handle successful purchase
///     },
///     onDismiss: {
///         // Dismiss the view
///     }
/// )
/// ```
///
/// ## Customization
///
/// Override the default colors, typography, or layout by implementing
/// the optional properties in your configuration:
///
/// ```swift
/// struct CustomStoreConfiguration: StoreConfigurationProtocol {
///     // Required
///     var subscriptionIds: [String] { ... }
///     var inAppPurchaseIds: [String] { ... }
///     var privacyPolicyURL: URL { ... }
///     var termsOfUseURL: URL { ... }
///
///     // Optional - override defaults
///     var colors: StoreColors {
///         StoreColors(
///             primaryText: .white,
///             secondaryText: .gray,
///             secondaryBackground: Color(white: 0.2),
///             selectedView: .blue,
///             buttonBackground: Color(white: 0.3),
///             buttonHovered: Color(white: 0.4)
///         )
///     }
/// }
/// ```

// Re-export public types
@_exported import struct SwiftUI.Color
@_exported import struct SwiftUI.Font
