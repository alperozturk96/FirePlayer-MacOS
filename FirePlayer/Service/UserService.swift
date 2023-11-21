//
//  UserService.swift
//  FirePlayer
//
//  Created by Alper Ozturk on 17.11.2023.
//

import Foundation

struct UserService {
    private let playlistsKey = "playlists"
    private let folderPath = "folderPath"
    
    func savePlaylist(playlists: [String]) {
        UserDefaults.standard.set(playlists, forKey: playlistsKey)
    }
    
    func readPlaylists() -> [String] {
        return if let playlists = UserDefaults.standard.array(forKey: playlistsKey) as? [String] {
            playlists
        } else {
            .init()
        }
    }
    
    func saveFolderURL(url: URL) {
        UserDefaults.standard.set(url, forKey: folderPath)
    }
    
    func readFolderURL() -> URL? {
        UserDefaults.standard.url(forKey: folderPath)
    }
}
