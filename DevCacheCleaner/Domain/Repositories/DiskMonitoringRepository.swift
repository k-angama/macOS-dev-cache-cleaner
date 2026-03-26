//
//  DiskMonitoringRepository.swift
//  DevCacheCleaner
//
//  Created by Karim Angama on 14/03/2026.
//

import Foundation

public protocol DiskMonitoringRepository {
    var folderDidChange: ((String) -> Void)? { get set }
    func startMonitoring(url: URL)
    func stopMonitoring()
}
