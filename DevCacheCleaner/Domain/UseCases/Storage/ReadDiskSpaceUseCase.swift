//
//  ReadDiskSpaceUseCase.swift
//  DevCacheCleaner
//
//  Created by Karim Angama on 15/03/2026.
//

import Foundation

struct ReadDiskSpaceUseCase {

    private let diskRepository: DiskRepository

    init(diskRepository: DiskRepository) {
        self.diskRepository = diskRepository
    }

    func execute() -> DiskSpaceEntity {
        DiskSpaceEntity(
            totalSize: diskRepository.totalDiskCapacity,
            freeSize: diskRepository.availableDiskCapacity
        )
    }
}
