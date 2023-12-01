//
//  SortOptions.swift
//  FirePlayer
//
//  Created by Alper Ozturk on 26.11.2023.
//

import Foundation

enum SortOptions {
    case aToZ, zToA
    
    var next: SortOptions {
        self == .aToZ ? .zToA : .aToZ
    }
}
