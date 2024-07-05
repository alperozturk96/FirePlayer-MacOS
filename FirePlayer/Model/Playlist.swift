//
//  Playlist.swift
//  FirePlayer
//
//  Created by Alper Ozturk on 05.07.24.
//

import SwiftData

@Model
final class Playlist {
    @Attribute(.unique) var name: String
    var tracks: [Track]
    
    init(name: String, tracks: [Track]) {
        self.name = name
        self.tracks = tracks
    }
}
