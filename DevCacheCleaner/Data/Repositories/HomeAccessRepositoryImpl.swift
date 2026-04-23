//
//  HomeAccessRepositoryImpl.swift
//  DevCacheCleaner
//
//  Created by Karim Angama on 14/03/2026.
//

import Foundation

struct HomeAccessRepositoryImpl: HomeAccessRepository {
    private let manager: DirectoryAccessManaging

    init(manager: DirectoryAccessManaging) {
        self.manager = manager
    }

    func saveHomeURL(_ url: URL) -> Bool {
        manager.saveAccess(for: url, kind: .home)
    }

    func resolveHomeURL() -> URL? {
        manager.resolveURL(for: .home)
    }
}
