//
//  PlayMode.swift
//  FirePlayer
//
//  Created by Alper Ozturk on 19.11.2023.
//

import Foundation

enum PlayMode {
    case shuffle, sequential
    
    var next: Self {
        (self == .shuffle) ? .sequential : .shuffle
    }
    
    var icon: String {
        self == .shuffle ? "shuffle.circle.fill" : "arrow.forward.to.line.circle.fill"
    }
}
