//
//  MenuBarPanelController.swift
//  DevCacheCleaner
//
//  Created by Karim Angama on 29/05/2026.
//

import AppKit
import SwiftUI

/// Menu bar home panel used instead of `MenuBarExtra`.
///
/// The home view needs to remain visible while secondary panels, such as the
/// storage detail panel and delete confirmation alerts, receive focus. A plain
/// SwiftUI menu-bar presentation closes as soon as focus moves away, so this
/// controller owns the AppKit panel directly.
private final class MenuBarHomePanel: NSPanel {
    /// Called after the panel loses key status to decide whether that loss of
    /// focus should close the menu panel.
    ///
    /// The decision is injected from `MenuBarPanelController` because the
    /// controller knows about the rest of the app windows. This keeps the panel
    /// subclass limited to window behavior.
    var shouldCloseAfterResignKey: (() -> Bool)?

    override func resignKey() {
        super.resignKey()

        // AppKit can update `NSApp.keyWindow` after `resignKey` returns.
        // Deferring one run-loop turn lets us inspect the real next key window
        // instead of closing during the short transition between panels.
        DispatchQueue.main.async { [weak self] in
            guard let self, isVisible else {
                return
            }

            if shouldCloseAfterResignKey?() ?? true {
                orderOut(nil)
            }
        }
    }

    /// The panel must be key-capable so SwiftUI controls inside it can receive
    /// input and so `resignKey` gives us a reliable close signal.
    override var canBecomeKey: Bool {
        true
    }

    /// Some AppKit focus transitions only behave consistently when a custom
    /// floating panel can also become main.
    override var canBecomeMain: Bool {
        true
    }
}

@MainActor
final class MenuBarPanelController: NSObject {
    private enum Layout {
        static let homePanelWidth: CGFloat = 600

        // Keep these values aligned with the detail panel layout. They are used
        // before the detail panel opens so the home panel leaves enough room for
        // it when the screen width allows.
        static let detailPanelWidth: CGFloat = Constants.StorageCategoryDetails.panelWidth
        static let detailPanelGap: CGFloat = 12
        static let screenPadding: CGFloat = 8
    }

    private let container: AppContainer
    private let statusItem: NSStatusItem
    private var homePanel: NSPanel?

    // Local events cover clicks inside this app, including normal windows,
    // panels, alerts, and the status-item button window. Global events cover
    // clicks outside the app, where AppKit does not provide a local event.
    private var localMouseDownMonitor: Any?
    private var globalMouseDownMonitor: Any?

    init(container: AppContainer) {
        self.container = container
        self.statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        super.init()

        configureStatusItem()
        startObservingAppFocusChanges()
        startObservingMouseDownEvents()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)

        if let localMouseDownMonitor {
            NSEvent.removeMonitor(localMouseDownMonitor)
        }

        if let globalMouseDownMonitor {
            NSEvent.removeMonitor(globalMouseDownMonitor)
        }
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

