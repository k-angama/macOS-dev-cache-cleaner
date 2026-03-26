//
//  URL+Extension.swift
//  DevCacheCleaner
//
//  Created by Karim Angama on 17/03/2026.
//

import Foundation

extension URL {
    
    func withSecurityScope<T>(_ work: () throws -> T) rethrows -> T {
        let isSecurityScoped = self.startAccessingSecurityScopedResource()
        defer {
            if isSecurityScoped {
                self.stopAccessingSecurityScopedResource()
            }
        }
        return try work()
    }
    
}
