//
//  UserService.swift
//  FirePlayer
//
//  Created by Alper Ozturk on 17.11.2023.
//

import Foundation

struct UserService {
    private let folderPath = "folderPath"
    
    func saveFolderURL(url: URL) {
        UserDefaults.standard.set(url, forKey: folderPath)
    }
    
    func readFolderURL() -> URL? {
        UserDefaults.standard.url(forKey: folderPath)
    }
}
