//
//  StoreServiceProtocol.swift
//
//  Created on 18.12.2025.
//  Copyright © 2025 IGR Soft. All rights reserved.
//

import Foundation
import StoreKit

/// Protocol defining the interface for App Store interactions.
///
/// This protocol is implemented by `StoreService` and can be mocked for testing.
/// Products are loaded automatically from `Products.plist` via StoreHelper.
@MainActor
public protocol StoreServiceProtocol: Sendable {
    // MARK: - Product Collections

    /// Subscription products loaded from Products.plist (auto-renewable subscriptions).
    var subscriptionProducts: [Product] { get }

    /// Non-consumable products loaded from Products.plist (one-time purchases/tips).
    var nonConsumableProducts: [Product] { get }

    /// Indicates whether the user has an active subscription.
    var hasActiveSubscription: Bool { get }

    /// Indicates whether the user has any purchased products.
    var hasPurchasedProducts: Bool { get }

    // MARK: - Actions

    /// Synchronizes store data with the App Store.
    ///
    /// Call this when the store view appears to refresh product information
    /// and restore previous purchases.
    func syncStoreData() async throws

    /// Initiates the purchase of a product.
    ///
    /// - Parameter product: The product to purchase.
    /// - Returns: The result of the purchase attempt.
    func purchase(_ product: Product) async throws -> StorePurchaseResult

    /// Retrieves display information for a product.
    ///
    /// - Parameter product: The product to get information for.
    /// - Returns: Information about the product including name, description, and price.
    func info(for product: Product) -> StoreProductInfo
}

/// Errors that can occur during store operations.
public enum StoreServiceError: Error, Sendable {
    /// The requested product was not found in the store.
    case productNotFound

    /// The store has not been initialized.
    case storeNotStarted
}
