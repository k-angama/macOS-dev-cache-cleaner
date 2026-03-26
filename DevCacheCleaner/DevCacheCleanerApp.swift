//
//  DevCacheCleanerApp.swift
//  DevCacheCleaner
//
//  Created by Karim Angama on 05/03/2026.
//

import SwiftUI

@main
struct DevCacheCleanerApp: App {
    private var container = AppContainer()

    var body: some Scene {
        MenuBarExtra {
            CleanerHomeView(viewModel: container.cleanerHomeViewModel)
                .frame(width: 600)
        } label: {
            Image("FeatherDusterIcon")
                .renderingMode(.template)
                .interpolation(.high)
                .accessibilityLabel("DevCacheCleaner")
        }
        .menuBarExtraStyle(.window)
        
        WindowGroup("Cleanup Progress", id: Constants.WindowIds.cleanupProgress, for: String.self) { $categoryName in
            if let categoryName = categoryName {
                CleanupProgressView(
                    viewModel: container.cleanupProgressViewModel,
                    selectedCategoryName: categoryName
                )
                .frame(width: 600)
            }
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        
        Window("About DevCacheCleaner", id: Constants.WindowIds.about) {
            AboutView()
                .windowMinimizeBehavior(.disabled)
                .containerBackground(.regularMaterial, for: .window)
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
    }
}
