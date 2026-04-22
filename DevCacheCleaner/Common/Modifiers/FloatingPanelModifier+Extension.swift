//
//  FloatingPanelModifier.swift
//  DevCacheCleaner
//
//  Created by Karim Angama on 02/04/2026.
//  Adapted from Cindori's "Make a floating panel in SwiftUI for macOS":
//  https://cindori.com/developer/floating-panel
//

import AppKit
import Foundation
import SwiftUI

/// Add a ``FloatingPanel`` to a view hierarchy.
fileprivate struct FloatingPanelModifier<Item: Equatable, PanelContent: View>: ViewModifier {
    
    //private var hostWindow: NSWindow?
    @Binding var item: Item?

    /// Determines the starting size of the panel
    var contentRect: CGRect = CGRect(x: 0, y: 0, width: 460, height: 240)

    /// Holds the panel content's view closure
    @ViewBuilder let view: (Item) -> PanelContent

    /// Stores the panel instance with the same generic type as the view closure
    @State private var panel: FloatingPanel<PanelContent>?

    func body(content: Content) -> some View {

        content
            .onChange(of: item) { _, newValue in
                if let item = newValue {
                    ensurePanel(for: item)
                    present()
                } else {
                    panel?.close()
                }
            }
    }

    /// Present the panel and make it the key window
    func present() {
        let anchor = NSApp.keyWindow ?? NSApp.mainWindow
        DispatchQueue.main.async {
            if panel?.isVisible == false {
                positionPanel(relativeTo: anchor)
            }
            panel?.orderFront(nil)
            panel?.makeKey()
        }
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

    func positionPanel(relativeTo hostWindow: NSWindow?) {
        
        guard let panel, let hostWindow, hostWindow !== panel else {
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
     - Parameter content: The displayed content
     **/
    func floatingPanel<Item: Equatable, Content: View>(
        of item: Binding<Item?>,
        @ViewBuilder content: @escaping (Item) -> Content
    ) -> some View {
        self.modifier(
            FloatingPanelModifier(
                item: item,
                view: content
            )
        )
    }
}
