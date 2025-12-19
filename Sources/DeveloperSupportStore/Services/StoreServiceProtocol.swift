//
//  StoreServiceProtocol.swift
//
//  Created on 18.12.2025.
//  Copyright © 2025 IGR Soft. All rights reserved.
//

import Foundation

/// Protocol defining the interface for App Store interactions.
///
/// This protocol is implemented by `StoreService` and can be mocked for testing.
@MainActor
public protocol StoreServiceProtocol: Sendable {
    /// Synchronizes store data with the App Store.
    ///
    /// Call this when the store view appears to refresh product information
    /// and restore previous purchases.
    func syncStoreData() async throws

    /// Initiates the purchase of a product.
    ///
    /// - Parameter productId: The identifier of the product to purchase.
    /// - Returns: The result of the purchase attempt.
    func purchase(_ productId: String) async throws -> StorePurchaseResult

    /// Retrieves information for a product.
    ///
    /// - Parameter productId: The identifier of the product.
    /// - Returns: Information about the product.
    /// - Throws: `StoreServiceError.productNotFound` if the product is not available.
    func info(for productId: String) throws -> StoreProductInfo

    /// Indicates whether the user has an active subscription.
    var hasActiveSubscription: Bool { get }
}

/// Errors that can occur during store operations.
public enum StoreServiceError: Error, Sendable {
    /// The requested product was not found in the store.
    case productNotFound

    /// The store has not been initialized.
    case storeNotStarted
}
