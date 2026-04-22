//
//  WorkspaceCleanupTargetEntity.swift
//  DevCacheCleaner
//
//  Created by Karim Angama on 21/04/2026.
//

import Foundation

struct WorkspaceCleanupTargetEntity: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    let workspaceID: UUID
    let kind: WorkspaceCleanupKind
    let projectPath: String
    let directoryPath: String
    var size: CGFloat

    func updateSize(_ size: CGFloat) -> WorkspaceCleanupTargetEntity {
        WorkspaceCleanupTargetEntity(
            id: self.id,
            workspaceID: self.workspaceID,
            kind: self.kind,
            projectPath: self.projectPath,
            directoryPath: self.directoryPath,
            size: size
        )
    }
}