        // Making the panel key is intentional. Without this, the panel can stay
        // visible but stop participating in key-window transitions after the
        // detail panel opens, which makes outside-click dismissal unreliable.
        panel.makeKey()
    }

    private func hideHomePanel() {
        homePanel?.orderOut(nil)
    }

    private func startObservingAppFocusChanges() {
        // This catches Cmd-Tab, switching apps, and clicks that activate another
        // app. Mouse monitors handle pointer clicks; this observer handles app
        // activation changes that are not always represented as local events.
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationDidResignActive),
            name: NSApplication.didResignActiveNotification,
            object: nil
        )
    }

    @objc private func applicationDidResignActive() {
        hideHomePanel()
    }

    private func startObservingMouseDownEvents() {
        let eventMask: NSEvent.EventTypeMask = [.leftMouseDown, .rightMouseDown]

        // Local monitor: decide based on the clicked window. Returning the event
        // keeps normal controls working after the menu panel is hidden or kept.
        localMouseDownMonitor = NSEvent.addLocalMonitorForEvents(matching: eventMask) { [weak self] event in
            self?.handleLocalMouseDown(event)
            return event
        }

        // Global monitor: any mouse down outside this app should dismiss the
        // menu panel. AppKit does not expose the outside target window here, so
        // this path intentionally has no detail-panel exception.
        globalMouseDownMonitor = NSEvent.addGlobalMonitorForEvents(matching: eventMask) { [weak self] _ in
            Task { @MainActor in
                self?.hideHomePanel()
            }
        }
    }

    private func handleLocalMouseDown(_ event: NSEvent) {
        guard homePanel?.isVisible == true else {
            return
        }

        // Keep the panel open for clicks inside itself and for clicks on the
        // menu-bar icon. The icon click is handled by `toggleHomePanel`; closing
        // here as well would race with the toggle action.
        if event.window === homePanel || event.window === statusItem.button?.window {
            return
        }

        // Detail panels and modal alerts are AppKit panels. They are part of the
        // same workflow, so focusing them must not close the home panel.
        if event.window is NSPanel {
            return
        }

        // Any other in-app window click is outside the menu workflow.
        hideHomePanel()
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
        let panel = MenuBarHomePanel(
            contentRect: NSRect(x: 0, y: 0, width: Layout.homePanelWidth, height: 1),
            styleMask: [.nonactivatingPanel, .titled, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )

        // Close on key loss only when the next key window is not another panel.
        // `nil` can happen briefly between the home panel resigning key and the
        // detail panel becoming key, so `nil` means "wait" rather than close.
        panel.shouldCloseAfterResignKey = { [weak panel] in
            guard let panel else {
                return true
            }

            guard let keyWindow = NSApp.keyWindow else {
                return false
            }

            return keyWindow !== panel && !(keyWindow is NSPanel)
        }

        panel.contentViewController = hostingController
        panel.isFloatingPanel = true
        panel.level = .floating
        panel.collectionBehavior.insert(.fullScreenAuxiliary)

        // The real visual background and rounded shape come from SwiftUI. The
        // AppKit panel itself stays transparent so there is no titlebar or
        // window chrome visible around the custom content.
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
        // Position relative to the status-item button in screen coordinates.
        // `NSStatusBarButton` lives in its own window, so view coordinates must
        // be converted through the button window before placing the panel.
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
        panelFrame.origin.x = homePanelOriginX(
            panelWidth: panelFrame.width,
            buttonFrame: buttonFrameInScreen,
            visibleFrame: visibleFrame
        )
        panelFrame.origin.y = visibleFrame.maxY - panelFrame.height

        panelFrame.origin.y = max(panelFrame.origin.y, visibleFrame.minY + Layout.screenPadding)

        panel.setFrame(panelFrame, display: false)
    }

    private func homePanelOriginX(
        panelWidth: CGFloat,
        buttonFrame: NSRect,
        visibleFrame: NSRect
    ) -> CGFloat {
        let minX = visibleFrame.minX + Layout.screenPadding
        let maxX = visibleFrame.maxX - panelWidth - Layout.screenPadding
        let detailSpaceWidth = panelWidth + Layout.detailPanelGap + Layout.detailPanelWidth
        let hasEnoughWidthForDetails = visibleFrame.width >= detailSpaceWidth + (Layout.screenPadding * 2)

        // On narrow screens, pin the home panel to the right edge. This leaves
        // the most predictable space for the detail panel when it opens.
        guard hasEnoughWidthForDetails else {
            return maxX
        }

        // Prefer the same x-origin as the menu-bar icon, but only when the home
        // panel plus detail panel can still fit on screen.
        let leftAlignedX = buttonFrame.minX
        if leftAlignedX >= minX, leftAlignedX + detailSpaceWidth <= visibleFrame.maxX - Layout.screenPadding {
            return leftAlignedX
        }

        // If left alignment would push the detail panel offscreen, align the
        // home panel's right edge with the icon instead.
        let rightAlignedX = buttonFrame.maxX - panelWidth
        if rightAlignedX >= minX, rightAlignedX <= maxX {
            return rightAlignedX
        }

        return maxX
    }
}
