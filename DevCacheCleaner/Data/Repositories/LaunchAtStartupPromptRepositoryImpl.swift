//
//  LaunchAtStartupPromptRepositoryImpl.swift
//  DevCacheCleaner
//
//  Created by Karim Angama on 27/04/2026.
//

import Foundation

struct LaunchAtStartupPromptRepositoryImpl: LaunchAtStartupPromptRepository {
    private let parameters: Parameters

    init(parameters: Parameters) {
        self.parameters = parameters
    }

    func isPromptDismissed() -> Bool {
        parameters.didDismissLaunchAtStartupPrompt
    }

    func setPromptDismissed() {
        var parameters = parameters
        parameters.didDismissLaunchAtStartupPrompt = true
    }
}
