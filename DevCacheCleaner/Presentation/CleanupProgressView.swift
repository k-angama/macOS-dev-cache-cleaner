//
//  CleanupProgressView.swift
//  DevCacheCleaner
//
//  Created by Karim Angama on 11/03/2026.
//

import SwiftUI

struct CleanupProgressView: View {
    
    @State var viewModel: CleanupProgressViewModel
    @Environment(\.dismissWindow) private var dismissWindow
    
    init(viewModel: CleanupProgressViewModel, selectedCategoryName: String) {
        self.viewModel = viewModel
        self.viewModel.setCategoryName(selectedCategoryName)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Cleaning cache files...")
                .font(.title3)
                .bold()

            Text(viewModel.categoryName)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Text(
                viewModel.isFinished
                ? "Finished!"
                : (viewModel.currentDirectoryPath ?? "Preparing cleanup...")
            )
            .font(.subheadline)
            .foregroundStyle(.secondary)

            HStack {
                Text("\(viewModel.deletedSizeText) of \(viewModel.totalSizeText) deleted")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                Spacer()
                Text("\(viewModel.progressPercentage)%")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            ProgressView(value: viewModel.progress, total: 1)
                .progressViewStyle(.linear)
        }
        .padding()
        .padding(.top, 0)
        .onChange(of: viewModel.shouldDismiss, { _, newValue in
            if newValue {
                dismissWindow()
            }
        })
    }

}

#Preview {
    let container = AppContainer()
    return CleanupProgressView(
        viewModel: container.cleanupProgressViewModel,
        selectedCategoryName: StorageCategoryEntity.preview.name
    )
}
