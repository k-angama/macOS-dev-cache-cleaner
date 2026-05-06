//
//  PresentationDI.swift
//  DevCacheCleaner
//
//  Created by Karim Angama on 06/05/2026.
//

import Foundation
import SwiftUI

protocol PresentationDI {
    associatedtype Content: View
    associatedtype Data = Void
    func start(data: Data) -> Content
}

extension PresentationDI where Data == Void {
    func start() -> Content {
        start(data: ())
    }
}
