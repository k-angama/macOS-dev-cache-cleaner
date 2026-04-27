//
//  ResolveLaunchAtStartupPromptDismissalUseCase.swift
//  DevCacheCleaner
//
//  Created by Karim Angama on 27/04/2026.
//

import Foundation

struct ResolveLaunchAtStartupPromptDismissalUseCase {

    private let launchAtStartupPromptRepository: LaunchAtStartupPromptRepository

    init(launchAtStartupPromptRepository: LaunchAtStartupPromptRepository) {
        self.launchAtStartupPromptRepository = launchAtStartupPromptRepository
    }

    func execute() -> Bool {
        launchAtStartupPromptRepository.isPromptDismissed()
    }
}
