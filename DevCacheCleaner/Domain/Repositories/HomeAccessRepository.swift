//
//  HomeAccessRepository.swift
//  DevCacheCleaner
//
//  Created by Karim Angama on 14/03/2026.
//

import Foundation

protocol HomeAccessRepository {
    func requestAndSaveHomeAccess() -> URL?
    func resolveHomeURL() -> URL?
}
