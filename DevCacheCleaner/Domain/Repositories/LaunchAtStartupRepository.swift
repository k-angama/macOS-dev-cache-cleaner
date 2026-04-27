//
//  LaunchAtStartupRepository.swift
//  DevCacheCleaner
//
//  Created by Karim Angama on 27/04/2026.
//

import Foundation

protocol LaunchAtStartupRepository {
    func resolveStatus() -> LaunchAtStartupStatusEntity
    func update(isEnabled: Bool) throws
}
