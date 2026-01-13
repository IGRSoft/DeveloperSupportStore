//
//  ContentView.swift
//  DeveloperSupportStoreExample
//
//  Example demonstrating DeveloperSupportStore integration.
//

import DeveloperSupportStore
import SwiftUI

// MARK: - Store Configuration

/// Example store configuration.
/// Product IDs are loaded automatically from Products.plist by StoreHelper.
public struct ExampleStoreConfiguration: StoreConfigurationProtocol {
    public var privacyPolicyURL: URL {
        URL(string: "https://igrsoft.com/info/app/developersupporstoreapp/policy.html")!
    }

    public var termsOfUseURL: URL {
        URL(string: "https://igrsoft.com/info/app/developersupporstoreapp/terms.html")!
    }

    public init() {}
}

// MARK: - Content View

public struct ContentView: View {
    @State private var isStorePresented = false
    @State private var storeService: StoreServiceProtocol = StoreService(isLoggingEnabled: true)
    private let configuration = ExampleStoreConfiguration()

    public var body: some View {
        launcherView
            .sheet(isPresented: $isStorePresented) {
                DeveloperSupportStoreView(
                    configuration: configuration,
                    storeService: storeService,
                    onPurchaseSuccess: { productId in
                        print("Purchase successful: \(productId)")
                    },
                    onDismiss: {
                        isStorePresented = false
                    }
                )
            }
            .task {
                try? await storeService.syncStoreData()
            }
    }

    @ViewBuilder
    private var launcherView: some View {
        VStack(spacing: 24) {
            HStack {
                Image(systemName: "heart.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(storeService.hasPurchasedProducts ? .green : .pink)
                
                Image(systemName: "heart.fill")
                    .font(.system(size: 64))
                    .foregroundStyle( storeService.hasActiveSubscription ? .green : .pink)
            }

            Text("DeveloperSupportStore")
                .font(.title)
                .fontWeight(.bold)

            Text("Example App")
                .font(.headline)
                .foregroundStyle(.secondary)

            Text("Products are loaded from Products.plist")
                .font(.caption)
                .foregroundStyle(.tertiary)

            Button {
                isStorePresented = true
            } label: {
                Label("Open Store", systemImage: "storefront")
                    .font(.headline)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
            }
            .buttonStyle(.borderedProminent)
            .tint(.pink)
        }
        .padding(40)
    }

    public init() {}
}

// MARK: - Preview

#Preview("Launcher") {
    ContentView()
}

#Preview("Store View") {
    let config = ExampleStoreConfiguration()
    let previewService = StoreService()

    DeveloperSupportStoreView(
        configuration: config,
        storeService: previewService,
        onPurchaseSuccess: { _ in },
        onDismiss: {}
    )
    .frame(width: 400, height: 500)
}
