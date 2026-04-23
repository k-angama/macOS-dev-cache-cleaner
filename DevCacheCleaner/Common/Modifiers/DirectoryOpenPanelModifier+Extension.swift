//
//  DirectoryOpenPanelModifier.swift
//  DevCacheCleaner
//
//  Created by Karim Angama on 22/04/2026.
//

import AppKit
import SwiftUI

fileprivate struct DirectoryOpenPanelModifier: ViewModifier {

    @Binding var isPresented: Bool
    let title: String
    let message: String
    let prompt: String
    let directoryURL: URL?
    let onSelection: (URL) -> Void
    let onCancellation: () -> Void

    func body(content: Content) -> some View {
        content
            .onChange(of: isPresented) { _, newValue in
                guard newValue else {
                    return
                }

                DispatchQueue.main.async {
                    showOpenPanel()
                }
            }
    }

    @MainActor
    private func showOpenPanel() {
        isPresented = false

        let panel = NSOpenPanel()
        panel.title = title
        panel.message = message
        panel.prompt = prompt
        panel.directoryURL = directoryURL
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.resolvesAliases = true

        guard panel.runModal() == .OK, let url = panel.url else {
            onCancellation()
            return
        }

        onSelection(url)
    }
}

extension View {
    func directoryOpenPanel(
        isPresented: Binding<Bool>,
        title: String,
        message: String,
        prompt: String = "Select",
        directoryURL: URL? = FileManager.default.homeDirectoryForCurrentUser,
        onSelection: @escaping (URL) -> Void,
        onCancellation: @escaping () -> Void = {}
    ) -> some View {
        self.modifier(
            DirectoryOpenPanelModifier(
                isPresented: isPresented,
                title: title,
                message: message,
                prompt: prompt,
                directoryURL: directoryURL,
                onSelection: onSelection,
                onCancellation: onCancellation
            )
        )
    }
}
