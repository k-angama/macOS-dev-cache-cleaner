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
    case swiftPackageManager
    case androidGradle
    case androidBuild

    var title: String {
        switch self {
        case .nodeModules:
            return "Node Modules"
        case .cocoaPods:
            return "CocoaPods"
        case .swiftPackageManager:
            return "Swift Package Manager"
        case .androidGradle:
            return "Android Gradle"
        case .androidBuild:
            return "Android Build"
        }
    }

    var generatedDirectoryName: String {
        switch self {
        case .nodeModules:
            return "node_modules"
        case .cocoaPods:
            return "Pods"
        case .swiftPackageManager:
            return ".build"
        case .androidGradle:
            return ".gradle"
        case .androidBuild:
            return "build"
        }
    }
}
