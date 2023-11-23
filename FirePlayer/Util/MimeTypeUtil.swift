//
//  MimeTypeUtil.swift
//  FirePlayer
//
//  Created by Alper Ozturk on 18.11.2023.
//

import Foundation
import AVFoundation

struct MimeTypeUtil {
    static let shared = MimeTypeUtil()
    
    private init() {}
    
    var allowedAVPlayerFileExtensions: [String] {
        let avTypes: [AVFileType] = AVURLAsset.audiovisualTypes()
        
        let avExtensions: [String] =
            avTypes
                .compactMap({ UTType($0.rawValue)?.preferredFilenameExtension })
                .sorted()

        return avExtensions
    }

    func isSupported(format: String) -> Bool {
        allowedAVPlayerFileExtensions.contains(format)
    }
}
