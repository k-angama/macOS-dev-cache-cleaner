//
//  StorageUsageView.swift
//  DevCacheCleaner
//
//  Created by Karim Angama on 05/03/2026.
//

import SwiftUI

enum StorageCategoryRowState: Hashable {
    case loading
    case ready
    case deleting
}

struct StorageUsageView: View {
    
    let total: CGFloat
    let free: CGFloat
    let categories: [StorageCategoryEntity]
    let rowStates: [UUID: StorageCategoryRowState]
    let isCleaning: Bool
    var onClean: ((StorageCategoryEntity) -> Void)? = nil
    var onCleanAll: (() -> Void)? = nil

    var totalCategoriesSize: CGFloat {
        categories.sum({ $0.size })
    }

    var systeme: CGFloat {
        (total - totalCategoriesSize) - free
    }
    
    var usedSpace: CGFloat {
        systeme + categories.map(\.size).reduce(0, +)
    }

    func rowState(for category: StorageCategoryEntity) -> StorageCategoryRowState {
        rowStates[category.id] ?? .ready
    }

    var rowActionTransition: AnyTransition {
        .asymmetric(
            insertion: .opacity.combined(with: .scale(scale: 0.92)),
            removal: .opacity.combined(with: .scale(scale: 0.98))
        )
    }
    

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            VStack {
                HStack {
                    Text("Macintosh HD").font(.headline)
                    Spacer()
                    Text("\(usedSpace.byteCountString) used of \(total.byteCountString)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                ZStack(alignment: .leading) {
                    GeometryReader { geo in
                        HStack(spacing: 0) {
                            Rectangle()
                                .fill(.gray.opacity(0.8))
                                .frame(width: geo.size.width * (systeme / total), height: 24)
                            ForEach(categories) { cat in
                                Rectangle()
                                    .fill(cat.color)
                                    .frame(width: geo.size.width * (cat.size / total), height: 24)
                            }
                            Rectangle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(width: geo.size.width * (free / total), height: 24)
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    .frame(height: 24)
                }
                HStack {
                    HStack {
                        Text("System")
                            .font(.footnote)
                            .foregroundStyle(.primary)
                        Circle().fill(.gray.opacity(0.8)).frame(width: 10, height: 10)
                        Text(systeme.byteCountString)
                            .font(.footnote)
                            .foregroundStyle(.primary)
                    }
                    Spacer()
                    HStack {
                        Text(free.byteCountString)
                            .font(.footnote)
                            .foregroundStyle(.primary)
                        Text("Free")
                            .font(.footnote)
                            .foregroundStyle(.primary)
                        Circle().fill(.gray.opacity(0.2)).frame(width: 10, height: 10)
                    }

                }
                .padding(.vertical, 2)
                .padding(.bottom, 8)
            }
            .padding([.horizontal, .top])
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .shadow(radius: 1)
            
            // Legend row
            VStack(alignment: .center, spacing: 18) {
                ForEach(categories) { cat in
                    let state = rowState(for: cat)
                    HStack {
                        Label {
                            Text(cat.name)
                        } icon: {
                            Circle().fill(cat.color).frame(width: 10, height: 10)
                        }
                        Spacer()
                        Text(cat.size.byteCountString)
                            .font(.footnote)
                            .foregroundStyle(.primary)
                            .padding(.horizontal, 4)
                        ZStack(alignment: .trailing) {
                            switch state {
                            case .ready:
                                Button {
                                    onClean?(cat)
                                } label: {
                                    Label("Clean Caches", systemImage: "trash")
                                }
                                .buttonStyle(.automatic)
                                .help("Clean caches in \(cat.name)")
                                .disabled(isCleaning || cat.size <= 0.01)
                                .transition(rowActionTransition)
                            case .loading:
                                ProgressView()
                                    .scaleEffect(0.4)
                                    .transition(rowActionTransition)
                            case .deleting:
                                HStack(spacing: 3) {
                                    Text("Deleting caches…")
                                        .font(.footnote)
                                        .foregroundStyle(.secondary)
                                    ProgressView()
                                        .scaleEffect(0.4)
                                }
                                .transition(rowActionTransition)
                            }
                        }
                        .frame(minWidth: 120, alignment: .trailing)
                        .animation(.easeInOut(duration: 0.2), value: state)
                    }
                }
            }
            Divider()
            HStack {
                Text("Clean All Caches")
                Spacer()
                Text("\(totalCategoriesSize.byteCountString) to clean")
                    .font(.footnote)
                    .foregroundStyle(.primary)
                    .padding(.horizontal, 4)
                Button {
                    onCleanAll?()
                } label: {
                    Label("Clean All Caches", systemImage: "trash.fill")
                }
                .buttonStyle(.borderedProminent)
                .tint(.red)
                .help("Clean all caches")
                .disabled(isCleaning || totalCategoriesSize <= 0.01)
            }
        }
    }
}

#Preview {
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
    StorageUsageView(
        total: 499.96,
        free: 72,
        categories: categories,
        rowStates: [
            categories[1].id: .loading,
            categories[6].id: .deleting
        ],
        isCleaning: false,
        onClean: { cat in
            print("Clean tapped for: \(cat.name)")
        },
        onCleanAll: {
            print("Clean All tapped")
        }
    )
    .padding()
}
