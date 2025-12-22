//
//  StoreLogger.swift
//
//  Created on 22.12.2025.
//  Copyright © 2025 IGR Soft. All rights reserved.
//

import os.log

/// A conditional logger that respects the store configuration's logging setting.
///
/// When logging is disabled, all log calls are no-ops.
struct StoreLogger: Sendable {
    private let logger: Logger
    private let isEnabled: Bool

    /// Creates a store logger.
    ///
    /// - Parameters:
    ///   - category: The logging category.
    ///   - isEnabled: Whether logging is enabled.
    init(category: String, isEnabled: Bool) {
        logger = Logger(subsystem: "DeveloperSupportStore", category: category)
        self.isEnabled = isEnabled
    }

    /// Logs a notice message.
    func notice(_ message: String) {
        guard isEnabled else { return }
        logger.notice("\(message, privacy: .public)")
    }

    /// Logs an error message.
    func error(_ message: String) {
        guard isEnabled else { return }
        logger.error("\(message, privacy: .public)")
    }

    /// Logs a debug message.
    func debug(_ message: String) {
        guard isEnabled else { return }
        logger.debug("\(message, privacy: .public)")
    }
}
