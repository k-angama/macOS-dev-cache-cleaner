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
            container.cleanerHomeDI.start()
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
                container.cleanupProgressDI.start(data: categoryName)
                .frame(width: 600)
            }
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        .defaultPosition(.center)
        
        Window("About DevCacheCleaner", id: Constants.WindowIds.about) {
            AboutView()
                .windowMinimizeBehavior(.disabled)
                .containerBackground(.regularMaterial, for: .window)
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        .defaultPosition(.center)

        Window("Help DevCacheCleaner", id: Constants.WindowIds.help) {
            HelpView()
                .windowMinimizeBehavior(.disabled)
                .containerBackground(.regularMaterial, for: .window)
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        .defaultPosition(.center)

        Window("Support DevCacheCleaner", id: Constants.WindowIds.support) {
            container.supportDI.start()
                .windowMinimizeBehavior(.disabled)
                .containerBackground(.regularMaterial, for: .window)
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        .defaultPosition(.center)
        
        Window("Settings DevCacheCleaner", id: Constants.WindowIds.settings) {
            container.settingsDI.start()
                .windowMinimizeBehavior(.disabled)
                .windowFullScreenBehavior(.disabled)
                .windowResizeBehavior(.disabled)
        }
        .windowResizability(.contentSize)
        .defaultPosition(.center)
    }
}
