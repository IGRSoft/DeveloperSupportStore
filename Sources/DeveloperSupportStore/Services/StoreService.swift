//
//  StoreService.swift
//
//  Created on 18.12.2025.
//  Copyright © 2025 IGR Soft. All rights reserved.
//

import Foundation
import StoreHelper
import StoreKit

/// Service for handling App Store interactions using StoreHelper.
@MainActor
public final class StoreService: StoreServiceProtocol {
    private let storeHelper: StoreHelper
    private let configuration: any StoreConfigurationProtocol

    /// Creates a new store service.
    ///
    /// - Parameters:
    ///   - configuration: The store configuration with product IDs.
    ///   - storeHelper: The StoreHelper instance (defaults to a new instance).
    public init(
        configuration: any StoreConfigurationProtocol,
        storeHelper: StoreHelper = StoreHelper()
    ) {
        self.configuration = configuration
        self.storeHelper = storeHelper
    }

    /// Indicates whether the user has an active subscription.
    public var hasActiveSubscription: Bool {
        storeHelper.purchasedProducts.contains { productId in
            configuration.subscriptionIds.contains(productId)
        }
    }

    /// Synchronizes store data with the App Store.
    public func syncStoreData() async throws {
        if !storeHelper.hasStarted {
            await storeHelper.startAsync()
        } else {
            storeHelper.refreshProductsFromAppStore()
        }
    }

    /// Initiates the purchase of a product.
    ///
    /// - Parameter productId: The identifier of the product to purchase.
    /// - Returns: The result of the purchase attempt.
    public func purchase(_ productId: String) async throws -> StorePurchaseResult {
        if !storeHelper.hasStarted {
            await storeHelper.startAsync()
        }

        guard let storeProduct = storeHelper.product(from: productId) else {
            throw StoreServiceError.productNotFound
        }

        let (_, purchaseState) = try await storeHelper.purchase(storeProduct)

        switch purchaseState {
        case .purchased:
            return .success(productId: productId)
        case .cancelled:
            return .userCancelled
        case .pending:
            return .pending
        case .inProgress, .notStarted, .unknown, .notPurchased,
             .userCannotMakePayments, .failed, .failedVerification:
            return .userCancelled
        }
    }

    /// Retrieves information for a product.
    ///
    /// - Parameter productId: The identifier of the product.
    /// - Returns: Information about the product.
    public func info(for productId: String) throws -> StoreProductInfo {
        guard let storeProduct = storeHelper.product(from: productId) else {
            throw StoreServiceError.productNotFound
        }

        return StoreProductInfo(
            name: storeProduct.displayName,
            description: storeProduct.description,
            price: storeProduct.displayPrice
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
@MainActor
public final class StoreServicePreview: StoreServiceProtocol {
    public var hasActiveSubscription: Bool

    private let mockProducts: [String: MockProductData]
    private let purchaseResult: StorePurchaseResult
    private let syncDelay: Duration

    /// Creates a preview store service with configurable mock data.
    ///
    /// - Parameters:
    ///   - hasActiveSubscription: Whether to simulate an active subscription.
    ///   - mockProducts: Array of mock product data to use.
    ///   - purchaseResult: The result to return from purchase attempts.
    ///   - syncDelay: Artificial delay for sync operations (simulates network).
    public init(
        hasActiveSubscription: Bool = false,
        mockProducts: [MockProductData] = [],
        purchaseResult: StorePurchaseResult = .success(productId: "mock.product"),
        syncDelay: Duration = .zero
    ) {
        self.hasActiveSubscription = hasActiveSubscription
        self.mockProducts = Dictionary(uniqueKeysWithValues: mockProducts.map { ($0.productId, $0) })
        self.purchaseResult = purchaseResult
        self.syncDelay = syncDelay
    }

    public func syncStoreData() async throws {
        if syncDelay > .zero {
            try await Task.sleep(for: syncDelay)
        }
    }

    public func purchase(_ productId: String) async throws -> StorePurchaseResult {
        if syncDelay > .zero {
            try await Task.sleep(for: syncDelay)
        }

        switch purchaseResult {
        case .success:
            return .success(productId: productId)
        default:
            return purchaseResult
        }
    }

    public func info(for productId: String) throws -> StoreProductInfo {
        if let mockProduct = mockProducts[productId] {
            return StoreProductInfo(
                name: mockProduct.name,
                description: mockProduct.description,
                price: mockProduct.price
            )
        }

        return StoreProductInfo(
            name: "Preview Product",
            description: "This is a preview product description.",
            price: "$0.99"
        )
    }
}

// MARK: - Default Mock Data

extension StoreServicePreview {
    /// Creates a preview service with realistic mock data for a tip jar / subscription store.
    ///
    /// - Parameters:
    ///   - subscriptionIds: The subscription product IDs to mock.
    ///   - inAppPurchaseIds: The one-time purchase product IDs to mock.
    ///   - hasActiveSubscription: Whether to simulate an active subscription.
    /// - Returns: A configured preview service.
    public static func withDefaultMockData(
        subscriptionIds: [String] = ["com.example.subscription.monthly"],
        inAppPurchaseIds: [String] = ["com.example.tip.small", "com.example.tip.large"],
        hasActiveSubscription: Bool = false
    ) -> StoreServicePreview {
        var mockProducts: [MockProductData] = []

        // Add subscription mocks
        for (index, subscriptionId) in subscriptionIds.enumerated() {
            let tier = index == 0 ? "Monthly" : "Yearly"
            let price = index == 0 ? "$2.99" : "$24.99"
            mockProducts.append(MockProductData(
                productId: subscriptionId,
                name: "\(tier) Support",
                description: "Support ongoing development with a \(tier.lowercased()) contribution.",
                price: price
            ))
        }

        // Add one-time purchase mocks
        let tipNames = ["Small Tip", "Large Tip", "Generous Tip"]
        let tipDescriptions = [
            "A small token of appreciation.",
            "A generous contribution to development.",
            "An amazing show of support!"
        ]
        let tipPrices = ["$0.99", "$4.99", "$9.99"]

        for (index, purchaseId) in inAppPurchaseIds.enumerated() {
            let safeIndex = min(index, tipNames.count - 1)
            mockProducts.append(MockProductData(
                productId: purchaseId,
                name: tipNames[safeIndex],
                description: tipDescriptions[safeIndex],
                price: tipPrices[safeIndex]
            ))
        }

        return StoreServicePreview(
            hasActiveSubscription: hasActiveSubscription,
            mockProducts: mockProducts
        )
    }
}
