//
//  Collection+Extension.swift
//  DevCacheCleaner
//
//  Created by Karim Angama on 06/03/2026.
//

import Foundation

extension Collection where Element: Numeric {
    func sum() -> Element {
        return reduce(0, +)
    }
}

extension Collection {
    func sum<T: Numeric>(_ transform: (Element) throws -> T) rethrows -> T {
        return try map(transform).sum()
    }
}
