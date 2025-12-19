# DeveloperSupportStore

A configurable SwiftUI package for displaying in-app purchases and subscriptions with a modern, customizable UI.

## Features

- 🎨 Fully customizable colors, typography, and layout
- 📱 Support for both subscriptions and one-time purchases
- 🌙 Light/dark mode support with adaptive defaults
- 🔒 Swift 6 strict concurrency compliance
- 🧪 Unit tested configuration system
- 📦 Uses StoreHelper for IAP handling

## Requirements

- macOS 14.0+ / iOS 17.0+
- Swift 6.0+
- Xcode 16.0+

## Installation

### Local Package

1. In Xcode, go to **File → Add Package Dependencies**
2. Click **Add Local...**
3. Select the `DeveloperSupportStore` folder
4. Add to your target

### Swift Package Manager

Add to your `Package.swift`:

```swift
dependencies: [
    .package(path: "../DeveloperSupportStore")
]
```

## Usage

### Basic Usage

```swift
import DeveloperSupportStore

// 1. Create a configuration
struct MyStoreConfiguration: StoreConfigurationProtocol {
    var subscriptionIds: [String] { ["com.app.subscription.monthly"] }
    var inAppPurchaseIds: [String] { ["com.app.tip.small", "com.app.tip.large"] }
    var privacyPolicyURL: URL { URL(string: "https://example.com/privacy")! }
    var termsOfUseURL: URL { URL(string: "https://example.com/terms")! }
}

// 2. Create the view
let config = MyStoreConfiguration()
let storeService = StoreService(configuration: config)
let viewModel = StoreViewModel(
    configuration: config,
    storeService: storeService,
    onClose: { /* dismiss */ },
    onPurchaseSuccess: { productId in /* handle success */ }
)

// 3. Display
DeveloperSupportStoreView(configuration: config)
    .environment(viewModel)
```

### Custom Styling

Override defaults by implementing the optional protocol properties:

```swift
struct CustomStoreConfiguration: StoreConfigurationProtocol {
    // Required
    var subscriptionIds: [String] { ["com.app.sub"] }
    var inAppPurchaseIds: [String] { ["com.app.tip"] }
    var privacyPolicyURL: URL { URL(string: "https://example.com/privacy")! }
    var termsOfUseURL: URL { URL(string: "https://example.com/terms")! }

    // Optional: Custom colors
    var colors: StoreColors {
        StoreColors(
            primaryText: .white,
            secondaryText: .gray,
            secondaryBackground: .init(light: .darkGray, dark: .lightGray),
            selectedView: .blue,
            buttonBackground: .gray,
            buttonHovered: .init(light: .black.opacity(0.5), dark: .white.opacity(0.5))
        )
    }

    // Optional: Custom typography
    var typography: StoreTypography {
        StoreTypography(
            headlineLarge: .system(size: 24, weight: .bold),
            headlineMedium: .system(size: 18, weight: .semibold),
            // ... more fonts
        )
    }

    // Optional: Custom layout
    var layout: StoreLayoutConstants {
        StoreLayoutConstants(
            spacingDefault: 12,
            paddingDefault: 20,
            radiusDefault: 12
        )
    }
}
```

## Configuration Protocol

### Required Properties

| Property | Type | Description |
|----------|------|-------------|
| `subscriptionIds` | `[String]` | Product IDs for subscriptions |
| `inAppPurchaseIds` | `[String]` | Product IDs for one-time purchases |
| `privacyPolicyURL` | `URL` | Privacy policy link |
| `termsOfUseURL` | `URL` | Terms of use link |

### Optional Properties (with defaults)

| Property | Type | Description |
|----------|------|-------------|
| `colors` | `StoreColors` | UI color configuration |
| `typography` | `StoreTypography` | Font configuration |
| `layout` | `StoreLayoutConstants` | Spacing and padding |

## Architecture

```
DeveloperSupportStore/
├── Configuration/       # Protocol and configuration types
├── Models/             # Data models (ProductInfo, PurchaseResult)
├── Services/           # StoreHelper integration
├── Views/              # SwiftUI views and view model
├── Styles/             # Button styles
└── Resources/          # Localized strings
```

## Testing

Run tests with:

```bash
swift test
```

## License

MIT License - See LICENSE file for details.
