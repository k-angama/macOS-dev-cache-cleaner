//
//  LaunchAtStartupRepositoryImpl.swift
//  DevCacheCleaner
//
//  Created by Karim Angama on 27/04/2026.
//

import Foundation

struct LaunchAtStartupRepositoryImpl: LaunchAtStartupRepository {
    private let manager: LaunchAtStartupManaging

    init(manager: LaunchAtStartupManaging) {
        self.manager = manager
    }

    func resolveStatus() -> LaunchAtStartupStatusEntity {
        manager.resolveStatus()
    }

    func update(isEnabled: Bool) throws {
        try manager.update(isEnabled: isEnabled)
    }
}
