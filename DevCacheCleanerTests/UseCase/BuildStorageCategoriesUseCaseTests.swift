import Foundation
import Testing
@testable import DevCacheCleaner

@MainActor
struct BuildStorageCategoriesUseCaseTests {

    @Test func buildsItemsFromConstants() {
        let categories = BuildStorageCategoriesUseCase().execute()
        let flutterCategory = categories.first {
            $0.categories.contains(where: { $0.path == ".pub-cache" })
        }
        let ideCategory = categories.first {
            $0.name == "IDE Caches (VS Code, Cursor, Android Studio...)"
        }
        let androidStudioCache = ideCategory?.categories.first {
            $0.path == "Library/Caches/Google"
        }
        let cursorCache = ideCategory?.categories.first {
            $0.path == "Library/Application Support/Cursor/Cache"
        }
        let swiftPMCache = categories
            .first(where: { $0.name == "Package Manager Caches (npm, Homebrew, CocoaPods...)" })?
            .categories
            .first(where: { $0.path == "Library/Caches/org.swift.swiftpm" })
        let languageToolchainCaches = categories.first {
            $0.name == "Language Caches (Python, Rust, Go, Flutter...)"
        }
        let jvmBuildToolCaches = categories.first {
            $0.name == "JVM Build Caches (Gradle, Maven...)"
        }

        #expect(categories.count == Constants.Storages.items.count)
        #expect(flutterCategory != nil)
        #expect(flutterCategory?.categories.contains(where: { $0.path == ".pub-cache" }) == true)
        #expect(androidStudioCache?.rule == .childNamePrefix("AndroidStudio"))
        #expect(cursorCache?.name == "Cursor")
        #expect(swiftPMCache?.name == "SwiftPM")
        #expect(languageToolchainCaches?.categories.contains(where: { $0.path == "Library/Caches/pip" }) == true)
        #expect(languageToolchainCaches?.categories.contains(where: { $0.path == ".cargo/registry/cache" }) == true)
        #expect(languageToolchainCaches?.categories.contains(where: { $0.path == "Library/Caches/go-build" }) == true)
        #expect(jvmBuildToolCaches?.categories.contains(where: { $0.path == ".gradle/caches" }) == true)
        #expect(jvmBuildToolCaches?.categories.contains(where: { $0.path == ".m2/repository" }) == true)
    }
}
