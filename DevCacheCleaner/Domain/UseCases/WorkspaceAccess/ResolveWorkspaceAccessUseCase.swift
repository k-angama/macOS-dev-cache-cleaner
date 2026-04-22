//
//  ResolveWorkspaceAccessUseCase.swift
//  DevCacheCleaner
//
//  Created by Karim Angama on 22/04/2026.
//

import Foundation

struct ResolveWorkspaceAccessUseCase {

    private let workspaceAccessRepository: WorkspaceAccessRepository

    init(workspaceAccessRepository: WorkspaceAccessRepository) {
        self.workspaceAccessRepository = workspaceAccessRepository
    }

    func execute() -> URL? {
        workspaceAccessRepository.resolveWorkspaceURL()
    }
}
