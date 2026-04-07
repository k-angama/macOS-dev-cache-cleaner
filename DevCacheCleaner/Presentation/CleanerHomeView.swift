//
//  ContentView.swift
//  DevCacheCleaner
//
//  Created by Karim Angama on 05/03/2026.
//

import SwiftUI
import AppKit

struct CleanerHomeView: View {
    @State var viewModel: CleanerHomeViewModel
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
                        onOpenDetails: { category in
                            viewModel.selectCategoryForDetails(category)
                        },
                        onClean: { entity in
                            viewModel.askRemoveDirectory(entiy: entity)
                        },
                        onCleanAll: {
                            viewModel.askRemoveAllCaches()
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
                        viewModel.requesUserDirectoryAccess()
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
        .alert("Access Home Directory", isPresented: $viewModel.isAlertNotHomeDirectory, actions: {
            Button(role: .close) { }
        }, message: {
            Text("Please select the Home directory")
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
                    if AlertPresenter.showConfirmation(
                        title: "Clean Cache Files",
                        message: "Are you sure to proceed? This can't be undone."
                    ) {
                        startCleanupWindow()
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

    }
    
    func startCleanupWindow() {
        if let categoryName = viewModel.startCleanup() {
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
    viewModel.categories = categories
    viewModel.categoryRowStates = [
        categories[1].id: .loading,
        categories[3].id: .deleting
    ]
    return CleanerHomeView(
        viewModel: viewModel
    )
})
 
