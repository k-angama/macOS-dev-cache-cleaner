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
        let locations: [StorageLocation]

        init(
            name: String = "",
            locations: [StorageLocation]
        ) {
            self.name = name
            self.locations = locations
        }

        init(
            _ path: String,
            name: String = "",
            rule: StoragePathRule = .allContents
        ) {
            self.init(
                name: name,
                locations: [
                    StorageLocation(path: path, rule: rule)
                ]
            )
        }
    }

    struct StorageLocation {
        let path: String
        let rule: StoragePathRule

        init(
            path: String,
            rule: StoragePathRule = .allContents
        ) {
            self.path = path
            self.rule = rule
        }
    }

    struct Storages {
        static let items: [StorageItem] = [
            StorageItem(
                title: "IDE Caches (VS Code, Cursor, Android Studio...)",
                color: .green,
                paths: [
                    StoragePath(
                        name: "VS Code",
                        locations: [
                            StorageLocation(path: "Library/Application Support/Code/Cache"),
                            StorageLocation(path: "Library/Application Support/Code/CachedData"),
                            StorageLocation(path: "Library/Caches/com.microsoft.VSCode"),
                            StorageLocation(path: "Library/Caches/com.microsoft.VSCode.ShipIt"),
                        ]
                    ),
                    StoragePath(
                        name: "Cursor",
                        locations: [
                            StorageLocation(path: "Library/Application Support/Cursor/Cache"),
                            StorageLocation(path: "Library/Application Support/Cursor/CachedData"),
                            StorageLocation(path: "Library/Application Support/Cursor/CachedExtensionVSIXs"),
                            StorageLocation(path: "Library/Application Support/Cursor/Code Cache"),
                            StorageLocation(path: "Library/Application Support/Cursor/GPUCache"),
                            StorageLocation(path: "Library/Caches/com.todesktop.230313mzl4w4u92"),
                            StorageLocation(path: "Library/Caches/com.todesktop.230313mzl4w4u92.ShipIt"),
                        ]
                    ),
                    StoragePath(
                        name: "Unity Hub",
                        locations: [
                            StorageLocation(path: "Library/Caches/com.unity3d.unityhub"),
                            StorageLocation(path: "Library/Caches/com.unity3d.unityhub.ShipIt"),
                        ]
                    ),
                    StoragePath(
                        name: "Android",
                        locations: [
                            StorageLocation(
                                path: "Library/Caches/Google",
                                rule: .childNamePrefix("AndroidStudio")
                            ),
                            StorageLocation(
                                path: "Library/Caches/JetBrains",
                                rule: .childNamePrefix("AndroidStudio")
                            ),
                        ]
                    ),
                ]
            ),
            StorageItem(
                title: "Package Manager Caches (npm, Homebrew, CocoaPods...)",
                color: .orange,
                paths: [
                    StoragePath("Library/Caches/Yarn", name: "Yarn"),
                    StoragePath(
                        name: "npm",
                        locations: [
                            StorageLocation(path: ".npm-cache-user/_cacache"),
                            StorageLocation(path: ".npm/_cacache"),
                        ]
                    ),
                    StoragePath("Library/pnpm/store", name: "pnpm"),
                    StoragePath(".bun/install/cache", name: "bun"),
                    StoragePath("Library/Caches/CocoaPods", name: "CocoaPods"),
                    StoragePath("Library/Caches/Homebrew", name: "Homebrew"),
                    StoragePath("Library/Caches/composer", name: "Composer"),
                    StoragePath("Library/Caches/org.swift.swiftpm", name: "SwiftPM"),
                ]
            ),
            StorageItem(
                title: "Language Caches (Python, Rust, Go, Flutter...)",
                color: .pink,
                paths: [
                    StoragePath("Library/Caches/pip", name: "Python / pip"),
                    StoragePath("Library/Caches/uv", name: "Python / uv"),
                    StoragePath("Library/Caches/pypoetry", name: "Python / Poetry"),
                    StoragePath(
                        name: "Rust / Cargo",
                        locations: [
                            StorageLocation(path: ".cargo/registry/cache"),
                            StorageLocation(path: ".cargo/registry/src"),
                            StorageLocation(path: ".cargo/git/checkouts"),
                            StorageLocation(path: ".cargo/git/db"),
                        ]
                    ),
                    StoragePath("Library/Caches/go-build", name: "Go build cache"),
                    StoragePath("go/pkg/mod", name: "Go module cache"),
                    StoragePath(".pub-cache", name: "Flutter / Dart"),
                ]
            ),
            StorageItem(
                title: "JVM Build Caches (Gradle, Maven...)",
                color: .red,
                paths: [
                    StoragePath(
                        name: "Gradle",
                        locations: [
                            StorageLocation(path: ".gradle/caches"),
                            StorageLocation(path: ".gradle/daemon"),
                        ]
                    ),
                    StoragePath(".m2/repository", name: "Maven"),
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
                    StoragePath(
                        name: "Xcode",
                        locations: [
                            StorageLocation(path: "Library/Caches/com.apple.dt.xcodebuild"),
                            StorageLocation(path: "Library/Caches/com.apple.dt.Xcode.sourcecontrol.Git"),
                        ]
                    ),
                    StoragePath("Library/Developer/CoreSimulator/Caches", name: "CoreSimulator"),
                ]
            ),
            StorageItem(
                title: "Browser Caches (Chrome, Safari, Firefox...)",
                color: .brown,
                paths: [
                    StoragePath("Library/Caches/Google/Chrome", name: "Chrome"),
                    StoragePath("Library/Caches/BraveSoftware/Brave-Browser", name: "Brave"),
                    StoragePath("Library/Caches/Firefox", name: "Firefox"),
                    StoragePath("Library/Caches/com.apple.Safari", name: "Safari"),
                    StoragePath(
                        name: "Edge",
                        locations: [
                            StorageLocation(path: "Library/Caches/Microsoft Edge"),
                            StorageLocation(path: "Library/Caches/com.microsoft.edgemac"),
                        ]
                    ),
                    StoragePath(
                        name: "Opera",
                        locations: [
                            StorageLocation(path: "Library/Caches/com.operasoftware.Opera"),
                            StorageLocation(path: "Library/Caches/com.operasoftware.OperaGX"),
                        ]
                    ),
                ]
            ),
            StorageItem(
                title: "Design App Caches (Figma, Adobe, Motion...)",
                color: .purple,
                paths: [
                    StoragePath("Library/Caches", name: "Figma", rule: .childNamePrefix("com.figma.")),
                    StoragePath(
                        name: "Adobe",
                        locations: [
                            StorageLocation(path: "Library/Caches/Adobe"),
                            StorageLocation(
                                path: "Library/Caches",
                                rule: .childNamePrefix("com.adobe.")
                            ),
                            StorageLocation(path: "Library/Application Support/Adobe/Common/Media Cache"),
                            StorageLocation(path: "Library/Application Support/Adobe/Common/Media Cache Files"),
                        ]
                    ),
                    StoragePath("Library/Application Support/Adobe/AcroCef/DC/Acrobat/Cache", name: "Adobe Acrobat"),
                    StoragePath("Library/Containers/Motion/Data/Library/Caches/com.apple.motionapp/Retiming Cache Files", name: "Motion"),
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
