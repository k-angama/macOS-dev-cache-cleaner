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
    let alternateMarkerFileNames: [String]
    let generatedDirectoryName: String

    var markerFileNames: [String] {
        [markerFileName] + alternateMarkerFileNames
    }

    init(
        kind: WorkspaceCleanupKind,
        markerFileName: String,
        alternateMarkerFileNames: [String] = [],
        generatedDirectoryName: String
    ) {
        self.kind = kind
        self.markerFileName = markerFileName
        self.alternateMarkerFileNames = alternateMarkerFileNames
        self.generatedDirectoryName = generatedDirectoryName
    }

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
        ),
        WorkspaceCleanupRuleEntity(
            kind: .swiftPackageManager,
            markerFileName: "Package.swift",
            generatedDirectoryName: WorkspaceCleanupKind.swiftPackageManager.generatedDirectoryName
        ),
        WorkspaceCleanupRuleEntity(
            kind: .androidGradle,
            markerFileName: "settings.gradle",
            alternateMarkerFileNames: ["settings.gradle.kts"],
            generatedDirectoryName: WorkspaceCleanupKind.androidGradle.generatedDirectoryName
        ),
        WorkspaceCleanupRuleEntity(
            kind: .androidBuild,
            markerFileName: "build.gradle",
            alternateMarkerFileNames: ["build.gradle.kts"],
            generatedDirectoryName: WorkspaceCleanupKind.androidBuild.generatedDirectoryName
        )
    ]
}
