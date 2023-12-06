//
//  URLExtensions.swift
//  FirePlayer
//
//  Created by Alper Ozturk on 18.11.2023.
//

import Foundation

extension [URL] {
    var supportedUrls: [URL] {
        return self.filter { url in
            let format = url.pathExtension
            return MimeTypeUtil.shared.isSupported(format: format)
        }
    }
}

extension URL {
    func toTrack(_ analyzer: TrackMetaDataAnalyzer) -> Track {
        let title = self.lastPathComponent
        
        var track = Track(title: title, artist: "", album: "", path: self, pathExtension: self.pathExtension)
        
        if let metadata = analyzer.getMetadata(url: self) {
            track.artist = metadata["artist"] as? String ?? "Unknown"
            track.album = metadata["album"] as? String ?? "Unknown"
            
            // FIX ME
            if let dateModified = metadata[kMDItemContentModificationDate as String] as? Date {
                track.dateModified = dateModified
            }
        }
        
        return track
    }
}
