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
    rule: StoragePathRule = .allContents,
    size: CGFloat = 0
) -> StorageSubCategoryEntity {
    StorageSubCategoryEntity(path: name, rule: rule, size: size)
}

func makeSubCategory(
    name: String? = nil,
    locations: [StorageLocationEntity]
) -> StorageSubCategoryEntity {
    StorageSubCategoryEntity(
        name: name,
        locations: locations,
        size: locations.reduce(0) { $0 + $1.size }
    )
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

func makeTemporaryWorkspaceURL() throws -> URL {
    let url = FileManager.default.temporaryDirectory
        .appending(path: UUID().uuidString, directoryHint: .isDirectory)
    try FileManager.default.createDirectory(
        at: url,
        withIntermediateDirectories: true
    )
    return url
}

func createDirectory(at url: URL) throws {
    try FileManager.default.createDirectory(
        at: url,
        withIntermediateDirectories: true
    )
}

func writeEmptyFile(at url: URL) throws {
    try FileManager.default.createDirectory(
        at: url.deletingLastPathComponent(),
        withIntermediateDirectories: true
    )
    try Data().write(to: url)
}
