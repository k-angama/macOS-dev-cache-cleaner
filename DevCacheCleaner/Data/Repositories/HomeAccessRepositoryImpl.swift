//
//  HomeAccessRepositoryImpl.swift
//  DevCacheCleaner
//
//  Created by Karim Angama on 14/03/2026.
//

import Foundation

struct HomeAccessRepositoryImpl: HomeAccessRepository {
    private let manager: HomeAccessManager

    init(manager: HomeAccessManager) {
        self.manager = manager
    }

    func requestAndSaveHomeAccess() -> URL? {
        manager.requestAndSaveHomeAccess()
    }

    func resolveHomeURL() -> URL? {
        manager.resolveHomeURL()
    }
}
