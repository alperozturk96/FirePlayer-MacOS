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
    func toTrack() -> Track {
        let asset = AVAsset(url: self)
        let (artist, album) = getArtistAndAlbum(asset)
        
        if artist.isEmpty || album.isEmpty {
            print("METADATA_NOT_FOUND_FOR: ", lastPathComponent)
        }
        
        let resourceValues = try? self.resourceValues(forKeys: [.contentModificationDateKey])
        let dateModified: Date? = resourceValues?.contentModificationDate
        
        return Track(title: lastPathComponent, artist: artist, album: album, path: self, pathExtension: pathExtension, dateModified: dateModified)
    }
    
    private func getArtistAndAlbum(_ asset: AVAsset) -> (artist: String, album: String) {
        let formats = [
            kAudioFileFLACType,
            kAudioFilePropertyID3Tag,
            kAudioFileM4AType,
            kAudioFileMP3Type,
            kAudioFileWAVEType
        ]
        
        for format in formats {
            let (artist, album) = audioFileInfo(metadata: format) ?? ("", "")
            if !artist.isEmpty && !album.isEmpty {
                return (artist, album)
            }
        }
        
        return ("", "")
    }
    
    private func audioFileInfo(metadata: AudioFileTypeID) -> (String, String)? {
        var fileID: AudioFileID? = nil
        var status: OSStatus = AudioFileOpenURL(self as CFURL, .readPermission, metadata, &fileID)
        
        guard status == noErr else { return nil }
        
        var dict: CFDictionary? = nil
        var dataSize = UInt32(MemoryLayout<CFDictionary?>.size(ofValue: dict))
        
        guard let audioFile = fileID else { return nil }
        
        
        let (unsafeDataSize, unsafeDict) = withUnsafeMutablePointer(to: &dataSize) { unsafeDataSize in
            withUnsafeMutablePointer(to: &dict) { unsafeDict in
                return (unsafeDataSize, unsafeDict)
            }
        }
        
        status = AudioFileGetProperty(audioFile, kAudioFilePropertyInfoDictionary, unsafeDataSize, unsafeDict)
        guard status == noErr else { return nil }
        
        AudioFileClose(audioFile)
        
        guard let cfDict = dict else { return nil }
        
        let tagsDict = NSDictionary.init(dictionary: cfDict)
        
        let artist = tagsDict["artist"] as? String
        let album = tagsDict["album"] as? String
        return (artist ?? "", album ?? "")
    }
}
