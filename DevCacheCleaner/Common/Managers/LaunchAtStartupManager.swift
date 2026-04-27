//
//  LaunchAtStartupManager.swift
//  DevCacheCleaner
//
//  Created by Karim Angama on 27/04/2026.
//

import Foundation
import ServiceManagement

protocol LaunchAtStartupManaging {
    func resolveStatus() -> LaunchAtStartupStatusEntity
    func update(isEnabled: Bool) throws
}

final class LaunchAtStartupManager: LaunchAtStartupManaging {

    func resolveStatus() -> LaunchAtStartupStatusEntity {
        switch SMAppService.mainApp.status {
        case .enabled:
            .enabled
        case .requiresApproval:
            .requiresApproval
        case .notRegistered:
            .disabled
        case .notFound:
            .unavailable
        @unknown default:
            .unavailable
        }
    }

    func update(isEnabled: Bool) throws {
        if isEnabled {
            try SMAppService.mainApp.register()
        } else {
            try SMAppService.mainApp.unregister()
        }
    }
}
