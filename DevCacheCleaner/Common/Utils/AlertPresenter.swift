//
//  AlertPresenter.swift
//  DevCacheCleaner
//
//  Created by Karim Angama on 17/03/2026.
//

import AppKit

@MainActor
struct AlertPresenter {

    struct ConfirmationResult {
        let didConfirm: Bool
        let isCheckboxChecked: Bool
    }

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
        checkboxTitle: String? = nil,
        confirmTitle: String = "Clean",
        cancelTitle: String = "Cancel"
    ) -> ConfirmationResult {
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = message
        alert.alertStyle = .warning
        var checkbox: NSButton?
        if let checkboxTitle {
            let checkboxButton = NSButton(
                checkboxWithTitle: checkboxTitle,
                target: nil,
                action: nil
            )
            checkbox = checkboxButton
            alert.accessoryView = checkboxButton
        }
        alert.addButton(withTitle: confirmTitle)
        alert.addButton(withTitle: cancelTitle)
        let didConfirm = alert.runModal() == .alertFirstButtonReturn
        return ConfirmationResult(
            didConfirm: didConfirm,
            isCheckboxChecked: checkbox?.state == .on
        )
    }

}
