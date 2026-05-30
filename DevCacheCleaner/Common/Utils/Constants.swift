//
//  Constants.swift
//  DevCacheCleaner
//
//  Created by Karim Angama on 06/03/2026.
//

import Foundation
import SwiftUI

struct Constants {
    
    // MARK: - Storage Definitions
    struct StorageItem {
        let title: String
        let color: Color
        let paths: [StoragePath]
    }

    struct StoragePath {
        let path: String
        let rule: StoragePathRule

        init(_ path: String, rule: StoragePathRule = .allContents) {
            self.path = path
            self.rule = rule
        }
    }

    struct Storages {
        static let items: [StorageItem] = [
            StorageItem(
                title: "IDE (JetBrains, VSCode) Caches",
                color: .green,
                paths: [
                    StoragePath("Library/Caches/CocoaPods"),
                    StoragePath("Library/Application Support/Code/Cache"),
                    StoragePath("Library/Application Support/Code/CachedData"),
                    StoragePath("Library/Application Support/Code/User/workspaceStorage")
                ]
            ),
            StorageItem(
                title: "CocoaPods Caches",
                color: .yellow,
                paths: [
                    StoragePath(".cocoapods/repos"),
                    StoragePath("Library/Caches/CocoaPods"),
                ]
            ),
            StorageItem(
                title: "npm/yarn Caches",
                color: .orange,
                paths: [
                    StoragePath("Library/Caches/Yarn"),
                    StoragePath(".npm-cache-user/_cacache"),
                ]
            ),
            StorageItem(
                title: "Android/Gradle Caches",
                color: .red,
                paths: [
                    StoragePath(".gradle/caches"),
                    StoragePath(".gradle/daemon"),
                    StoragePath("Library/Caches/Google", rule: .childNamePrefix("AndroidStudio")),
                    StoragePath("Library/Caches/JetBrains", rule: .childNamePrefix("AndroidStudio"))
                ]
            ),
            StorageItem(
                title: "Xcode Caches & DerivedData",
                color: .blue,
                paths: [
                    StoragePath("Library/Developer/Xcode/DerivedData"),
                    StoragePath("Library/Developer/Xcode/iOS DeviceSupport"),
                    StoragePath("Library/Caches/com.apple.dt.Xcode"),
                    StoragePath("Library/Developer/Xcode/Archives"),
                    StoragePath("Library/Developer/Xcode/Products"),
                    StoragePath("Library/Developer/Xcode/DocumentationCache"),
                    StoragePath("Library/Developer/CoreSimulator/Devices"),
                ]
            ),
            StorageItem(
                title: "Browser Caches (Chrome, Brave, Firefox, Safari, Edge, Opera)",
                color: .brown,
                paths: [
                    StoragePath("Library/Caches/Google/Chrome"),
                    StoragePath("Library/Caches/BraveSoftware/Brave-Browser"),
                    StoragePath("Library/Caches/Firefox"),
                    StoragePath("Library/Caches/com.apple.Safari"),
                    StoragePath("Library/Caches/Microsoft Edge"),
                    StoragePath("Library/Caches/com.microsoft.edgemac"),
                    StoragePath("Library/Caches/com.operasoftware.Opera"),
                    StoragePath("Library/Caches/com.operasoftware.OperaGX")
                ]
            ),
            StorageItem(
                title: "Flutter/pub-cache",
                color: .pink,
                paths: [
                    StoragePath(".pub-cache"),
                ]
            ),
        ]
    }
    
    struct WindowIds {
        static let cleanupProgress = "cleanup-progress-dev-cache-cleaner"
        static let about = "about-dev-cache-cleaner"
        static let help = "help-dev-cache-cleaner"
        static let support = "support-dev-cache-cleaner"
        static let settings = "about-dev-cache-settings"
    }

    struct StorageCategoryDetails {
        static let panelWidth: CGFloat = 460
    }
    
    struct About {
        static var version: String = {
            Bundle.main
                .infoDictionary?["CFBundleShortVersionString"] as? String ?? "N/A"
        }()
        static var build: String = {
            Bundle.main
                .infoDictionary?["CFBundleVersion"] as? String ?? "N/A"
        }()
        static var copyright: String = {
            let calendar = Calendar.current
            let year = calendar.component(.year, from: Date())
            return "© \(year)"
        }()
        static var displayName: String = {
            let info = Bundle.main.infoDictionary ?? [:]
            return info["CFBundleDisplayName"] as? String
                ?? info["CFBundleName"] as? String
                ?? "DevCacheCleaner"
        }()
        static let websiteURL = URL(string: "https://www.kangama.com/")!
        static let linkedInURL = URL(string: "https://www.linkedin.com/in/karim-angama")!
        static let gitHub = URL(string: "https://github.com/k-angama/macOS-dev-cache-Cleaner")!
    }

    struct SupportTips {
        static let coffee = "com.kangama.devcachecleaner.tip.coffee"
        static let lunch = "com.kangama.devcachecleaner.tip.lunch"
        static let sponsor = "com.kangama.devcachecleaner.tip.sponsor"

        static let all = [
            coffee,
            lunch,
            sponsor
        ]
    }

}
