//
//  Track.swift
//  FirePlayer
//
//  Created by Alper Ozturk on 2.10.2023.
//

import Foundation
import SwiftData

@Model
final class Track {
    let id = UUID()
    var title: String
    var artist: String
    var album: String
    var path: URL
    var pathExtension: String
    var dateModified: Date?
    @Relationship(inverse: \Playlist.tracks) var playlist: [Playlist]?

    init(title: String, artist: String, album: String, path: URL, pathExtension: String, dateModified: Date? = nil, playlist: [Playlist]? = nil) {
        self.title = title
        self.artist = artist
        self.album = album
        self.path = path
        self.pathExtension = pathExtension
        self.dateModified = dateModified
        self.playlist = playlist
    }
}
