import Foundation
import SwiftUI
import Testing
@testable import DevCacheCleaner

let testHomeURL = URL(filePath: "/Users/test")

@MainActor
func makeCategory(
    name: String,
    color: Color = .red,
    subcategories: [StorageSubCategoryEntity]
) -> StorageCategoryEntity {
    StorageCategoryEntity(
        name: name,
        color: color,
        size: subcategories.reduce(0) { $0 + $1.size },
        categories: subcategories
    )
}

func makeSubCategory(
    name: String,
    match: String = "",
    size: CGFloat = 0
) -> StorageSubCategoryEntity {
    StorageSubCategoryEntity(path: name, match: match, size: size)
}

func collectEvents(
    from stream: AsyncStream<CleanStorageCategoryEventEntity>
) async -> [CleanStorageCategoryEventEntity] {
    var events: [CleanStorageCategoryEventEntity] = []

    for await event in stream {
        events.append(event)
    }

    return events
}

@MainActor
func waitUntil(
    timeout: TimeInterval = 1,
    pollIntervalNanoseconds: UInt64 = 10_000_000,
    _ condition: @escaping @MainActor () -> Bool
) async -> Bool {
    let deadline = Date().addingTimeInterval(timeout)

    while Date() < deadline {
        if condition() {
            return true
        }

        try? await Task.sleep(nanoseconds: pollIntervalNanoseconds)
    }

    return condition()
}
