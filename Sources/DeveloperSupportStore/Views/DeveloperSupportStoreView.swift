//
//  DeveloperSupportStoreView.swift
//
//  Created on 18.12.2025.
//  Copyright © 2025 IGR Soft. All rights reserved.
//

import StoreKit
import SwiftUI

/// A SwiftUI view that presents the developer support store interface
/// for subscriptions and in-app purchases.
///
/// Products are loaded automatically from `Products.plist` in your app bundle via StoreHelper.
///
/// Example usage:
/// ```swift
/// DeveloperSupportStoreView(
///     configuration: MyStoreConfiguration(),
///     onPurchaseSuccess: { productId in
///         // Handle successful purchase
///     },
///     onDismiss: {
///         // Dismiss the view
///     }
/// )
/// ```
public struct DeveloperSupportStoreView: View {
    private enum ButtonsFocusable: Hashable {
        case subscribe(String)
        case tips(String)
        case restore
        case close
    }

    @FocusState private var elementFocus: ButtonsFocusable?

    @State private var viewModel: StoreViewModel

    @State private var hoveredProductId: String?

    private let logger: StoreLogger

    /// Creates a new developer support store view.
    ///
    /// - Parameters:
    ///   - configuration: The store configuration with product IDs and appearance settings.
    ///   - storeService: Optional custom store service (created automatically if not provided).
    ///   - onPurchaseSuccess: Called when a purchase succeeds with the product ID.
    ///   - onDismiss: Called when the view should be dismissed.
    public init(
        configuration: any StoreConfigurationProtocol,
        storeService: (any StoreServiceProtocol)? = nil,
        onPurchaseSuccess: @escaping @MainActor (String) -> Void,
        onDismiss: @escaping @MainActor () -> Void
    ) {
        _viewModel = State(wrappedValue: StoreViewModel(
            configuration: configuration,
            storeService: storeService,
            onPurchaseSuccess: onPurchaseSuccess,
            onDismiss: onDismiss
        ))
        logger = StoreLogger(category: "StoreView", isEnabled: configuration.isLoggingEnabled)
    }

    // MARK: - Convenience Accessors

    private var config: any StoreConfigurationProtocol { viewModel.configuration }
    private var colors: StoreColors { config.colors }
    private var typography: StoreTypography { config.typography }
    private var layout: StoreLayoutConstants { config.layout }

    // MARK: - Body

    public var body: some View {
        VStack(spacing: layout.spacingDefault) {
            headerView

            VStack(spacing: layout.spacingHeight) {
                subscriptionSection
                dividerWithText
                oneTimePurchaseSection
            }

            legalLinksFooter
        }
        .onAppear {
            logger.notice("onAppear - initial products:")
            logger.notice("  subscriptionProducts: \(self.viewModel.subscriptionProducts.count)")
            logger.notice("  nonConsumableProducts: \(self.viewModel.nonConsumableProducts.count)")
            if let firstSubscription = viewModel.subscriptionProducts.first {
                elementFocus = .subscribe(firstSubscription.id)
            }
            Task {
                await viewModel.syncStore()
                logger.notice("After syncStore:")
                logger.notice("  subscriptionProducts: \(self.viewModel.subscriptionProducts.count)")
                logger.notice("  nonConsumableProducts: \(self.viewModel.nonConsumableProducts.count)")
            }
        }
        .padding(layout.paddingBig)
        .overlay {
            if viewModel.isLoading {
                ZStack {
                    Rectangle()
                        .fill(.background.opacity(0.8))
                    ProgressView()
                        .progressViewStyle(.circular)
                }
                .ignoresSafeArea()
            }
        }
        .overlay {
            if let restoreResult = viewModel.restoreResult {
                RestoreOverlayView(
                    result: restoreResult,
                    colors: colors,
                    typography: typography,
                    layout: layout,
                    onDismiss: viewModel.dismissRestoreResult
                )
            }
        }
    }

    // MARK: - Header

    @ViewBuilder
    private var headerView: some View {
        HStack {
            closeButton
            Spacer()
            restoreButton
        }
    }

    // MARK: - Subscription Section

