//
//  StoreConfigurationTests.swift
//
//  Created on 18.12.2025.
//  Copyright © 2025 IGR Soft. All rights reserved.
//

import DeveloperSupportStore
import Foundation
import Testing

@Suite("Store Configuration Tests")
struct StoreConfigurationTests {
    // MARK: - Test Configuration

    /// Test configuration that provides required URLs.
    /// Product IDs are managed by Products.plist via StoreHelper.
    struct TestConfiguration: StoreConfigurationProtocol {
        var privacyPolicyURL: URL { URL(string: "https://test.com/privacy")! }
        var termsOfUseURL: URL { URL(string: "https://test.com/terms")! }
    }

    // MARK: - Tests

    @Test("URLs are provided correctly")
    func urlsProvided() {
        let config = TestConfiguration()

        #expect(config.privacyPolicyURL.absoluteString == "https://test.com/privacy")
        #expect(config.termsOfUseURL.absoluteString == "https://test.com/terms")
    }

    @Test("default colors are provided")
    func defaultColors() {
        let config = TestConfiguration()

        // Default colors should be available
        _ = config.colors.primaryText
        _ = config.colors.secondaryText
        _ = config.colors.secondaryBackground
        _ = config.colors.selectedView
        _ = config.colors.buttonBackground
        _ = config.colors.buttonHovered
    }

    @Test("default typography is provided")
    func defaultTypography() {
        let config = TestConfiguration()

        // Default typography should be available
        _ = config.typography.headlineLarge
        _ = config.typography.headlineMedium
        _ = config.typography.headlineSmall
        _ = config.typography.bodyMedium
        _ = config.typography.bodySmall
        _ = config.typography.labelMedium
        _ = config.typography.labelSmall
    }

    @Test("default layout constants are provided")
    func defaultLayout() {
        let config = TestConfiguration()

        #expect(config.layout.spacingDefault == 8)
        #expect(config.layout.spacingSmall == 4)
        #expect(config.layout.spacingHeight == 16)
        #expect(config.layout.paddingDefault == 16)
        #expect(config.layout.paddingSmall == 8)
        #expect(config.layout.paddingBig == 24)
        #expect(config.layout.paddingThin == 4)
        #expect(config.layout.radiusDefault == 16)
        #expect(config.layout.radiusThin == 4)
        #expect(config.layout.radiusBig == 24)
    }
}

@Suite("Store Layout Constants Tests")
struct StoreLayoutConstantsTests {
    @Test("custom layout constants can be created")
    func customLayout() {
        let layout = StoreLayoutConstants(
            spacingDefault: 12,
            spacingSmall: 6,
            spacingHeight: 24,
            paddingDefault: 20,
            paddingSmall: 10,
            paddingBig: 32,
            paddingThin: 5,
            radiusDefault: 20,
            radiusThin: 6,
            radiusBig: 30
        )

        #expect(layout.spacingDefault == 12)
        #expect(layout.spacingSmall == 6)
        #expect(layout.spacingHeight == 24)
        #expect(layout.paddingDefault == 20)
        #expect(layout.paddingSmall == 10)
        #expect(layout.paddingBig == 32)
        #expect(layout.paddingThin == 5)
        #expect(layout.radiusDefault == 20)
        #expect(layout.radiusThin == 6)
        #expect(layout.radiusBig == 30)
    }
}

@Suite("Store Purchase Result Tests")
struct StorePurchaseResultTests {
    @Test("success result contains product ID")
    func successResult() {
        let result = StorePurchaseResult.success(productId: "test.product")

        if case let .success(productId) = result {
            #expect(productId == "test.product")
        } else {
            Issue.record("Expected success result")
        }
    }

    @Test("results are equatable")
    func equatable() {
        #expect(StorePurchaseResult.userCancelled == StorePurchaseResult.userCancelled)
        #expect(StorePurchaseResult.pending == StorePurchaseResult.pending)
        #expect(StorePurchaseResult.success(productId: "a") == StorePurchaseResult.success(productId: "a"))
        #expect(StorePurchaseResult.success(productId: "a") != StorePurchaseResult.success(productId: "b"))
    }
}

@Suite("Store Product Info Tests")
struct StoreProductInfoTests {
    @Test("product info stores values correctly")
    func productInfo() {
        let info = StoreProductInfo(
            name: "Test Product",
            description: "A test product",
            price: "$1.99"
        )

        #expect(info.name == "Test Product")
        #expect(info.description == "A test product")
        #expect(info.price == "$1.99")
    }
}
