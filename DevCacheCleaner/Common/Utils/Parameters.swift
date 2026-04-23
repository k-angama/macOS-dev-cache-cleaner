//
//  Parameters.swift
//  DevCacheCleaner
//
//  Created by Karim Angama on 06/03/2026.
//

import Foundation

protocol Parameters {
    var homeFolderBookmark: Data? { get set }
    var workspaceFolderBookmark: Data? { get set }
}

struct ParametersImpl: Parameters {
    
    struct Keys {
        static let homeFolderBookmark = "com.angama.home-folder-bookmark"
        static let workspaceFolderBookmark = "com.angama.workspace-folder-bookmark"
    }
    
    var homeFolderBookmark: Data? {
        get {
            UserDefaults.standard.data(forKey: Keys.homeFolderBookmark)
        }
        set {
            set(newValue, forKey: Keys.homeFolderBookmark)
        }
    }

    var workspaceFolderBookmark: Data? {
        get {
            UserDefaults.standard.data(forKey: Keys.workspaceFolderBookmark)
        }
        set {
            set(newValue, forKey: Keys.workspaceFolderBookmark)
        }
    }

    private func set(_ data: Data?, forKey key: String) {
        if let data {
            UserDefaults.standard.set(data, forKey: key)
        } else {
            UserDefaults.standard.removeObject(forKey: key)
        }
    }
    
}
