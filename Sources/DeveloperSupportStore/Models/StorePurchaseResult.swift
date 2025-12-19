//
//  StorePurchaseResult.swift
//
//  Created on 18.12.2025.
//  Copyright © 2025 IGR Soft. All rights reserved.
//

import Foundation

/// The result of a purchase attempt.
public enum StorePurchaseResult: Sendable, Equatable {
    /// The purchase succeeded.
    ///
    /// - Parameter productId: The identifier of the purchased product.
    case success(productId: String)

    /// The user cancelled the purchase.
    case userCancelled

    /// The purchase is pending (e.g., awaiting parental approval).
    case pending
}
