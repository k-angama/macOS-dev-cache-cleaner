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
    let workspaceSizeText: String
    let isCleanEnabled: Bool
    let isSelectionEnabled: Bool
    let state: StorageCategoryRowState
    let onSelectWorkspace: () -> Void
    let onOpenDetails: (() -> Void)?
    let onClean: (() -> Void)?
    @State private var isHovered = false
    @State private var isInfoPresented = false

    private var hasSelectedWorkspace: Bool {
        selectedWorkspaceName != nil
    }

    private var isDetailsEnabled: Bool {
        hasSelectedWorkspace && state == .ready && onOpenDetails != nil
    }

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            workspaceButton
            workspaceInfoButton

            Spacer(minLength: 12)

            if hasSelectedWorkspace {
                workspaceStateView

                Button {
                    onClean?()
                } label: {
                    Label("Clean Workspace", systemImage: "trash")
                }
                .disabled(isCleanEnabled == false)
                .help("Clean caches in the selected workspace")
            } else {
                Button("Select Workspace", systemImage: "folder.badge.plus") {
                    onSelectWorkspace()
                }
                .disabled(isSelectionEnabled == false)
            }
        }
    }

    private var workspaceStateView: some View {
        Group {
            switch state {
            case .ready:
                Text(workspaceSizeText)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            case .loading:
                HStack(spacing: 3) {
                    Text("Scanning...")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    ProgressView()
                        .scaleEffect(0.4)
                }
            case .deleting:
                HStack(spacing: 3) {
                    Text("Deleting...")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    ProgressView()
                        .scaleEffect(0.4)
                }
            }
        }
        .frame(minWidth: 82, alignment: .trailing)
    }

    private var workspaceInfoButton: some View {
        Button {
            isInfoPresented.toggle()
        } label: {
            Image(systemName: "info.circle")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .frame(width: 24, height: 24)
        }
        .buttonStyle(.plain)
        .help("What is workspace cleanup?")
        .popover(isPresented: $isInfoPresented, arrowEdge: .bottom) {
            workspaceInfoPopover
        }
    }

    private var workspaceInfoPopover: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Workspace cleanup")
                .font(.headline)

            Text("Workspace cleanup looks inside the selected project folder for generated dependency directories.")

            Text("Examples include node_modules for JavaScript projects and Pods for CocoaPods projects.")

            Text("Only generated folders are intended to be cleaned. Your source files, project files, and configuration files stay outside this cleanup.")
        }
        .font(.subheadline)
        .foregroundStyle(.primary)
        .frame(width: 300, alignment: .leading)
        .padding(14)
    }

    private var workspaceButton: some View {
        Button {
            if hasSelectedWorkspace {
                onOpenDetails?()
            } else {
                onSelectWorkspace()
            }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: hasSelectedWorkspace ? "folder.fill" : "folder.badge.questionmark")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(width: 14)

                VStack(alignment: .leading, spacing: 2) {
                    Text(selectedWorkspaceName ?? "Workspace")
                        .font(.subheadline)

                    Text(selectedWorkspacePath ?? "No workspace selected")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .truncationMode(.middle)
                        .textSelection(.enabled)
                }

                Image(systemName: "chevron.right")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .opacity(hasSelectedWorkspace && isHovered ? 1 : 0.35)
            }
            .padding(.vertical, 6)
            .padding(.horizontal, 8)
            .background(
                isHovered
                ? Color.teal.opacity(0.12)
                : Color.clear
            )
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(hasSelectedWorkspace && isDetailsEnabled == false)
        .help(
            hasSelectedWorkspace
            ? (isDetailsEnabled ? "Show workspace cleanable directories" : "Details are available after scanning")
            : "Select a workspace"
        )
        .onHover { isHovering in
            isHovered = isHovering && (hasSelectedWorkspace == false || isDetailsEnabled)
        }
    }
}

#Preview {
    VStack(spacing: 18) {
        WorkspaceSelectionView(
            selectedWorkspaceName: nil,
            selectedWorkspacePath: nil,
            workspaceSizeText: "Size pending",
            isCleanEnabled: false,
            isSelectionEnabled: true,
            state: .ready,
            onSelectWorkspace: {},
            onOpenDetails: nil,
            onClean: nil
        )

        WorkspaceSelectionView(
            selectedWorkspaceName: "DevCacheCleaner",
            selectedWorkspacePath: "/Users/kangama/Documents/Projets/Desktop/MacOS/app/DevCacheCleaner",
            workspaceSizeText: "Size pending",
            isCleanEnabled: false,
            isSelectionEnabled: true,
            state: .loading,
            onSelectWorkspace: {},
            onOpenDetails: {},
            onClean: {}
        )
    }
    .padding()
}