    @ViewBuilder
    private var subscriptionSection: some View {
        VStack(spacing: layout.spacingDefault) {
            HStack(spacing: layout.spacingDefault) {
                Image(systemName: "heart.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(colors.selectedView)

                Text("store.title.subscription", bundle: .module)
                    .font(typography.headlineLarge)
                    .foregroundStyle(colors.primaryText)
            }

            ForEach(viewModel.subscriptionProducts, id: \.id) { product in
                subscriptionCard(for: product)
            }
        }
    }

    @ViewBuilder
    private func subscriptionCard(for product: Product) -> some View {
        let info = viewModel.productInfo(for: product)
        let isHovered = hoveredProductId == product.id

        Button {
            Task { await viewModel.purchase(product) }
        } label: {
            HStack(spacing: layout.spacingDefault) {
                ZStack {
                    Circle()
                        .fill(colors.selectedView.opacity(0.2))
                        .frame(width: 48, height: 48)

                    Image(systemName: "cup.and.saucer.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(colors.selectedView)
                }

                VStack(alignment: .leading, spacing: layout.spacingSmall) {
                    Text(info.name)
                        .font(typography.headlineMedium)
                        .foregroundStyle(colors.primaryText)

                    Text(info.description)
                        .font(typography.bodyMedium)
                        .foregroundStyle(colors.secondaryText)
                        .lineLimit(2)
                }

                Spacer()

                VStack(spacing: layout.spacingSmall) {
                    Text(info.price)
                        .font(typography.headlineSmall)
                        .foregroundStyle(colors.primaryText)

                    Text("store.price.perMonth", bundle: .module)
                        .font(typography.labelSmall)
                        .foregroundStyle(colors.secondaryText)
                }
                .padding(.horizontal, layout.paddingSmall)
                .padding(.vertical, layout.paddingThin)
                .background(colors.selectedView.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: layout.radiusThin))
            }
            .padding(layout.paddingDefault)
            .background(
                RoundedRectangle(cornerRadius: layout.radiusDefault)
                    .fill(colors.secondaryBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: layout.radiusDefault)
                    .strokeBorder(
                        isHovered ? colors.selectedView : colors.selectedView.opacity(0.5),
                        lineWidth: isHovered ? 2 : 1.5
                    )
            )
            .scaleEffect(isHovered ? 1.02 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isHovered)
        }
        .buttonStyle(.plain)
        .focused($elementFocus, equals: .subscribe(product.id))
        .focusEffectDisabled()
        .onHover { hovering in
            hoveredProductId = hovering ? product.id : nil
        }
        .help(Text("store.button.purchase", bundle: .module))
    }

    // MARK: - Divider

    @ViewBuilder
    private var dividerWithText: some View {
        HStack(spacing: layout.spacingDefault) {
            Rectangle()
                .fill(colors.secondaryText.opacity(0.3))
                .frame(height: 1)

            Text("store.title.oneTime", bundle: .module)
                .font(typography.labelMedium)
                .foregroundStyle(colors.secondaryText)

            Rectangle()
                .fill(colors.secondaryText.opacity(0.3))
                .frame(height: 1)
        }
        .padding(.vertical, layout.paddingSmall)
    }

    // MARK: - One-Time Purchases Section

    @ViewBuilder
    private var oneTimePurchaseSection: some View {
        HStack(spacing: layout.spacingDefault) {
            ForEach(Array(viewModel.nonConsumableProducts.enumerated()), id: \.element.id) { index, product in
                oneTimePurchaseCard(for: product, isFirst: index == 0)
            }
        }
    }

    @ViewBuilder
    private func oneTimePurchaseCard(for product: Product, isFirst: Bool) -> some View {
        let info = viewModel.productInfo(for: product)
        let isHovered = hoveredProductId == product.id
        let icon = isFirst ? "cup.and.saucer" : "takeoutbag.and.cup.and.straw"

        Button {
            Task { await viewModel.purchase(product) }
        } label: {
            VStack(spacing: layout.spacingDefault) {
                ZStack {
                    Circle()
                        .fill(colors.secondaryBackground)
                        .frame(width: 56, height: 56)

                    Image(systemName: icon)
                        .font(.system(size: 24))
                        .foregroundStyle(colors.primaryText)
                }

                Text(info.name)
                    .font(typography.headlineSmall)
                    .foregroundStyle(colors.primaryText)

                Text(info.description)
                    .font(typography.bodySmall)
                    .foregroundStyle(colors.secondaryText)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .frame(minHeight: 36)

                Spacer(minLength: 0)

                Text(info.price)
                    .font(typography.headlineMedium)
                    .foregroundStyle(colors.primaryText)
            }
            .padding(layout.paddingDefault)
            .frame(maxWidth: 220, minHeight: 180)
            .background(
                RoundedRectangle(cornerRadius: layout.radiusDefault)
                    .fill(colors.secondaryBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: layout.radiusDefault)
                    .strokeBorder(
                        isHovered ? colors.primaryText.opacity(0.5) : colors.primaryText.opacity(0.2),
                        lineWidth: isHovered ? 1.5 : 1
                    )
            )
            .scaleEffect(isHovered ? 1.02 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isHovered)
        }
        .buttonStyle(.plain)
        .focused($elementFocus, equals: .tips(product.id))
        .focusEffectDisabled()
        .onHover { hovering in
            hoveredProductId = hovering ? product.id : nil
        }
        .help(Text("store.button.purchase", bundle: .module))
    }

    // MARK: - Legal Links Footer

    @ViewBuilder
    private var legalLinksFooter: some View {
        HStack(spacing: layout.spacingDefault) {
            Link(destination: config.privacyPolicyURL) {
                Text("store.link.privacyPolicy", bundle: .module)
                    .font(typography.labelSmall)
                    .foregroundStyle(colors.secondaryText)
            }
            .buttonStyle(.plain)

            Text("\u{2022}")
                .font(typography.labelSmall)
                .foregroundStyle(colors.secondaryText.opacity(0.5))

            Link(destination: config.termsOfUseURL) {
                Text("store.link.termsOfUse", bundle: .module)
                    .font(typography.labelSmall)
                    .foregroundStyle(colors.secondaryText)
            }
            .buttonStyle(.plain)
        }
        .padding(.top, layout.paddingSmall)
    }

    // MARK: - Header Buttons

    @ViewBuilder
    private var restoreButton: some View {
        Button {
            Task { await viewModel.syncStore(showResult: true) }
        } label: {
            Image(systemName: "arrow.counterclockwise")
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(colors.secondaryText)
                .frame(width: 36, height: 36)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .focused($elementFocus, equals: .restore)
        .focusEffectDisabled()
        .help(Text("store.button.restore", bundle: .module))
        .accessibilityLabel(Text("store.button.restore", bundle: .module))
    }

    @ViewBuilder
    private var closeButton: some View {
        Button(action: viewModel.onDismiss) {
            Image(systemName: "xmark.circle.fill")
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(colors.secondaryText)
                .frame(width: 36, height: 36)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .focused($elementFocus, equals: .close)
        .focusEffectDisabled()
        .help(Text("store.button.close", bundle: .module))
        .accessibilityLabel(Text("store.button.close", bundle: .module))
    }
}

// MARK: - Preview Configuration

private struct PreviewConfiguration: StoreConfigurationProtocol {
    var privacyPolicyURL: URL { URL(string: "https://example.com/privacy")! }
    var termsOfUseURL: URL { URL(string: "https://example.com/terms")! }
}

#Preview("DeveloperSupportStoreView") {
    let config = PreviewConfiguration()
    let previewService = StoreServicePreview.withDefaultMockData()

    DeveloperSupportStoreView(
        configuration: config,
        storeService: previewService,
        onPurchaseSuccess: { _ in },
        onDismiss: {}
    )
    .frame(width: 400, height: 500)
}

#Preview("DeveloperSupportStoreView - With Subscription") {
    let config = PreviewConfiguration()
    let previewService = StoreServicePreview.withDefaultMockData(hasActiveSubscription: true)

    DeveloperSupportStoreView(
        configuration: config,
        storeService: previewService,
        onPurchaseSuccess: { _ in },
        onDismiss: {}
    )
    .frame(width: 400, height: 500)
}
