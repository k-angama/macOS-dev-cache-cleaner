//
//  Parameters.swift
//  DevCacheCleaner
//
//  Created by Karim Angama on 06/03/2026.
//

import Foundation

protocol Parameters {
    var homeFolderBookmark: Data? { get set }
}

struct ParametersImpl: Parameters {
    
    struct Keys {
        static let homeFolderBookmark = "com.angama.home-folder-bookmark-test"
    }
    
    var homeFolderBookmark: Data? {
        get {
            UserDefaults.standard.data(forKey: Keys.homeFolderBookmark)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.homeFolderBookmark)
        }
    }
    
}
