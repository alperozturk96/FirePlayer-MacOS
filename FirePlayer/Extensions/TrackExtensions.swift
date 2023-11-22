//
//  TrackExtensions.swift
//  FirePlayer
//
//  Created by Alper Ozturk on 17.11.2023.
//

import Foundation

extension [Track] {
    func sortByTitleAZ() -> [Track] {
        return self.sorted { $0.title < $1.title }
    }

    func sortByTitleZA() -> [Track] {
        return self.sorted { $0.title > $1.title }
    }
    
    func filterByTitle(title: String) -> [Track] {
        self.filter { $0.title.localizedCaseInsensitiveContains(title) }
    }
    
    func filterByArtist(artist: String) -> [Track] {
        self.filter { $0.artist.localizedCaseInsensitiveContains(artist) }
    }
    
    func filterByAlbum(album: String) -> [Track] {
        self.filter { $0.album.localizedCaseInsensitiveContains(album) }
    }
    
    // FIXME crashes for playlist
    var randomIndex: Int {
        Int.random(in: 0..<self.count)
    }
}
