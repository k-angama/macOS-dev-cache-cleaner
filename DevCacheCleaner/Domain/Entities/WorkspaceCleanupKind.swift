//
//  WorkspaceCleanupKind.swift
//  DevCacheCleaner
//
//  Created by Karim Angama on 21/04/2026.
//

import Foundation

enum WorkspaceCleanupKind: String, CaseIterable, Codable, Hashable {
    case nodeModules
    case cocoaPods

    var title: String {
        switch self {
        case .nodeModules:
            return "Node Modules"
        case .cocoaPods:
            return "CocoaPods"
        }
    }

    var generatedDirectoryName: String {
        switch self {
        case .nodeModules:
            return "node_modules"
        case .cocoaPods:
            return "Pods"
        }
    }
}

