# DeveloperSupportStore

A configurable SwiftUI package for displaying in-app purchases and subscriptions with a modern, customizable UI.

## Features

- 🎨 Fully customizable colors, typography, and layout
- 📱 Support for both subscriptions and one-time purchases
- 🌙 Light/dark mode support with adaptive defaults
- 🔒 Swift 6 strict concurrency compliance
- 🧪 Unit tested configuration system
- 📦 Uses StoreHelper for IAP handling with automatic `Products.plist` loading

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
    .package(url: "https://github.com/IGRSoft/DeveloperSupportStore.git", from: "1.0.0"),
]
```

## Setup

### 1. Add Products.plist

Create a `Products.plist` file in your app bundle with your product IDs:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Products</key>
    <array>
        <!-- Non-consumable (one-time) products -->
        <string>com.yourapp.tip.small</string>
        <string>com.yourapp.tip.large</string>
    </array>
    <key>Subscriptions</key>
    <array>
        <dict>
            <key>Group</key>
            <string>support</string>
            <key>Products</key>
            <array>
                <string>com.yourapp.subscription.monthly</string>
            </array>
        </dict>
    </array>
</dict>
</plist>
```

**Structure:**
- `Products` → Array of one-time purchase product IDs (tips/non-consumables)
- `Subscriptions` → Array of subscription group dictionaries containing group name and product IDs

### 2. Add StoreKit Configuration (for testing)

Create a `.storekit` configuration file in Xcode to test purchases in the simulator.

## Usage

### Basic Usage

```swift
import DeveloperSupportStore
import SwiftUI

// 1. Create a configuration (only URLs required - products come from Products.plist)
struct MyStoreConfiguration: StoreConfigurationProtocol {
    var privacyPolicyURL: URL { URL(string: "https://example.com/privacy")! }
    var termsOfUseURL: URL { URL(string: "https://example.com/terms")! }
}

// 2. Display the store view
struct ContentView: View {
    @State private var isStorePresented = false
    private let config = MyStoreConfiguration()

    var body: some View {
        Button("Open Store") {
            isStorePresented = true
        }
        .sheet(isPresented: $isStorePresented) {
            DeveloperSupportStoreView(
                configuration: config,
                onPurchaseSuccess: { productId in
                    print("Purchased: \(productId)")
                },
                onDismiss: {
                    isStorePresented = false
                }
            )
        }
    }
}
```

### Custom Styling

Override defaults by implementing the optional protocol properties:

```swift
struct CustomStoreConfiguration: StoreConfigurationProtocol {
    // Required
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
| `privacyPolicyURL` | `URL` | Privacy policy link |
| `termsOfUseURL` | `URL` | Terms of use link |

### Optional Properties (with defaults)

| Property | Type | Description |
|----------|------|-------------|
| `colors` | `StoreColors` | UI color configuration |
| `typography` | `StoreTypography` | Font configuration |
| `layout` | `StoreLayoutConstants` | Spacing and padding |

> **Note:** Product IDs are loaded automatically from `Products.plist` by StoreHelper.

## Example Project

The `Example/` directory contains a complete iOS app demonstrating integration:

```bash
# Open the example project
open Example/DeveloperSupportStoreExample.xcworkspace
```

The example includes:
- `Products.plist` with sample product IDs
- `DeveloperSupportStoreExample.storekit` configuration for testing
- `ContentView.swift` showing store integration

## Architecture

```
DeveloperSupportStore/
├── Configuration/      # Protocol and configuration types
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
