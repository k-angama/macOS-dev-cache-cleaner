//
//  SettingsViewModel.swift
//  DevCacheCleaner
//
//  Created by Karim Angama on 27/04/2026.
//

import Foundation

@Observable
class SettingsViewModel {
    var isAlertErrorRequest: Bool = false
    var alertErrorMessage: String = "Unable to save workspace access."
    var workspacePath: String?
    var workspaceDirectoryURL: URL?

    private let settingsStore: SettingsStore
    private let saveWorkspaceAccessUseCase: SaveWorkspaceAccessUseCase

    init(
        saveWorkspaceAccessUseCase: SaveWorkspaceAccessUseCase,
        settingsStore: SettingsStore
    ) {
        self.settingsStore = settingsStore
        self.saveWorkspaceAccessUseCase = saveWorkspaceAccessUseCase
        setup()
    }
    
    func setup() {
        workspaceDirectoryURL = settingsStore.selectedWorkspaceURL
        workspacePath = settingsStore.selectedWorkspaceURL?.path
    }

    func selectWorkspace(url: URL?) {
        guard let url else { return }

        guard saveWorkspaceAccessUseCase.execute(url: url) else {
            alertErrorMessage = "Unable to save workspace access."
            isAlertErrorRequest = true
            return
        }

        workspaceDirectoryURL = url
        workspacePath = url.path
        settingsStore.selectedWorkspaceURL = url
    }
}
