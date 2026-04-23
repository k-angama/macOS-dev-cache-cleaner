//
//  CleanerHomeView.swift
//  DevCacheCleaner
//
//  Created by Karim Angama on 05/03/2026.
//

import SwiftUI
import AppKit

struct CleanerHomeView: View {
    @State var viewModel: CleanerHomeViewModel
    @State private var isWorkspaceOpenPanelPresented = false
    @State private var isHomeOpenPanelPresented = false
    @Environment(\.openWindow) var openWindow
    
    var body: some View {

        VStack(alignment: .leading, spacing: 18) {
            if viewModel.isAccessUserDirectory {
                VStack(alignment: .leading, spacing: 18) {
                    StorageUsageView(
                        total: viewModel.totalSize,
                        free: viewModel.freeSize,
                        categories: viewModel.categories,
                        rowStates: viewModel.categoryRowStates,
                        isCleaning: viewModel.isCleaning,
                        selectedWorkspaceName: viewModel.selectedWorkspaceName,
                        selectedWorkspacePath: viewModel.selectedWorkspacePath,
                        selectedWorkspaceCategory: viewModel.selectedWorkspaceCategory,
                        workspaceRowState: viewModel.workspaceRowState,
                        isWorkspaceSelectionEnabled: viewModel.isCleaning == false,
                        onOpenDetails: { category in
                            viewModel.selectCategoryForDetails(category)
                        },
                        onClean: { entity in
                            viewModel.askRemoveDirectory(entity: entity)
                        },
                        onCleanAll: {
                            viewModel.askRemoveAllCaches()
                        },
                        onSelectWorkspace: {
                            isWorkspaceOpenPanelPresented = true
                        },
                        onOpenWorkspaceDetails: {
                            viewModel.selectWorkspaceForDetails()
                        },
                        onCleanWorkspace: {
                            viewModel.askRemoveWorkspaceCaches()
                        }
                    )
                }
                .padding(.top)
            } else {
                VStack(alignment: .center, spacing: 10) {
                    Text("Access to the Home folder is required")
                        .font(.headline)
                    Text("DevCacheCleaner needs permission to access your Home folder and scan cache files.")
                        .font(.body)
                        .foregroundStyle(.secondary)
                    Button("Grant Access", systemImage: "square.on.square") {
                        isHomeOpenPanelPresented = true
                    }
                    .padding(.top)
                }
                .frame(maxWidth: .infinity)
                .padding(.top)
            }
            Divider()
            HStack {
                Spacer()
                Menu {
                    Button("About DevCacheCleaner") {
                        openWindow(
                            id: "about-dev-cache-cleaner",
                        )
                    }
                    Divider()
                    Button("Quit", systemImage: "close") {
                        NSApp.terminate(nil)
                    }.keyboardShortcut("q", modifiers: [.control])
                } label: {
                    Image(systemName: "gearshape")
                }
            }

        }
        .padding()
        .onAppear(perform: {
            viewModel.startMonitoring()
        })
        .onDisappear(perform: {
            viewModel.stopMonitoring()
        })
        .onChange(of: viewModel.isAlertErrorRequest, { _, newValue in
            if newValue {
                Task { @MainActor in
                    AlertPresenter.showError(
                        title: "Error", message: viewModel.alertErrorMessage
                    )
                    viewModel.isAlertCleanCache = false
                }
            }
        })
        .onChange(of: viewModel.isAlertCleanCache, { _, newValue in
            if newValue {
                Task { @MainActor in
                    let confirmation = AlertPresenter.showConfirmation(
                        title: "Clean Cache Files",
                        message: "Are you sure to proceed? This can't be undone.",
                        checkboxTitle: viewModel.cleanAllWorkspaceOptionTitle
                    )

                    if confirmation.didConfirm {
                        startCleanupWindow(
                            includeWorkspaceInAllCaches: confirmation.isCheckboxChecked
                        )
                    }
                    viewModel.isAlertCleanCache = false
                }
            }
        })
        .floatingPanel(
            of: $viewModel.selectedCategoryForDetails
        ) { category in
            StorageCategoryDetailsView(category: category)
        }
        .floatingPanel(
            of: $viewModel.selectedWorkspaceCategoryForDetails
        ) { category in
            StorageCategoryDetailsView(category: category)
        }
        .directoryOpenPanel(
            isPresented: $isWorkspaceOpenPanelPresented,
            title: "Select Workspace",
            message: "Choose a workspace folder",
            prompt: "Select Workspace"
        ) { url in
            viewModel.selectWorkspace(url: url)
        }
        .directoryOpenPanel(
            isPresented: $isHomeOpenPanelPresented,
            title: "Home",
            message: "Select your Home folder",
            prompt: "Grant Access",
        ) { url in
            viewModel.selectHomeSpace(url: url)
        }

    }
    
    func startCleanupWindow(includeWorkspaceInAllCaches: Bool = false) {
        if let categoryName = viewModel.startCleanup(
            includeWorkspaceInAllCaches: includeWorkspaceInAllCaches
        ) {
            openWindow(
                id: Constants.WindowIds.cleanupProgress,
                value: categoryName
            )
        }
    }
}

#Preview {
    let container = AppContainer()
    let viewModel = container.cleanerHomeViewModel
    viewModel.isAccessUserDirectory = false
    return CleanerHomeView(
        viewModel: viewModel
    )
}

#Preview("AccessUserDirectory", body: {
    let container = AppContainer()
    let viewModel = container.cleanerHomeViewModel
    let categories: [StorageCategoryEntity] = [
        .init(name: "Android/Gradle Caches", color: .red, size: 0, categories: []),
        .init(name: "Xcode Caches & DerivedData", color: .orange, size: 100, categories: []),
        .init(name: "Flutter Cache", color: .yellow, size: 35, categories: []),
        .init(name: "Homebrew Cache", color: .green, size: 7, categories: []),
        .init(name: "npm/Yarn/pnpm Cache", color: .cyan, size: 5, categories: []),
        .init(name: "CocoaPods Cache", color: .brown, size: 10.8, categories: []),
        .init(name: "IDE (JetBrains, VSCode) Cache", color: .blue, size: 20.8, categories: []),
        .init(name: "Browser Cache", color: .gray.opacity(0.7), size: 5.8, categories: [])
    ]
    viewModel.isAccessUserDirectory = true
    viewModel.isAlertCleanCache = false
    viewModel.totalSize = 500
    viewModel.freeSize = 70
    viewModel.selectWorkspace(url: URL(filePath: "/Users/kangama/Documents/Projets/Desktop/MacOS/app/DevCacheCleaner"))
    viewModel.categories = categories
    viewModel.categoryRowStates = [
        categories[1].id: .loading,
        categories[3].id: .deleting
    ]
    return CleanerHomeView(
        viewModel: viewModel
    )
})
 
