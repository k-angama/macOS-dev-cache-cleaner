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
        let paths: [String: String]
    }

    struct Storages {
        static let items: [StorageItem] = [
            StorageItem(
                title: "IDE (JetBrains, VSCode) Caches",
                color: .green,
                paths: [
                    "Library/Caches/CocoaPods": "",
                    "Library/Application Support/Code/Cache": "",
                    "Library/Application Support/Code/CachedData": "",
                    "Library/Application Support/Code/User/workspaceStorage": ""
                ]
            ),
            StorageItem(
                title: "CocoaPods Caches",
                color: .yellow,
                paths: [
                    ".cocoapods/repos": "",
                    "Library/Caches/CocoaPods": "",
                ]
            ),
            StorageItem(
                title: "npm/yarn Caches",
                color: .orange,
                paths: [
                    "Library/Caches/Yarn": "",
                    ".npm-cache-user/_cacache": "",
                ]
            ),
            StorageItem(
                title: "Android/Gradle Caches",
                color: .red,
                paths: [
                    ".gradle/caches": "",
                    ".gradle/daemon": "",
                    "Library/Caches/Google": "AndroidStudio",
                    "Library/Caches/JetBrains": "AndroidStudio"
                ]
            ),
            StorageItem(
                title: "Xcode Caches & DerivedData",
                color: .blue,
                paths: [
                    "Library/Developer/Xcode/DerivedData": "",
                    "Library/Developer/Xcode/iOS DeviceSupport": "",
                    "Library/Caches/com.apple.dt.Xcode": "",
                    "Library/Developer/Xcode/Archives": "",
                    "Library/Developer/Xcode/Products": "",
                    "Library/Developer/Xcode/DocumentationCache": "",
                    "Library/Developer/CoreSimulator/Devices": "",
                ]
            ),
            StorageItem(
                title: "Browser Caches (Chrome, Brave, Firefox, Safari, Edge, Opera)",
                color: .brown,
                paths: [
                    "Library/Caches/Google/Chrome": "",
                    "Library/Caches/BraveSoftware/Brave-Browser": "",
                    "Library/Caches/Firefox": "",
                    "Library/Caches/com.apple.Safari": "",
                    "Library/Caches/Microsoft Edge": "",
                    "Library/Caches/com.microsoft.edgemac": "",
                    "Library/Caches/com.operasoftware.Opera": "",
                    "Library/Caches/com.operasoftware.OperaGX": ""
                ]
            ),
            StorageItem(
                title: "Flutter/pub-cache",
                color: .pink,
                paths: [
                    ".pub-cache": "",
                ]
            ),
        ]
    }
    
    struct WindowIds {
        static let cleanupProgress = "cleanup-progress"
        static let about = "about-dev-cache-cleaner"
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
}
