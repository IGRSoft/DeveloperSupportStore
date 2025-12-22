//
//  StoreViewModel.swift
//
//  Created on 18.12.2025.
//  Copyright © 2025 IGR Soft. All rights reserved.
//

import Foundation
import os.log
import StoreKit
import SwiftUI

private let logger = Logger(subsystem: "DeveloperSupportStore", category: "StoreViewModel")

/// ViewModel for managing the developer support store view state.
@MainActor
@Observable
public final class StoreViewModel {
    // MARK: - Configuration

    /// The store configuration.
    public let configuration: any StoreConfigurationProtocol

    // MARK: - Services

    /// The store service for handling purchases.
    public let storeService: any StoreServiceProtocol

    // MARK: - Callbacks

    /// Closure called when a purchase succeeds.
    public let onPurchaseSuccess: @MainActor (String) -> Void

    /// Closure called when the view should be dismissed.
    public let onDismiss: @MainActor () -> Void

    // MARK: - State

    /// Whether an overlay (loading indicator) should be displayed.
    public var isLoading: Bool = false

    // MARK: - Product Collections

    /// Subscription products from StoreHelper.
    /// Updated after `syncStore()` completes to trigger UI refresh.
    public private(set) var subscriptionProducts: [Product] = []

    /// Non-consumable products (tips) from StoreHelper.
    /// Updated after `syncStore()` completes to trigger UI refresh.
    public private(set) var nonConsumableProducts: [Product] = []

    // MARK: - Initialization

    /// Creates a new store view model.
    ///
    /// - Parameters:
    ///   - configuration: The store configuration.
    ///   - storeService: The store service (created automatically if not provided).
    ///   - onPurchaseSuccess: Called when a purchase succeeds with the product ID.
    ///   - onDismiss: Called when the view should be dismissed.
    public init(
        configuration: any StoreConfigurationProtocol,
        storeService: (any StoreServiceProtocol)? = nil,
        onPurchaseSuccess: @escaping @MainActor (String) -> Void,
        onDismiss: @escaping @MainActor () -> Void
    ) {
        self.configuration = configuration
        self.storeService = storeService ?? StoreService()
        self.onPurchaseSuccess = onPurchaseSuccess
        self.onDismiss = onDismiss
    }

    // MARK: - Actions

    /// Purchases a product.
    ///
    /// - Parameter product: The product to purchase.
    public func purchase(_ product: Product) async {
        isLoading = true
        defer { isLoading = false }

        do {
            let result = try await storeService.purchase(product)

            switch result {
            case let .success(purchasedProductId):
                onPurchaseSuccess(purchasedProductId)
                onDismiss()
            case .userCancelled, .pending:
                break
            }
        } catch {
            print("Purchase error: \(error.localizedDescription)")
        }
    }

    /// Syncs store data and updates product collections.
    ///
    /// After StoreHelper fetches products from the App Store,
    /// this updates the stored properties to trigger UI refresh.
    public func syncStore() async {
        logger.notice("syncStore() called")
        isLoading = true
        defer { isLoading = false }

        do {
            try await storeService.syncStoreData()

            logger.notice("After syncStoreData:")
            logger.notice("  storeService.subscriptionProducts: \(self.storeService.subscriptionProducts.count)")
            logger.notice("  storeService.nonConsumableProducts: \(self.storeService.nonConsumableProducts.count)")

            // Update stored properties to trigger @Observable notification
            subscriptionProducts = storeService.subscriptionProducts
            nonConsumableProducts = storeService.nonConsumableProducts

            logger.notice("After assignment:")
            logger.notice("  subscriptionProducts: \(self.subscriptionProducts.count)")
            logger.notice("  nonConsumableProducts: \(self.nonConsumableProducts.count)")
        } catch {
            logger.error("Sync error: \(error.localizedDescription)")
        }
    }

    /// Gets product info for a product.
    ///
    /// - Parameter product: The product.
    /// - Returns: The product info.
    public func productInfo(for product: Product) -> StoreProductInfo {
        storeService.info(for: product)
    }
}
