//
//  StoreViewModel.swift
//
//  Created on 18.12.2025.
//  Copyright © 2025 IGR Soft. All rights reserved.
//

import Foundation
import SwiftUI

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
        self.storeService = storeService ?? StoreService(configuration: configuration)
        self.onPurchaseSuccess = onPurchaseSuccess
        self.onDismiss = onDismiss
    }

    // MARK: - Actions

    /// Purchases a product.
    ///
    /// - Parameter productId: The identifier of the product to purchase.
    public func purchase(_ productId: String) async {
        isLoading = true
        defer { isLoading = false }

        do {
            let result = try await storeService.purchase(productId)

            switch result {
            case .success(let purchasedProductId):
                onPurchaseSuccess(purchasedProductId)
                onDismiss()
            case .userCancelled, .pending:
                break
            }
        } catch {
            print("Purchase error: \(error.localizedDescription)")
        }
    }

    /// Syncs store data.
    public func syncStore() async {
        do {
            try await storeService.syncStoreData()
        } catch {
            print("Sync error: \(error.localizedDescription)")
        }
    }

    /// Gets product info for a product ID.
    ///
    /// - Parameter productId: The product identifier.
    /// - Returns: The product info, or nil if not found.
    public func productInfo(for productId: String) -> StoreProductInfo? {
        try? storeService.info(for: productId)
    }
}
