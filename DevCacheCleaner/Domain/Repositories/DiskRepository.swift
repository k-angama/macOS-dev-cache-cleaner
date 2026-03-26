//
//  DiskRepository.swift
//  DevCacheCleaner
//
//  Created by Karim Angama on 14/03/2026.
//

import Foundation

public protocol DiskRepository {
    var totalDiskCapacity: CGFloat { get }
    var availableDiskCapacity: CGFloat { get }
    func computeDiskSize(homeURL: URL, path: String, match: String) async -> CGFloat
    func cleanPath(
        homeURL: URL,
        path: String,
        match: String,
        onFileDeleted: ((CGFloat) -> Void)?
    ) async throws
}
