//
//  StoreProductInfo.swift
//
//  Created on 18.12.2025.
//  Copyright © 2025 IGR Soft. All rights reserved.
//

import Foundation

/// Information about a store product retrieved from the App Store.
public struct StoreProductInfo: Sendable {
    /// The display name of the product.
    public let name: String

    /// The product description.
    public let description: String

    /// The localized price string (e.g., "$0.99").
    public let price: String

    /// Creates a new product info instance.
    ///
    /// - Parameters:
    ///   - name: The display name of the product.
    ///   - description: The product description.
    ///   - price: The localized price string.
    public init(name: String, description: String, price: String) {
        self.name = name
        self.description = description
        self.price = price
    }
}
