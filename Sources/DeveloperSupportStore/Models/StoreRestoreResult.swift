//
//  StoreRestoreResult.swift
//
//  Created on 09.01.2026.
//  Copyright © 2026 IGR Soft. All rights reserved.
//

import Foundation

/// Represents the result of a restore purchases action.
public enum StoreRestoreResult: Sendable, Equatable {
    /// The restore completed successfully with purchases found.
    case success
    /// The restore failed with an error.
    case failure
    /// The restore completed but no previous purchases were found.
    case nothingToRestore
}
