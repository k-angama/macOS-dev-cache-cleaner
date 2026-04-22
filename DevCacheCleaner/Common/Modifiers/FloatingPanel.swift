//
//  FloatingPanel.swift
//  DevCacheCleaner
//
//  Created by Karim Angama on 02/04/2026.
//  Adapted from Cindori's "Make a floating panel in SwiftUI for macOS":
//  https://cindori.com/developer/floating-panel
//

import Foundation
import SwiftUI
 
/// An NSPanel subclass that implements floating panel traits.
class FloatingPanel<Content: View>: NSPanel {
    
    private let onClose: () -> Void
    private var isClosing = false
 
    init(view: () -> Content,
             contentRect: NSRect,
             backing: NSWindow.BackingStoreType = .buffered,
             defer flag: Bool = false,
             onClose: @escaping () -> Void) {
        self.onClose = onClose
     
        /// Init the window as usual
        super.init(contentRect: contentRect,
                    styleMask: [.nonactivatingPanel, .titled, .fullSizeContentView],
                    backing: backing,
                    defer: flag)
     
        /// Allow the panel to be on top of other windows
        isFloatingPanel = true
        level = .floating
     
        /// Allow the pannel to be overlaid in a fullscreen space
        collectionBehavior.insert(.fullScreenAuxiliary)
     
        /// Don't show a window title, even if it's set
        titleVisibility = .hidden
        titlebarAppearsTransparent = true
        backgroundColor = .clear
        isOpaque = false
        
        isMovable = false
        isReleasedWhenClosed = false
     
        /// Hide all traffic light buttons
        standardWindowButton(.closeButton)?.isHidden = true
        standardWindowButton(.miniaturizeButton)?.isHidden = true
        standardWindowButton(.zoomButton)?.isHidden = true
     
        /// Sets animations accordingly
        animationBehavior = .utilityWindow
     
        /// Set the content view.
        /// The safe area is ignored because the title bar still interferes with the geometry
        updateContent(view)
    }

    func updateContent(_ view: () -> Content) {
        let hostingView = NSHostingView(rootView: view()
            .ignoresSafeArea())
        
        hostingView.wantsLayer = true
        hostingView.layer?.cornerRadius = 20
        hostingView.layer?.masksToBounds = true

        contentView = hostingView
    }

    override func resignKey() {
        super.resignKey()

        if isVisible {
            close()
        }
    }
    
    /// Close and toggle presentation, so that it matches the current state of the panel
    override func close() {
        guard isClosing == false else { return }

        isClosing = true
        super.close()
        onClose()
        isClosing = false
    }
     
    /// `canBecomeKey` and `canBecomeMain` are both required so that text inputs inside the panel can receive focus
    override var canBecomeKey: Bool {
        return true
    }
     
    override var canBecomeMain: Bool {
        return true
    }
}
