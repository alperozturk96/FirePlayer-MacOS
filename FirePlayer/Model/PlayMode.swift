//
//  PlayMode.swift
//  FirePlayer
//
//  Created by Alper Ozturk on 19.11.2023.
//

import Foundation

enum PlayMode {
    case shuffle, sequential, loop
    
    var next: Self {
        return switch(self) {
            case .shuffle: .sequential
            case .sequential: .loop
            case .loop: .shuffle
        }
    }
    
    var icon: String {
        return switch(self) {
            case .shuffle: AppIcons.shuffle
            case .sequential: AppIcons.sequential
            case .loop: AppIcons.loop
        }
    }
}
