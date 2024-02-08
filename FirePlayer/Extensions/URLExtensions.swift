//
//  URLExtensions.swift
//  FirePlayer
//
//  Created by Alper Ozturk on 18.11.2023.
//

import Foundation
import AVFoundation

extension [URL] {
    var supportedUrls: [URL] {
        return self.filter { url in
            let format = url.pathExtension
            return MimeTypeUtil.shared.isSupported(format: format)
        }
    }
}

extension URL {
    func toTrack() async -> Track {
        let asset = AVAsset(url: self)
        
        let metadata = try? await asset.load(.metadata)
        
        let artist: String? = await extractMetadata(metadata, .commonKeyArtist)
        let album: String? = await extractMetadata(metadata, .commonKeyAlbumName)
        
        let resourceValues = try? self.resourceValues(forKeys: [.contentModificationDateKey])
        let dateModified: Date? = resourceValues?.contentModificationDate
        
        return Track(title: lastPathComponent, artist: artist ?? "", album: album ?? "", path: self, pathExtension: pathExtension, dateModified: dateModified)
    }
    
    private func extractMetadata<Value>(_ metadata: [AVMetadataItem]?, _ key: AVMetadataKey) async -> Value? {
        return try? await metadata?.first(where: { $0.commonKey == key })?.load(.value) as? Value
    }
}
