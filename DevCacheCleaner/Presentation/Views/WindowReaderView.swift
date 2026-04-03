//
//  WindowReaderView.swift
//  DevCacheCleaner
//
//  Created by Karim Angama on 01/04/2026.
//

import SwiftUI
import AppKit

final class WindowReaderNSView: NSView {
    var onResolve: ((NSWindow?) -> Void)?

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        DispatchQueue.main.async { [weak self] in
            self?.onResolve?(self?.window)
        }
    }
}

struct WindowReaderView: NSViewRepresentable {
    let onResolve: (NSWindow?) -> Void

    func makeNSView(context: Context) -> WindowReaderNSView {
        let view = WindowReaderNSView()
        view.onResolve = onResolve
        return view
    }

    func updateNSView(_ nsView: WindowReaderNSView, context: Context) {
        nsView.onResolve = onResolve

        DispatchQueue.main.async {
            onResolve(nsView.window)
        }
    }
}
