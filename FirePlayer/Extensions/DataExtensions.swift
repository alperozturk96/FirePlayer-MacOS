//
//  DataExtensions.swift
//  FirePlayer
//
//  Created by Alper Ozturk on 18.02.2024.
//

import Foundation

extension Data {
    func isMusicFile(url: URL) -> Bool {
        let musicFileExtensions: Set<String> = ["mp3", "m4a", "ogg", "flac", "wav", "wma", "alac", "ogg", "wv"]
        let fileExtension = url.pathExtension.lowercased()
        return musicFileExtensions.contains(fileExtension)
    }
}
