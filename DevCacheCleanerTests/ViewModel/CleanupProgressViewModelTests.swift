import Foundation
import Testing
@testable import DevCacheCleaner

@MainActor
struct CleanupProgressViewModelTests {

    @Test func computedProperties_reflectStoreState() {
        let store = CleanupProgressStore()
        let viewModel = CleanupProgressViewModel(store: store)
        let currentDirectory = StorageSubCategoryEntity(
            path: "/Users/kangama/.pub-cache",
            match: "",
            size: 512
        )

        store.start(categoryName: "Flutter", totalSize: 2_048)
        store.update(
            currentDirectory: currentDirectory,
            deletedSize: 1_536,
            totalSize: 2_048
        )

        #expect(viewModel.categoryName == "Flutter")
        #expect(viewModel.currentDirectoryPath == "/Users/kangama/.pub-cache")
        #expect(viewModel.progress == 0.75)
        #expect(viewModel.progressPercentage == 75)
        #expect(viewModel.deletedSizeText == CGFloat(1_536).byteCountString)
        #expect(viewModel.totalSizeText == CGFloat(2_048).byteCountString)
        #expect(viewModel.isFinished == false)
        #expect(viewModel.shouldDismiss == false)
    }

    @Test func progressPercentage_roundsStoreProgress() {
        let store = CleanupProgressStore()
        let viewModel = CleanupProgressViewModel(store: store)

        store.start(categoryName: "Xcode", totalSize: 3)
        store.update(currentDirectory: nil, deletedSize: 2, totalSize: 3)

        #expect(viewModel.progressPercentage == 67)
    }

    @Test func setCategoryName_updatesStoreCategoryName() {
        let store = CleanupProgressStore()
        let viewModel = CleanupProgressViewModel(store: store)

        viewModel.setCategoryName("Flutter")

        #expect(store.categoryName == "Flutter")
    }

    @Test func finish_updatesFinishedStateAndDismissFlag() async {
        let store = CleanupProgressStore()
        let viewModel = CleanupProgressViewModel(store: store)

        store.start(categoryName: "All Caches", totalSize: 4_096)
        store.update(
            currentDirectory: StorageSubCategoryEntity(
                path: "/Users/kangama/Library/Caches",
                match: "",
                size: 2_048
            ),
            deletedSize: 2_048,
            totalSize: 4_096
        )

        await store.finish(isComplete: true)

        #expect(viewModel.isFinished)
        #expect(viewModel.shouldDismiss)
        #expect(viewModel.progress == 1)
        #expect(viewModel.progressPercentage == 100)
        #expect(viewModel.deletedSizeText == CGFloat(4_096).byteCountString)
        #expect(viewModel.currentDirectoryPath == nil)
    }
}
