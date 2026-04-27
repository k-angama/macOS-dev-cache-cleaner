//
//  DismissLaunchAtStartupPromptUseCase.swift
//  DevCacheCleaner
//
//  Created by Karim Angama on 27/04/2026.
//

import Foundation

struct DismissLaunchAtStartupPromptUseCase {

    private let launchAtStartupPromptRepository: LaunchAtStartupPromptRepository

    init(launchAtStartupPromptRepository: LaunchAtStartupPromptRepository) {
        self.launchAtStartupPromptRepository = launchAtStartupPromptRepository
    }

    func execute() {
        launchAtStartupPromptRepository.setPromptDismissed()
    }
}
