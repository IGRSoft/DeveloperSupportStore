//
//  StoreService.swift
//
//  Created on 18.12.2025.
//  Copyright © 2025 IGR Soft. All rights reserved.
//

import Foundation
import OrderedCollections
import StoreHelper
import StoreKit

/// Service for handling App Store interactions using StoreHelper.
///
/// Products are loaded automatically from `Products.plist` in your app bundle.
@MainActor
public final class StoreService: StoreServiceProtocol {
    private let storeHelper: StoreHelper
    private let logger: StoreLogger

    // Local storage for products (synced from StoreHelper)
    private var _subscriptionProducts: [Product] = []
    private var _nonConsumableProducts: [Product] = []

    /// Creates a new store service.
    ///
    /// - Parameters:
    ///   - storeHelper: The StoreHelper instance (defaults to a new instance).
    ///   - isLoggingEnabled: Whether logging is enabled (defaults to true).
    public init(storeHelper: StoreHelper = StoreHelper(), isLoggingEnabled: Bool = true) {
        self.storeHelper = storeHelper
        logger = StoreLogger(category: "StoreService", isEnabled: isLoggingEnabled)
    }

    // MARK: - Product Collections

    /// Subscription products loaded from Products.plist (auto-renewable subscriptions).
    public var subscriptionProducts: [Product] {
        _subscriptionProducts
    }

    /// Non-consumable products loaded from Products.plist (one-time purchases/tips).
    public var nonConsumableProducts: [Product] {
        _nonConsumableProducts
    }

    /// Indicates whether the user has an active subscription.
    public var hasActiveSubscription: Bool {
        guard let subscriptionIds = storeHelper.subscriptionProductIds else { return false }
        return storeHelper.purchasedProducts.contains { productId in
            subscriptionIds.contains(productId)
        }
    }

    // MARK: - Actions

    /// Synchronizes store data with the App Store.
    ///
    /// Fetches products using StoreHelper and updates local storage.
    public func syncStoreData() async throws {
        logger.notice("syncStoreData() called")
        logger.notice("storeHelper.hasStarted: \(storeHelper.hasStarted)")

        // Start StoreHelper if needed
        if !storeHelper.hasStarted {
            logger.notice("Starting StoreHelper...")
            await storeHelper.startAsync()
            logger.notice("StoreHelper started, hasStarted: \(storeHelper.hasStarted)")
        }

        // After startAsync, products should be loaded from App Store
        // storeHelper.products contains all Product objects fetched
        logger.notice("storeHelper.products count: \(storeHelper.products?.count ?? 0)")
        logger.notice("storeHelper.productIds: \(Array(storeHelper.productIds ?? []))")

        if let products = storeHelper.products {
            for product in products {
                logger.notice("  Product: \(product.id) type=\(String(describing: product.type))")
            }
        }

        // Use StoreHelper's filtered product arrays directly
        // These filter by product.type from the App Store response
        _subscriptionProducts = storeHelper.subscriptionProducts ?? []
        _nonConsumableProducts = storeHelper.nonConsumableProducts ?? []

        logger.notice("_subscriptionProducts count: \(_subscriptionProducts.count)")
        logger.notice("_nonConsumableProducts count: \(_nonConsumableProducts.count)")
    }

    /// Initiates the purchase of a product.
    ///
    /// - Parameter product: The product to purchase.
    /// - Returns: The result of the purchase attempt.
    public func purchase(_ product: Product) async throws -> StorePurchaseResult {
        if !storeHelper.hasStarted {
            await storeHelper.startAsync()
        }

        let (_, purchaseState) = try await storeHelper.purchase(product)

        switch purchaseState {
        case .purchased:
            return .success(productId: product.id)
        case .cancelled:
            return .userCancelled
        case .pending:
            return .pending
        case .inProgress, .notStarted, .unknown, .notPurchased,
             .userCannotMakePayments, .failed, .failedVerification:
            return .userCancelled
        }
    }

    /// Retrieves display information for a product.
    ///
    /// - Parameter product: The product to get information for.
    /// - Returns: Information about the product.
    public func info(for product: Product) -> StoreProductInfo {
        StoreProductInfo(
            name: product.displayName,
            description: product.description,
            price: product.displayPrice
        )
    }
}

// MARK: - Preview Service

/// Mock product data for previews and testing.
public struct MockProductData: Sendable {
    /// The product identifier.
    public let productId: String
    /// The display name.
    public let name: String
    /// The product description.
    public let description: String
    /// The formatted price string.
    public let price: String

