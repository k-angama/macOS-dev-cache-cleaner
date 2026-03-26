//
//  AlertPresenter.swift
//  DevCacheCleaner
//
//  Created by Karim Angama on 17/03/2026.
//

import AppKit

@MainActor
struct AlertPresenter {

    @discardableResult
    static func showError(title: String, message: String) -> Bool  {
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = message
        alert.alertStyle = .warning
        alert.addButton(withTitle: "OK")
        return alert.runModal() == .abort
    }

    static func showConfirmation(
        title: String,
        message: String,
        confirmTitle: String = "Clean",
        cancelTitle: String = "Cancel"
    ) -> Bool {
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = message
        alert.alertStyle = .warning
        alert.addButton(withTitle: confirmTitle)
        alert.addButton(withTitle: cancelTitle)
        return alert.runModal() == .alertFirstButtonReturn
    }

}
