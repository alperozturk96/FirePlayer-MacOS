//
//  UserService.swift
//  FirePlayer
//
//  Created by Alper Ozturk on 17.11.2023.
//

import Foundation

struct UserService {
    func removeTrackPlaybackPosition(id: UUID) {
        UserDefaults.standard.removeObject(forKey: id.uuidString)
    }
    
    func saveTrackPlaybackPosition(id: UUID?, position: Double?) {
        guard let id = id, let position = position else { return }
        UserDefaults.standard.setValue(position, forKey: id.uuidString)
    }
    
    func readTrackPlaybackPosition(id: UUID) -> Double? {
        return UserDefaults.standard.double(forKey: id.uuidString)
    }
    
    func saveFolderURL(url: URL) {
        UserDefaults.standard.set(url, forKey: UserDefaultsKeys.folderPath)
    }
    
    func readFolderURL() -> URL? {
        UserDefaults.standard.url(forKey: UserDefaultsKeys.folderPath)
    }
}
