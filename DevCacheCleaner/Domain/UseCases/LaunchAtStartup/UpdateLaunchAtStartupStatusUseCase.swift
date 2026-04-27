//
//  UpdateLaunchAtStartupStatusUseCase.swift
//  DevCacheCleaner
//
//  Created by Karim Angama on 27/04/2026.
//

import Foundation

struct UpdateLaunchAtStartupStatusUseCase {

    private let launchAtStartupRepository: LaunchAtStartupRepository

    init(launchAtStartupRepository: LaunchAtStartupRepository) {
        self.launchAtStartupRepository = launchAtStartupRepository
    }

    func execute(isEnabled: Bool) throws {
        try launchAtStartupRepository.update(isEnabled: isEnabled)
    }
}
