//
//  WorkspaceSelectionView.swift
//  DevCacheCleaner
//
//  Created by Karim Angama on 21/04/2026.
//

import SwiftUI

struct WorkspaceSelectionView: View {
    let selectedWorkspaceName: String?
    let selectedWorkspacePath: String?
    let isSelectionEnabled: Bool
    let onSelectWorkspace: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Workspace", systemImage: "folder")
                    .font(.headline)

                Spacer()

                Button("Select Workspace", systemImage: "folder.badge.plus") {
                    onSelectWorkspace()
                }
                .disabled(isSelectionEnabled == false)
            }

            HStack(alignment: .center, spacing: 10) {
                Image(systemName: selectedWorkspaceName == nil ? "folder.badge.questionmark" : "folder.fill")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .frame(width: 24)

                VStack(alignment: .leading, spacing: 3) {
                    Text(selectedWorkspaceName ?? "No workspace selected")
                        .font(.subheadline)
                        .fontWeight(.medium)

                    if let selectedWorkspacePath {
                        Text(selectedWorkspacePath)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                            .truncationMode(.middle)
                            .textSelection(.enabled)
                    }
                }

                Spacer()
            }
            .padding(12)
            .background(Color.primary.opacity(0.035))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .padding([.horizontal, .vertical])
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(radius: 1)
    }
}

#Preview {
    VStack {
        WorkspaceSelectionView(
            selectedWorkspaceName: nil,
            selectedWorkspacePath: nil,
            isSelectionEnabled: true,
            onSelectWorkspace: {}
        )

        WorkspaceSelectionView(
            selectedWorkspaceName: "DevCacheCleaner",
            selectedWorkspacePath: "/Users/kangama/Documents/Projets/Desktop/MacOS/app/DevCacheCleaner",
            isSelectionEnabled: true,
            onSelectWorkspace: {}
        )
    }
    .padding()
}

