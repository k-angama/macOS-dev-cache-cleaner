//
//  DiskManager.swift
//  DevCacheCleaner
//
//  Created by Karim Angama on 06/03/2026.
//

import Foundation
import AppKit

protocol DiskManager {
    var totalDiskCapacity: CGFloat { get }
    var availableDiskCapacity: CGFloat { get }
    func cleanPath(
        path: String,
        rule: StoragePathRule,
        homeURL: URL,
        expectedDeletedSize: CGFloat,
        onFileDeleted: ((CGFloat) -> Void)?
    ) async throws
    func computeDiskSize(homeURL: URL, path: String, rule: StoragePathRule) async -> CGFloat
}

enum DiskManagerError: Error {
    case directoryDoesNotExist
}

class DiskManagerImpl: DiskManager {

    // MARK: - Public properties
    
    var totalDiskCapacity: CGFloat {
        let url = URL(filePath: "/")
        let results = try? url.resourceValues(forKeys: [.volumeTotalCapacityKey])
        return (results?.volumeTotalCapacity ?? 0).toCGFloat
    }
    
    var availableDiskCapacity: CGFloat {
        let url = URL(filePath: "/")
        let results = try? url.resourceValues(forKeys: [.volumeAvailableCapacityKey])
        return (results?.volumeAvailableCapacity ?? 0).toCGFloat
    }
    
    // MARK: - Public Methode

    func getDiskSize(path: String, homeURL: URL) -> CGFloat {
        var bytes: Int64 = 0
        homeURL.withSecurityScope {
            let cachesURL = homeURL
                .appending(path: path, directoryHint: .isDirectory)
            if FileManager.default.fileExists(atPath: cachesURL.path) {
                bytes = directorySize(at: cachesURL)
            } else {
                bytes = 0
            }
        }
        return bytes.toCGFloat
    }
    
    // MARK: - Private Methode

    private func directorySize(at url: URL) -> Int64 {
        var total: Int64 = 0
        if let enumerator = FileManager.default.enumerator(
            at: url,
            includingPropertiesForKeys: [.isRegularFileKey, .totalFileAllocatedSizeKey, .fileAllocatedSizeKey],
            //options: [.skipsHiddenFiles]
        ) {
            for case let fileURL as URL in enumerator {
                do {
                    let values = try fileURL.resourceValues(
                        forKeys: [.isRegularFileKey, .totalFileAllocatedSizeKey, .fileAllocatedSizeKey]
                    )
                    if values.isRegularFile == true {
                        if let size = values.totalFileAllocatedSize ?? values.fileAllocatedSize {
                            total += Int64(size)
                        }
                    }
                } catch {
                    // ignore unreadable files
                }
            }
        }
        return total
    }

    private func deleteContents(
        of url: URL,
        fileManager: FileManager,
        expectedDeletedSize: CGFloat,
        onFileDeleted: ((CGFloat) -> Void)?
    ) throws {
        let values = try url.resourceValues(forKeys: [.isDirectoryKey, .isSymbolicLinkKey])

        guard values.isDirectory == true, values.isSymbolicLink != true else {
            try fileManager.removeItem(at: url)
            if expectedDeletedSize > 0 {
                onFileDeleted?(expectedDeletedSize)
            }
            return
        }

        let items = try fileManager.contentsOfDirectory(
            at: url,
            includingPropertiesForKeys: nil,
            options: []
        )

        for itemURL in items {
            try fileManager.removeItem(at: itemURL)
        }

        if expectedDeletedSize > 0 {
            onFileDeleted?(expectedDeletedSize)
        }
    }

    private func deleteMatchingChildren(
        of url: URL,
        prefix: String,
        fileManager: FileManager,
        expectedDeletedSize: CGFloat,
        onFileDeleted: ((CGFloat) -> Void)?
    ) throws {
        let items = try fileManager.contentsOfDirectory(
            at: url,
            includingPropertiesForKeys: nil,
            options: [.skipsHiddenFiles]
        )
        var didDeleteItem = false

        for itemURL in items where itemURL.lastPathComponent.hasPrefix(prefix) {
            try fileManager.removeItem(at: itemURL)
            didDeleteItem = true
        }

        if didDeleteItem, expectedDeletedSize > 0 {
            onFileDeleted?(expectedDeletedSize)
        }
    }
    
}

extension DiskManagerImpl {

    // MARK: - Async API
    
    func cleanPath(
        path: String,
        rule: StoragePathRule,
        homeURL: URL,
        expectedDeletedSize: CGFloat,
        onFileDeleted: ((CGFloat) -> Void)?
    ) async throws {
        
        return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            DispatchQueue.global(qos: .utility).async { [weak self] in
                guard let self else {
                    continuation.resume()
                    return
                }

                do {
                    try homeURL.withSecurityScope  {
                        let targetURL = homeURL.appending(path: path, directoryHint: .isDirectory)
                        let fm = FileManager.default

                        guard fm.fileExists(atPath: targetURL.path) else {
                            throw DiskManagerError.directoryDoesNotExist
                        }

                        switch rule {
                        case .allContents:
                            try self.deleteContents(
                                of: targetURL,
                                fileManager: fm,
                                expectedDeletedSize: expectedDeletedSize,
                                onFileDeleted: onFileDeleted
                            )
                        case .childNamePrefix(let prefix):
                            try self.deleteMatchingChildren(
                                of: targetURL,
                                prefix: prefix,
                                fileManager: fm,
                                expectedDeletedSize: expectedDeletedSize,
                                onFileDeleted: onFileDeleted
                            )
                        }
                    }

                    continuation.resume()
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    func computeDiskSize(homeURL: URL, path: String, rule: StoragePathRule) async -> CGFloat {
        
        return await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .utility).async { [weak self] in
                guard let self else {
                    continuation.resume(returning: 0)
                    return
                }
                
                switch rule {
                case .allContents:
                    let size = self.getDiskSize(path: path, homeURL: homeURL)
                    continuation.resume(returning: size)
                    return
                case .childNamePrefix(let prefix):
                    var localTotal: CGFloat = 0
                    let fm = FileManager.default
                    homeURL.withSecurityScope {
                        let base = homeURL.appending(path: path, directoryHint: .isDirectory)
                        guard let items = try? fm.contentsOfDirectory(at: base, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles]) else {
                            continuation.resume(returning: 0)
                            return
                        }
                        for url in items where url.lastPathComponent.hasPrefix(prefix) {
                            localTotal += self.getDiskSize(path: "\(path)/\(url.lastPathComponent)", homeURL: homeURL)
                        }
                        continuation.resume(returning: localTotal)
                    }
                }
            }
        }
    }
    
}
