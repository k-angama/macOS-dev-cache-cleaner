//
//  WorkspaceCleanupRuleEntity.swift
//  DevCacheCleaner
//
//  Created by Karim Angama on 21/04/2026.
//

import Foundation

struct WorkspaceCleanupRuleEntity: Identifiable, Codable, Hashable {
    var id: WorkspaceCleanupKind { kind }
    let kind: WorkspaceCleanupKind
    let markerFileName: String
    let generatedDirectoryName: String

    static let supportedRules: [WorkspaceCleanupRuleEntity] = [
        WorkspaceCleanupRuleEntity(
            kind: .nodeModules,
            markerFileName: "package.json",
            generatedDirectoryName: WorkspaceCleanupKind.nodeModules.generatedDirectoryName
        ),
        WorkspaceCleanupRuleEntity(
            kind: .cocoaPods,
            markerFileName: "Podfile",
            generatedDirectoryName: WorkspaceCleanupKind.cocoaPods.generatedDirectoryName
        )
    ]
}

