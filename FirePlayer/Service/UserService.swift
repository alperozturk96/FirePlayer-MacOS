//
//  UserService.swift
//  FirePlayer
//
//  Created by Alper Ozturk on 17.11.2023.
//

import Foundation

struct UserService {
    func removeTrackPlaybackPosition(id: String) {
        UserDefaults.standard.removeObject(forKey: id)
    }
    
    func saveTrackPlaybackPosition(id: String?, position: Double?) {
        guard let id = id, let position = position else { return }
        UserDefaults.standard.setValue(position, forKey: id)
    }
    
    func readTrackPlaybackPosition(id: String) -> Double? {
        return UserDefaults.standard.double(forKey: id)
    }
    
    func saveFolderURL(url: URL) {
        UserDefaults.standard.set(url, forKey: UserDefaultsKeys.folderPath)
    }
    
    func readFolderURL() -> URL? {
        UserDefaults.standard.url(forKey: UserDefaultsKeys.folderPath)
    }
}
