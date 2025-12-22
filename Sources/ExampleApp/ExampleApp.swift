//
//  ExampleApp.swift
//
//  Example app demonstrating DeveloperSupportStore on iOS and macOS.
//  Copyright © 2025 IGR Soft. All rights reserved.
//

import DeveloperSupportStore
import SwiftUI

// MARK: - Example Configuration

/// Example store configuration.
/// Product IDs are loaded automatically from Products.plist by StoreHelper.
struct ExampleStoreConfiguration: StoreConfigurationProtocol {
    var privacyPolicyURL: URL {
        URL(string: "https://example.com/privacy")!
    }

    var termsOfUseURL: URL {
        URL(string: "https://example.com/terms")!
    }
}

// MARK: - App Entry Point

#if os(macOS)
    import AppKit

    final class AppDelegate: NSObject, NSApplicationDelegate {
        func applicationDidFinishLaunching(_: Notification) {
            NSApp.setActivationPolicy(.regular)
            NSApp.activate(ignoringOtherApps: true)
        }
    }
#else
    import UIKit

    final class AppDelegate: NSObject, UIApplicationDelegate {
        func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
            return true
        }
    }
#endif

@main
struct ExampleApp: App {
    #if os(macOS)
        @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    #else
        @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    #endif

    @State private var isStorePresented = false

    var body: some Scene {
        WindowGroup {
            ContentView(isStorePresented: $isStorePresented)
        }
        #if os(macOS)
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        #endif
    }
}

// MARK: - Content View

struct ContentView: View {
    @Binding var isStorePresented: Bool

    private let configuration = ExampleStoreConfiguration()
    private var previewService: StoreServicePreview {
        .withDefaultMockData()
    }

    var body: some View {
        launcherView
            .sheet(isPresented: $isStorePresented) {
                DeveloperSupportStoreView(
                    configuration: configuration,
                    storeService: previewService,
                    onPurchaseSuccess: { productId in
                        print("✅ Purchase successful: \(productId)")
                    },
                    onDismiss: {
                        isStorePresented = false
                    }
                )
            }
        #if os(iOS)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        #else
            .frame(width: 420, height: 580)
        #endif
    }

    @ViewBuilder
    private var storeView: some View {
        DeveloperSupportStoreView(
            configuration: configuration,
            storeService: previewService,
            onPurchaseSuccess: { productId in
                print("✅ Purchase successful: \(productId)")
            },
            onDismiss: {
                isStorePresented = false
            }
        )
    }

    @ViewBuilder
    private var launcherView: some View {
        VStack(spacing: 24) {
            Image(systemName: "heart.fill")
                .font(.system(size: 64))
                .foregroundStyle(.pink)

            Text("DeveloperSupportStore")
                .font(.title)
                .fontWeight(.bold)

            Text("Example App")
                .font(.headline)
                .foregroundStyle(.secondary)

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
}

// MARK: - Previews

#Preview("Example App - Launcher") {
    ContentView(isStorePresented: .constant(false))
        .frame(width: 420, height: 580)
}

#Preview("Example App - Store") {
    ContentView(isStorePresented: .constant(true))
        .frame(width: 420, height: 580)
}
