//
//  SortOptions.swift
//  FirePlayer
//
//  Created by Alper Ozturk on 26.11.2023.
//

import Foundation

enum SortOptions {
    case aToZ, zToA, newToOld, oldToNew
    
    var next: Self {
        return if self == .aToZ {
            .zToA
        } else if self == .zToA {
            .newToOld
        } else if self == .newToOld {
            .oldToNew
        } else {
            .aToZ
        }
    }
    
    var icon: String {
        return if self == .aToZ {
            AppIcons.letterA
        } else if self == .zToA {
            AppIcons.letterZ
        } else if self == .newToOld {
            AppIcons.newToOld
        } else {
            AppIcons.oldToNew
        }
    }
}
