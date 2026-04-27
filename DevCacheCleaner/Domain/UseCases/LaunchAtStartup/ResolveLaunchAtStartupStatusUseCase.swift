//
//  ResolveLaunchAtStartupStatusUseCase.swift
//  DevCacheCleaner
//
//  Created by Karim Angama on 27/04/2026.
//

import Foundation

struct ResolveLaunchAtStartupStatusUseCase {

    private let launchAtStartupRepository: LaunchAtStartupRepository

    init(launchAtStartupRepository: LaunchAtStartupRepository) {
        self.launchAtStartupRepository = launchAtStartupRepository
    }

    func execute() -> LaunchAtStartupStatusEntity {
        launchAtStartupRepository.resolveStatus()
    }
}
