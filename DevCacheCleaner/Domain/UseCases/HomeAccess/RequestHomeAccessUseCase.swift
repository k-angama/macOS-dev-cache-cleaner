//
//  RequestHomeAccessUseCase.swift
//  DevCacheCleaner
//
//  Created by Karim Angama on 15/03/2026.
//

import Foundation

struct RequestHomeAccessUseCase {

    private let homeAccessRepository: HomeAccessRepository

    init(homeAccessRepository: HomeAccessRepository) {
        self.homeAccessRepository = homeAccessRepository
    }

    func execute() -> URL? {
        homeAccessRepository.requestAndSaveHomeAccess()
    }
}
