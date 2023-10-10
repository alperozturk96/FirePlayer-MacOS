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
    var title: String
    var artist: String
    var album: String
    var length: Double
    var path: URL
    
    init(title: String, artist: String, album: String, length: Double, path: URL) {
        self.title = title
        self.artist = artist
        self.album = album
        self.length = length
        self.path = path
    }
}
