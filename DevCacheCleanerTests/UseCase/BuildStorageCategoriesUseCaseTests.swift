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
            $0.name == "IDE & Development Tool Caches"
        }
        let androidStudioCache = ideCategory?.categories.first {
            $0.path == "Library/Caches/Google"
        }
        let swiftPMCache = categories
            .first(where: { $0.name == "Package Manager Caches" })?
            .categories
            .first(where: { $0.path == "Library/Caches/org.swift.swiftpm" })

        #expect(categories.count == Constants.Storages.items.count)
        #expect(flutterCategory != nil)
        #expect(flutterCategory?.categories.contains(where: { $0.path == ".pub-cache" }) == true)
        #expect(androidStudioCache?.rule == .childNamePrefix("AndroidStudio"))
        #expect(swiftPMCache?.name == "SwiftPM")
    }
}
