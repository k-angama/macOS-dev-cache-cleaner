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
    var isLaunchAtStartupEnabled: Bool = false
    var launchAtStartupStatusText: String = ""

    private let settingsStore: SettingsStore
    private let saveWorkspaceAccessUseCase: SaveWorkspaceAccessUseCase
    private let resolveWorkspaceAccessUseCase: ResolveWorkspaceAccessUseCase
    private let resolveLaunchAtStartupStatusUseCase: ResolveLaunchAtStartupStatusUseCase
    private let updateLaunchAtStartupStatusUseCase: UpdateLaunchAtStartupStatusUseCase

    init(
        saveWorkspaceAccessUseCase: SaveWorkspaceAccessUseCase,
        resolveWorkspaceAccessUseCase: ResolveWorkspaceAccessUseCase,
        resolveLaunchAtStartupStatusUseCase: ResolveLaunchAtStartupStatusUseCase,
        updateLaunchAtStartupStatusUseCase: UpdateLaunchAtStartupStatusUseCase,
        settingsStore: SettingsStore
    ) {
        self.settingsStore = settingsStore
        self.saveWorkspaceAccessUseCase = saveWorkspaceAccessUseCase
        self.resolveWorkspaceAccessUseCase = resolveWorkspaceAccessUseCase
        self.resolveLaunchAtStartupStatusUseCase = resolveLaunchAtStartupStatusUseCase
        self.updateLaunchAtStartupStatusUseCase = updateLaunchAtStartupStatusUseCase
        setup()
    }
    
    func setup() {
        let workspaceURL = settingsStore.selectedWorkspaceURL
            ?? resolveWorkspaceAccessUseCase.execute()
        workspaceDirectoryURL = workspaceURL
        workspacePath = workspaceURL?.path
        settingsStore.selectedWorkspaceURL = workspaceURL
        refreshLaunchAtStartupState()
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

    func setLaunchAtStartupEnabled(_ isEnabled: Bool) {
        do {
            try updateLaunchAtStartupStatusUseCase.execute(isEnabled: isEnabled)

            let status = refreshLaunchAtStartupState()

            if status == .requiresApproval {
                alertErrorMessage = "Approval is required in System Settings > Login Items."
                isAlertErrorRequest = true
            }
        } catch {
            refreshLaunchAtStartupState()
            alertErrorMessage = error.localizedDescription
            isAlertErrorRequest = true
        }
    }

    @discardableResult
    private func refreshLaunchAtStartupState() -> LaunchAtStartupStatusEntity {
        let status = resolveLaunchAtStartupStatusUseCase.execute()

        switch status {
        case .enabled:
            isLaunchAtStartupEnabled = true
            launchAtStartupStatusText = "DevCacheCleaner will open automatically at startup."
        case .requiresApproval:
            isLaunchAtStartupEnabled = true
            launchAtStartupStatusText = "Approval is required in System Settings > Login Items."
        case .disabled:
            isLaunchAtStartupEnabled = false
            launchAtStartupStatusText = "DevCacheCleaner won't open automatically at startup."
        case .unavailable:
            isLaunchAtStartupEnabled = false
            launchAtStartupStatusText = "Unable to determine the current startup setting."
        }

        return status
    }
}
