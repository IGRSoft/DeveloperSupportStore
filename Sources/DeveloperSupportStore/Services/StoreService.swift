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

/// A preview implementation of `StoreServiceProtocol` for SwiftUI previews and testing.
@MainActor
public final class StoreServicePreview: StoreServiceProtocol {
    public var hasActiveSubscription: Bool

    /// Creates a preview store service.
    ///
    /// - Parameter hasActiveSubscription: Whether to simulate an active subscription.
    public init(hasActiveSubscription: Bool = false) {
        self.hasActiveSubscription = hasActiveSubscription
    }

    public func syncStoreData() async throws {
        // No-op for preview
    }

    public func purchase(_ productId: String) async throws -> StorePurchaseResult {
        .success(productId: productId)
    }

    public func info(for _: String) throws -> StoreProductInfo {
        StoreProductInfo(
            name: "Preview Product",
            description: "This is a preview product description.",
            price: "$0.99"
        )
    }
}
