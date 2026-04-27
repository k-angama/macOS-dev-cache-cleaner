//
//  LaunchAtStartupPromptRepository.swift
//  DevCacheCleaner
//
//  Created by Karim Angama on 27/04/2026.
//

import Foundation

protocol LaunchAtStartupPromptRepository {
    func isPromptDismissed() -> Bool
    func setPromptDismissed()
}
