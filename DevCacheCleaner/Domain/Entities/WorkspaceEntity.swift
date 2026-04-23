//
//  WorkspaceEntity.swift
//  DevCacheCleaner
//
//  Created by Karim Angama on 21/04/2026.
//

import Foundation

struct WorkspaceEntity: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    let name: String
    let path: String
    let bookmarkData: Data
}

