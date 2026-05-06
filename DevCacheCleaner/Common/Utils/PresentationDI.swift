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
    static func start(data: Data) -> Content
}
