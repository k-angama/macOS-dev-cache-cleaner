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
    
    var body: some View {
        Group {
            if viewModel.isFinished {
                VStack(spacing: 10) {
                    Text("✅")
                        .font(.title)

                    Text("Cleanup complete")
                        .font(.title3)
                        .bold()

                    Text("Deleted \(viewModel.realDeletedSizeText) of cache files.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.bottom)
                .frame(maxWidth: .infinity)
            } else {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Cleaning cache files...")
                        .font(.title3)
                        .bold()

                    Text(viewModel.categoryName)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Text(viewModel.currentDirectoryPath ?? "Preparing cleanup...")
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
            }
        }
        .padding()
        .padding(.top, 0)
        .onChange(of: viewModel.shouldDismiss, { _, newValue in
            if newValue {
                dismissWindow()
            }
        })
        .onChange(of: viewModel.realDeletedSize, { _, _ in
            viewModel.syncDisplayedProgress()
        })
        .onChange(of: viewModel.realTotalSize, { _, _ in
            viewModel.syncDisplayedProgress()
        })
    }

}

#Preview {
    let container = AppContainer()
    container.cleanupProgressDI.start(data: StorageCategoryEntity.preview.name)
}
