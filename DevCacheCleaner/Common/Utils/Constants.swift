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
        let name: String
        let path: String
        let rule: StoragePathRule
        init(
            _ path: String,
            name: String = "",
            rule: StoragePathRule = .allContents
        ) {
            self.path = path
            self.rule = rule
            self.name = name
        }
    }

    struct Storages {
        static let items: [StorageItem] = [
            StorageItem(
                title: "IDE & Development Tool Caches",
                color: .green,
                paths: [
                    StoragePath("Library/Application Support/Code/Cache", name: "VS Code"),
                    StoragePath("Library/Application Support/Code/CachedData", name: "VS Code"),
                    StoragePath("Library/Caches/com.microsoft.VSCode", name: "VS Code"),
                    StoragePath("Library/Caches/com.microsoft.VSCode.ShipIt", name: "VS Code"),
                    StoragePath("Library/Caches/electron", name: "Electron"),
                    StoragePath("Library/Caches/com.unity3d.unityhub", name: "Unity Hub"),
                    StoragePath("Library/Caches/com.unity3d.unityhub.ShipIt", name: "Unity Hub"),
                    StoragePath("Library/Caches/Google", name: "Android", rule: .childNamePrefix("AndroidStudio")),
                    StoragePath("Library/Caches/JetBrains", name: "Android", rule: .childNamePrefix("AndroidStudio"))
                ]
            ),
            StorageItem(
                title: "Package Manager Caches",
                color: .orange,
                paths: [
                    StoragePath("Library/Caches/Yarn", name: "Yarn"),
                    StoragePath(".npm-cache-user/_cacache", name: "npm"),
                    StoragePath(".npm/_cacache", name: "npm"),
                    StoragePath("Library/pnpm/store", name: "pnpm"),
                    StoragePath(".bun/install/cache", name: "bun"),
                    StoragePath("Library/Caches/CocoaPods", name: "CocoaPods"),
                    StoragePath("Library/Caches/Homebrew", name: "Homebrew"),
                    StoragePath("Library/Caches/pip", name: "pip"),
                    StoragePath("Library/Caches/composer", name: "Composer"),
                    StoragePath("Library/Caches/org.swift.swiftpm", name: "SwiftPM"),
                ]
            ),
            StorageItem(
                title: "Gradle Caches",
                color: .red,
                paths: [
                    StoragePath(".gradle/caches"),
                    StoragePath(".gradle/daemon"),
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
                    StoragePath("Library/Caches/com.apple.dt.xcodebuild", name: "Xcode"),
                    StoragePath("Library/Caches/com.apple.dt.Xcode.sourcecontrol.Git", name: "Xcode"),
                    StoragePath("Library/Developer/CoreSimulator/Caches", name: "CoreSimulator"),
                ]
            ),
            StorageItem(
                title: "Browser Caches",
                color: .brown,
                paths: [
                    StoragePath("Library/Caches/Google/Chrome", name: "Chrome"),
                    StoragePath("Library/Caches/BraveSoftware/Brave-Browser", name: "Brave"),
                    StoragePath("Library/Caches/Firefox", name: "Firefox"),
                    StoragePath("Library/Caches/com.apple.Safari", name: "Safari"),
                    StoragePath("Library/Caches/Microsoft Edge", name: "Edge"),
                    StoragePath("Library/Caches/com.microsoft.edgemac", name: "Edge"),
                    StoragePath("Library/Caches/com.operasoftware.Opera", name: "Opera"),
                    StoragePath("Library/Caches/com.operasoftware.OperaGX", name: "Opera")
                ]
            ),
            StorageItem(
                title: "Flutter/pub-cache",
                color: .pink,
                paths: [
                    StoragePath(".pub-cache"),
                ]
            ),
            StorageItem(
                title: "Design App Caches",
                color: .purple,
                paths: [
                    StoragePath("Library/Caches", name: "Figma", rule: .childNamePrefix("com.figma.")),
                    StoragePath("Library/Caches/Adobe", name: "Adobe"),
                    StoragePath("Library/Caches", name: "Adobe", rule: .childNamePrefix("com.adobe.")),
                    StoragePath("Library/Application Support/Adobe/Common/Media Cache", name: "Adobe"),
                    StoragePath("Library/Application Support/Adobe/Common/Media Cache Files", name: "Adobe"),
                    StoragePath("Library/Application Support/Adobe/AcroCef/DC/Acrobat/Cache", name: "Adobe Acrobat"),
                    StoragePath("Library/Containers/Motion/Data/Library/Caches/com.apple.motionapp/Retiming Cache Files", name:"Motion"),
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
    
    struct Layout {
        struct DetailPanel {
            static let panelWidth: CGFloat = 460
            static let gap: CGFloat = 12
        }

        struct HomePanel {
            static let panelWidth: CGFloat = 600
            static let screenPadding: CGFloat = 8
            
            struct StorageUsage {
                static let categoryRowHeight: CGFloat = 32
                static let categoryActionWidth: CGFloat = 120
                static let workspaceRowHeight: CGFloat = 42
                static let workspaceStateWidth: CGFloat = 82
                static let cleanAllRowHeight: CGFloat = 32
            }
        }
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