    /// Creates mock product data.
    public init(productId: String, name: String, description: String, price: String) {
        self.productId = productId
        self.name = name
        self.description = description
        self.price = price
    }
}

/// A preview implementation of `StoreServiceProtocol` for SwiftUI previews and testing.
///
/// This service provides mock data for previews. For full testing with actual StoreKit
/// behavior, use a StoreKit Configuration file in your test target.
@MainActor
public final class StoreServicePreview: StoreServiceProtocol {
    public var hasActiveSubscription: Bool

    // Internal storage for mock data
    private let mockSubscriptions: [MockProductData]
    private let mockPurchases: [MockProductData]
    private let purchaseResult: StorePurchaseResult
    private let syncDelay: Duration

    // Product collections - empty for preview (use StoreKit Configuration for real products)
    public var subscriptionProducts: [Product] { [] }
    public var nonConsumableProducts: [Product] { [] }

    // Mock product arrays for preview iteration
    public let mockSubscriptionProducts: [MockProductData]
    public let mockNonConsumableProducts: [MockProductData]

    /// Creates a preview store service with configurable mock data.
    ///
    /// - Parameters:
    ///   - hasActiveSubscription: Whether to simulate an active subscription.
    ///   - mockSubscriptions: Mock subscription product data.
    ///   - mockPurchases: Mock one-time purchase product data.
    ///   - purchaseResult: The result to return from purchase attempts.
    ///   - syncDelay: Artificial delay for sync operations (simulates network).
    public init(
        hasActiveSubscription: Bool = false,
        mockSubscriptions: [MockProductData] = [],
        mockPurchases: [MockProductData] = [],
        purchaseResult: StorePurchaseResult = .success(productId: "mock.product"),
        syncDelay: Duration = .zero
    ) {
        self.hasActiveSubscription = hasActiveSubscription
        self.mockSubscriptions = mockSubscriptions
        self.mockPurchases = mockPurchases
        mockSubscriptionProducts = mockSubscriptions
        mockNonConsumableProducts = mockPurchases
        self.purchaseResult = purchaseResult
        self.syncDelay = syncDelay
    }

    public func syncStoreData() async throws {
        if syncDelay > .zero {
            try await Task.sleep(for: syncDelay)
        }
    }

    public func purchase(_ product: Product) async throws -> StorePurchaseResult {
        if syncDelay > .zero {
            try await Task.sleep(for: syncDelay)
        }

        switch purchaseResult {
        case .success:
            return .success(productId: product.id)
        default:
            return purchaseResult
        }
    }

    public func info(for product: Product) -> StoreProductInfo {
        // Check mock data first
        if let mock = mockSubscriptions.first(where: { $0.productId == product.id }) ??
            mockPurchases.first(where: { $0.productId == product.id })
        {
            return StoreProductInfo(name: mock.name, description: mock.description, price: mock.price)
        }

        // Fallback to Product's built-in info
        return StoreProductInfo(
            name: product.displayName,
            description: product.description,
            price: product.displayPrice
        )
    }

    /// Gets mock product info by product ID (for previews without real Products).
    public func mockInfo(for productId: String) -> StoreProductInfo? {
        if let mock = mockSubscriptions.first(where: { $0.productId == productId }) ??
            mockPurchases.first(where: { $0.productId == productId })
        {
            return StoreProductInfo(name: mock.name, description: mock.description, price: mock.price)
        }
        return nil
    }
}

// MARK: - Default Mock Data

public extension StoreServicePreview {
    /// Creates a preview service with realistic mock data for a tip jar / subscription store.
    ///
    /// - Parameter hasActiveSubscription: Whether to simulate an active subscription.
    /// - Returns: A configured preview service with default mock products.
    static func withDefaultMockData(
        hasActiveSubscription: Bool = false
    ) -> StoreServicePreview {
        let mockSubscriptions = [
            MockProductData(
                productId: "com.example.subscription.monthly",
                name: "Monthly Support",
                description: "Support ongoing development with a monthly contribution.",
                price: "$2.99"
            ),
        ]

        let mockPurchases = [
            MockProductData(
                productId: "com.example.tip.small",
                name: "Small Tip",
                description: "A small token of appreciation.",
                price: "$0.99"
            ),
            MockProductData(
                productId: "com.example.tip.large",
                name: "Large Tip",
                description: "A generous contribution to development.",
                price: "$4.99"
            ),
        ]

        return StoreServicePreview(
            hasActiveSubscription: hasActiveSubscription,
            mockSubscriptions: mockSubscriptions,
            mockPurchases: mockPurchases
        )
    }
}
