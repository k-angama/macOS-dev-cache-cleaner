//
//  SaveHomeAccessUseCase.swift
//  DevCacheCleaner
//
//  Created by Karim Angama on 15/03/2026.
//

import Foundation

struct SaveHomeAccessUseCase {

    private let homeAccessRepository: HomeAccessRepository

    init(homeAccessRepository: HomeAccessRepository) {
        self.homeAccessRepository = homeAccessRepository
    }

    func execute(url: URL) -> Bool {
        homeAccessRepository.saveHomeURL(url)
    }
}
