//
//  Track.swift
//  FirePlayer
//
//  Created by Alper Ozturk on 2.10.2023.
//

import Foundation

struct Track {
    let id = UUID()
    var title: String
    var artist: String
    var album: String
    var length: Double
    var path: URL
}
