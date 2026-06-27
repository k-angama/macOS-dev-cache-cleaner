import Foundation
import Testing
@testable import DevCacheCleaner

@MainActor
struct BuildStorageCategoriesUseCaseTests {

    @Test func buildsItemsFromConstants() {
        let categories = BuildStorageCategoriesUseCase().execute()
        let expectedSubcategoryCount = Constants.Storages.items.reduce(0) {
            $0 + $1.paths.count
        }
        let actualSubcategoryCount = categories.reduce(0) {
            $0 + $1.categories.count
        }
        let multiLocationPath = Constants.StoragePath(
            name: "Example",
            locations: [
                Constants.StorageLocation(path: "Cache/A"),
                Constants.StorageLocation(
                    path: "Cache/B",
                    rule: .childNamePrefix("example")
                )
            ]
        )
        let flutterCategory = categories.first {
            $0.categories.contains { subcategory in
                subcategory.locations.contains { $0.path == ".pub-cache" }
            }
        }
        let ideCategory = categories.first {
            $0.name == "IDE Caches (VS Code, Cursor, Android Studio...)"
        }
        let ideConstants = Constants.Storages.items.first {
            $0.title == "IDE Caches (VS Code, Cursor, Android Studio...)"
        }
        let vsCodePath = ideConstants?.paths.first {
            $0.name == "VS Code"
        }
        let cursorPath = ideConstants?.paths.first {
            $0.name == "Cursor"
        }
        let androidPath = ideConstants?.paths.first {
            $0.name == "Android"
        }
        let androidStudioCache = ideCategory?.categories.first {
            $0.name == "Android"
        }
        let cursorCache = ideCategory?.categories.first {
            $0.name == "Cursor"
        }
        let swiftPMCache = categories
            .first(where: { $0.name == "Package Manager Caches (npm, Homebrew, CocoaPods...)" })?
            .categories
            .first(where: { $0.name == "SwiftPM" })
        let languageToolchainCaches = categories.first {
            $0.name == "Language Caches (Python, Rust, Go, Flutter...)"
        }
        let jvmBuildToolCaches = categories.first {
            $0.name == "JVM Build Caches (Gradle, Maven...)"
        }
        let gradlePath = Constants.Storages.items
            .first(where: { $0.title == "JVM Build Caches (Gradle, Maven...)" })?
            .paths
            .first(where: { $0.name == "Gradle" })
        let adobePath = Constants.Storages.items
            .first(where: { $0.title == "Design App Caches (Figma, Adobe, Motion...)" })?
            .paths
            .first(where: { $0.name == "Adobe" })

        #expect(categories.count == Constants.Storages.items.count)
        #expect(actualSubcategoryCount == expectedSubcategoryCount)
        #expect(multiLocationPath.name == "Example")
        #expect(multiLocationPath.locations.count == 2)
        #expect(multiLocationPath.locations[0].path == "Cache/A")
        #expect(multiLocationPath.locations[0].rule == .allContents)
        #expect(multiLocationPath.locations[1].path == "Cache/B")
        #expect(multiLocationPath.locations[1].rule == .childNamePrefix("example"))
        #expect(vsCodePath?.locations.count == 4)
        #expect(cursorPath?.locations.count == 7)
        #expect(androidPath?.locations.count == 2)
        #expect(androidPath?.locations.allSatisfy {
            $0.rule == .childNamePrefix("AndroidStudio")
        } == true)
        #expect(gradlePath?.locations.count == 2)
        #expect(adobePath?.locations.count == 4)
        #expect(adobePath?.locations.contains {
            $0.rule == .childNamePrefix("com.adobe.")
        } == true)
        #expect(flutterCategory != nil)
        #expect(flutterCategory?.categories.contains { subcategory in
            subcategory.locations.contains { $0.path == ".pub-cache" }
        } == true)
        #expect(androidStudioCache?.rule == .childNamePrefix("AndroidStudio"))
        #expect(cursorCache?.name == "Cursor")
        #expect(cursorCache?.locations.count == 7)
        #expect(swiftPMCache?.name == "SwiftPM")
        #expect(languageToolchainCaches?.categories.contains(where: { $0.name == "Python / pip" }) == true)
        #expect(languageToolchainCaches?.categories.contains(where: { $0.name == "Rust / Cargo" }) == true)
        #expect(languageToolchainCaches?.categories.contains(where: { $0.name == "Go build cache" }) == true)
        #expect(jvmBuildToolCaches?.categories.contains(where: { $0.name == "Gradle" }) == true)
        #expect(jvmBuildToolCaches?.categories.contains(where: { $0.name == "Maven" }) == true)
    }
}
