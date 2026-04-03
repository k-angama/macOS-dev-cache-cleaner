//
//  FloatingPanelModifier.swift
//  DevCacheCleaner
//
//  Created by Karim Angama on 02/04/2026.
//

import AppKit
import Foundation
import SwiftUI

final class FloatingPanelWindowReaderNSView: NSView {
    var onResolve: ((NSWindow?) -> Void)?

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        DispatchQueue.main.async { [weak self] in
            self?.onResolve?(self?.window)
        }
    }
}

fileprivate struct FloatingPanelWindowReader: NSViewRepresentable {
    let onResolve: (NSWindow?) -> Void

    func makeNSView(context: Context) -> FloatingPanelWindowReaderNSView {
        let view = FloatingPanelWindowReaderNSView()
        view.onResolve = onResolve
        return view
    }

    func updateNSView(_ nsView: FloatingPanelWindowReaderNSView, context: Context) {
        nsView.onResolve = onResolve

        DispatchQueue.main.async {
            onResolve(nsView.window)
        }
    }
}

/// Add a ``FloatingPanel`` to a view hierarchy.
fileprivate struct FloatingPanelModifier<Item: Equatable, PanelContent: View>: ViewModifier {
    @Binding var item: Item?
    @State private var hostWindow: NSWindow?

    /// Determines the starting size of the panel
    var contentRect: CGRect = CGRect(x: 0, y: 0, width: 624, height: 512)

    /// Holds the panel content's view closure
    @ViewBuilder let view: (Item) -> PanelContent

    /// Stores the panel instance with the same generic type as the view closure
    @State private var panel: FloatingPanel<PanelContent>?

    func body(content: Content) -> some View {
        /*let _ = item.map { currentItem in
            panel?.updateContent {
                view(currentItem)
            }
        }*/

        content
            .background(
                FloatingPanelWindowReader { window in
                    hostWindow = window
                }
            )
            .onAppear {
                if let item {
                    ensurePanel(for: item)
                    present()
                }
            }
            .onChange(of: hostWindow) { _, _ in
                if item != nil {
                    present()
                }
            }
            .onChange(of: item) { _, newValue in
                if let item = newValue {
                    ensurePanel(for: item)
                    DispatchQueue.main.async {
                        present()
                    }
                } else {
                    panel?.close()
                }
            }
    }

    /// Present the panel and make it the key window
    func present() {
        positionPanel()
        panel?.orderFront(nil)
        panel?.makeKey()
    }

    func ensurePanel(for currentItem: Item) {
        let itemBinding = _item

        if panel == nil {
            panel = FloatingPanel(
                view: { view(currentItem) },
                contentRect: contentRect,
                onClose: {
                    itemBinding.wrappedValue = nil
                }
            )
        } else {
            panel?.updateContent {
                view(currentItem)
            }
        }
    }

    func positionPanel() {
        guard let panel, let hostWindow else {
            panel?.center()
            return
        }

        let gap: CGFloat = 12
        let anchorFrame = hostWindow.frame
        let visibleFrame = hostWindow.screen?.visibleFrame
            ?? panel.screen?.visibleFrame
            ?? NSScreen.main?.visibleFrame
            ?? .zero
        var panelFrame = panel.frame

        let preferredLeftX = anchorFrame.minX - gap - panelFrame.width
        let preferredRightX = anchorFrame.maxX + gap

        if preferredLeftX >= visibleFrame.minX {
            panelFrame.origin.x = preferredLeftX
        } else if preferredRightX + panelFrame.width <= visibleFrame.maxX {
            panelFrame.origin.x = preferredRightX
        } else {
            panelFrame.origin.x = max(
                visibleFrame.minX,
                min(preferredRightX, visibleFrame.maxX - panelFrame.width)
            )
        }

        let alignedTopY = anchorFrame.maxY - panelFrame.height
        let maxY = visibleFrame.maxY - panelFrame.height
        panelFrame.origin.y = min(max(alignedTopY, visibleFrame.minY), maxY)

        panel.setFrame(panelFrame, display: false)
    }
}

extension View {
    /** Present a ``FloatingPanel`` in SwiftUI fashion
     - Parameter of: The optional item driving the panel presentation state
     - Parameter contentRect: The initial content frame of the window
     - Parameter content: The displayed content
     **/
    func floatingPanel<Item: Equatable, Content: View>(
        of item: Binding<Item?>,
        contentRect: CGRect = CGRect(x: 0, y: 0, width: 460, height: 240),
        @ViewBuilder content: @escaping (Item) -> Content
    ) -> some View {
        self.modifier(
            FloatingPanelModifier(
                item: item,
                contentRect: contentRect,
                view: content
            )
        )
    }
}
