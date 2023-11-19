//
//  CMTimeExtensions.swift
//  FirePlayer
//
//  Created by Alper Ozturk on 19.11.2023.
//

import AVFoundation

extension CMTime {
    var isRepresentable: Bool {
        timescale > 0 && value > 0
    }
    
    var roundedSeconds: TimeInterval {
        return seconds.rounded()
    }
    var hours:  Int { return Int(roundedSeconds / 3600) }
    var minute: Int { return Int(roundedSeconds.truncatingRemainder(dividingBy: 3600) / 60) }
    var second: Int { return Int(roundedSeconds.truncatingRemainder(dividingBy: 60)) }
    var positionalTime: String? {
        return if isRepresentable {
            hours > 0 ?
                String(format: "%d:%02d:%02d",
                       hours, minute, second) :
                String(format: "%02d:%02d",
                       minute, second)
        } else {
            nil
        }
    }
}
