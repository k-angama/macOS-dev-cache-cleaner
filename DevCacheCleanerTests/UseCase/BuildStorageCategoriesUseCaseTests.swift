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

        #expect(categories.count == Constants.Storages.items.count)
        #expect(flutterCategory != nil)
        #expect(flutterCategory?.categories.contains(where: { $0.path == ".pub-cache" }) == true)
    }
}
