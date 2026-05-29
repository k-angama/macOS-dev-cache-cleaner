//
//  MenuBarPanelController.swift
//  DevCacheCleaner
//
//  Created by Karim Angama on 29/05/2026.
//

import AppKit
import SwiftUI

@MainActor
final class MenuBarPanelController: NSObject {
    private enum Layout {
        static let homePanelWidth: CGFloat = 600
        static let screenPadding: CGFloat = 8
    }

    private let container: AppContainer
    private let statusItem: NSStatusItem
    private var homePanel: NSPanel?

    init(container: AppContainer) {
        self.container = container
        self.statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        super.init()

        configureStatusItem()
    }

    private func configureStatusItem() {
        guard let button = statusItem.button else {
            return
        }

        button.image = NSImage(named: "FeatherDusterIcon")
        button.image?.isTemplate = true
        button.target = self
        button.action = #selector(toggleHomePanel)
    }

    @objc private func toggleHomePanel() {
        if homePanel?.isVisible == true {
            hideHomePanel()
            return
        }

        showHomePanel()
    }

    private func showHomePanel() {
        let panel = makeHomePanelIfNeeded()
        positionHomePanel(panel)
        panel.orderFrontRegardless()
    }

    private func hideHomePanel() {
        homePanel?.orderOut(nil)
    }

    private func makeHomePanelIfNeeded() -> NSPanel {
        if let homePanel {
            return homePanel
        }

        let contentView = container.cleanerHomeDI.start()
            .frame(width: Layout.homePanelWidth)
            .padding()
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))

        let hostingController = NSHostingController(rootView: contentView.ignoresSafeArea())
        let panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: Layout.homePanelWidth, height: 1),
            styleMask: [.nonactivatingPanel, .titled, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )

        panel.contentViewController = hostingController
        panel.isFloatingPanel = true
        panel.level = .floating
        panel.collectionBehavior.insert(.fullScreenAuxiliary)
        panel.titleVisibility = .hidden
        panel.titlebarAppearsTransparent = true
        panel.backgroundColor = .clear
        panel.isOpaque = false
        panel.isMovable = false
        panel.isReleasedWhenClosed = false
        panel.standardWindowButton(.closeButton)?.isHidden = true
        panel.standardWindowButton(.miniaturizeButton)?.isHidden = true
        panel.standardWindowButton(.zoomButton)?.isHidden = true
        panel.animationBehavior = .utilityWindow
        panel.setContentSize(hostingController.view.fittingSize)

        homePanel = panel
        return panel
    }

    private func positionHomePanel(_ panel: NSPanel) {
        guard
            let button = statusItem.button,
            let buttonWindow = button.window
        else {
            panel.center()
            return
        }

        let buttonFrameInWindow = button.convert(button.bounds, to: nil)
        let buttonFrameInScreen = buttonWindow.convertToScreen(buttonFrameInWindow)
        let visibleFrame = buttonWindow.screen?.visibleFrame
            ?? panel.screen?.visibleFrame
            ?? NSScreen.main?.visibleFrame
            ?? .zero

        var panelFrame = panel.frame
        panelFrame.origin.x = buttonFrameInScreen.midX - (panelFrame.width / 2)
        panelFrame.origin.y = visibleFrame.maxY - panelFrame.height

        panelFrame.origin.x = min(
            max(panelFrame.origin.x, visibleFrame.minX + Layout.screenPadding),
            visibleFrame.maxX - panelFrame.width - Layout.screenPadding
        )
        panelFrame.origin.y = max(panelFrame.origin.y, visibleFrame.minY + Layout.screenPadding)

        panel.setFrame(panelFrame, display: false)
    }
}
