//
//  TrackMetaDataAnalyzer.swift
//  FirePlayer
//
//  Created by Alper Ozturk on 10.10.2023.
//

import Foundation
import AVFoundation

struct TrackMetaDataAnalyzer {
    
    func getMetadata(url: URL) -> NSDictionary? {
        var fileID: AudioFileID? = nil
        var status: OSStatus = AudioFileOpenURL(url as CFURL, .readPermission, kAudioFileFLACType, &fileID)
        
        guard status == noErr else {
            return nil
        }
        
        var dict: CFDictionary? = nil
        var dataSize = UInt32(MemoryLayout<CFDictionary?>.size(ofValue: dict))
        
        guard let audioFile = fileID else {
            return nil
        }
        
        status = AudioFileGetProperty(audioFile, kAudioFilePropertyInfoDictionary, &dataSize, &dict)
        
        guard status == noErr else {
            return nil
        }
        
        AudioFileClose(audioFile)
        
        guard let cfDict = dict else {
            return nil
        }
        
        let tagsDict = NSDictionary.init(dictionary: cfDict)
        
        return tagsDict
    }
}
