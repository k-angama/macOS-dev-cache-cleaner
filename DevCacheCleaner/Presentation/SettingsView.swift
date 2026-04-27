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

                VStack(alignment: .leading, spacing: 8) {

                    HStack(alignment: .top, spacing: 12) {
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

            Spacer()
        }
        .navigationTitle("Settings")
        .padding(24)
        .frame(width: 660, height: 220, alignment: .topLeading)
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
}

#Preview {
    let container = AppContainer()
    return SettingsView(
        viewModel: container.settingsViewModel,
    )
}
