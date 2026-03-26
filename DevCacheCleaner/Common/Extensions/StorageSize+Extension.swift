//
//  StorageSize+Extension.swift
//  DevCacheCleaner
//
//  Created by Karim Angama on 15/03/2026.
//

import Foundation

extension BinaryInteger {

    var toCGFlot: CGFloat {
        CGFloat(self)
    }

}

extension CGFloat {
    
    var byteCountString: String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        formatter.includesUnit = true
        formatter.allowedUnits = [.useKB, .useMB, .useGB, .useTB]
        formatter.isAdaptive = true

        let bytes = Int64(self)
        return formatter.string(fromByteCount: bytes)
    }
    
}
