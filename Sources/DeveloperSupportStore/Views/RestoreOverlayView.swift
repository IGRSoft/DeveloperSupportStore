//
//  RestoreOverlayView.swift
//
//  Created on 09.01.2026.
//  Copyright © 2026 IGR Soft. All rights reserved.
//

import SwiftUI

/// A top overlay view that displays the result of a restore purchases action.
///
/// Shows a banner at the top of the screen with success or failure status,
/// automatically dismissing after a configurable duration.
struct RestoreOverlayView: View {
    /// The result to display.
    let result: StoreRestoreResult

    /// Color configuration.
    let colors: StoreColors

    /// Typography configuration.
    let typography: StoreTypography

    /// Layout configuration.
    let layout: StoreLayoutConstants

    /// Action to dismiss the overlay.
    let onDismiss: () -> Void

    /// Duration before auto-dismissing (in seconds).
    private let autoDismissDelay: TimeInterval = 3.0

    @State private var isVisible: Bool = false

    var body: some View {
        VStack {
            bannerContent
                .padding(.horizontal, layout.paddingDefault)
                .padding(.vertical, layout.paddingSmall)
                .background(
                    RoundedRectangle(cornerRadius: layout.radiusDefault)
                        .fill(backgroundColor)
                        .shadow(color: .black.opacity(0.2), radius: 8, y: 4)
                )
                .padding(.horizontal, layout.paddingBig)
                .padding(.top, layout.paddingDefault)
                .offset(y: isVisible ? 0 : -100)
                .opacity(isVisible ? 1 : 0)

            Spacer()
        }
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                isVisible = true
            }
            scheduleAutoDismiss()
        }
        .onTapGesture {
            dismissWithAnimation()
        }
    }

    // MARK: - Banner Content

    @ViewBuilder
    private var bannerContent: some View {
        HStack(spacing: layout.spacingDefault) {
            Image(systemName: iconName)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(iconColor)

            Text(messageKey, bundle: .module)
                .font(typography.bodyMedium)
                .foregroundStyle(colors.primaryText)

            Spacer()

            Button {
                dismissWithAnimation()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(colors.primaryText.opacity(0.6))
                    .frame(width: 24, height: 24)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Styling

    private var backgroundColor: Color {
        switch result {
        case .success:
            return colors.selectedView.opacity(0.9)
        case .failure:
            return Color.red.opacity(0.9)
        }
    }

    private var iconName: String {
        switch result {
        case .success:
            return "checkmark.circle.fill"
        case .failure:
            return "exclamationmark.triangle.fill"
        }
    }

    private var iconColor: Color {
        colors.primaryText
    }

    private var messageKey: LocalizedStringKey {
        switch result {
        case .success:
            return "store.restore.success"
        case .failure:
            return "store.restore.failure"
        }
    }

    // MARK: - Actions

    private func scheduleAutoDismiss() {
        Task {
            try? await Task.sleep(for: .seconds(autoDismissDelay))
            dismissWithAnimation()
        }
    }

    private func dismissWithAnimation() {
        withAnimation(.easeOut(duration: 0.25)) {
            isVisible = false
        }
        Task {
            try? await Task.sleep(for: .milliseconds(250))
            onDismiss()
        }
    }
}

// MARK: - Preview

#Preview("Restore Success") {
    ZStack {
        Color.black.ignoresSafeArea()

        RestoreOverlayView(
            result: .success,
            colors: .default,
            typography: .default,
            layout: .default,
            onDismiss: {}
        )
    }
}

#Preview("Restore Failure") {
    ZStack {
        Color.black.ignoresSafeArea()

        RestoreOverlayView(
            result: .failure,
            colors: .default,
            typography: .default,
            layout: .default,
            onDismiss: {}
        )
    }
}
