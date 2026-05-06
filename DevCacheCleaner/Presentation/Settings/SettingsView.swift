//
//  SettingsView.swift
//  DevCacheCleaner
//
//  Created by Karim Angama on 27/04/2026.
//

import SwiftUI

struct SettingsView: View {
    @State var viewModel: SettingsViewModel
    @State private var isWorkspaceOpenPanelPresented = false

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            workspaceSection

            Divider()

            launchAtStartupSection

            Spacer()
        }
        .navigationTitle("Settings")
        .padding(24)
        .frame(width: 660, height: 320, alignment: .topLeading)
        .onChange(of: viewModel.isAlertErrorRequest) { _, newValue in
            if newValue {
                Task { @MainActor in
                    AlertPresenter.showError(
                        title: "Error",
                        message: viewModel.alertErrorMessage
                    )
                    viewModel.isAlertErrorRequest = false
                }
            }
        }
        .directoryOpenPanel(
            isPresented: $isWorkspaceOpenPanelPresented,
            title: "Select Workspace",
            message: "Choose a workspace folder",
            prompt: "Change Path",
            directoryURL: viewModel.workspaceDirectoryURL
        ) { url in
            viewModel.selectWorkspace(url: url)
        }
    }

    private var workspaceSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Workspace")
                .font(.headline)

            Text(
                viewModel.workspacePath == nil ?
                "Choose the workspace folder used for project cleanup." :
                "Replace the currently selected workspace folder."
            )
                .font(.subheadline)
                .foregroundStyle(.secondary)

            HStack(alignment: .center, spacing: 12) {
                Image(systemName: "folder.fill")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.top, 2)

                Text(viewModel.workspacePath ?? "No workspace selected")
                    .font(.subheadline)
                    .foregroundStyle(
                        viewModel.workspacePath == nil
                        ? .secondary
                        : .primary
                    )
                    .textSelection(.enabled)
                    .lineLimit(2)
                    .truncationMode(.middle)

                Spacer(minLength: 12)

                Button("Change Path", systemImage: "folder.badge.gearshape") {
                    isWorkspaceOpenPanelPresented = true
                }
            }
            .padding(14)
            .background(Color.primary.opacity(0.035))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
    }

    private var launchAtStartupSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Launch at Startup")
                .font(.headline)

            Text("Open DevCacheCleaner automatically at startup on this Mac.")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            HStack(alignment: .center, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Start automatically")
                        .font(.subheadline)

                    Text(viewModel.launchAtStartupStatusText)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer(minLength: 12)

                Toggle(
                    "",
                    isOn: Binding(
                        get: { viewModel.isLaunchAtStartupEnabled },
                        set: { viewModel.setLaunchAtStartupEnabled($0) }
                    )
                )
                .labelsHidden()
                .toggleStyle(.switch)
            }
            .padding(14)
            .background(Color.primary.opacity(0.035))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
    }
}

#Preview {
    let container = AppContainer()
    return container.settingsDI.start()
}
