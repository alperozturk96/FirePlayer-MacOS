//
//  SortOptions.swift
//  FirePlayer
//
//  Created by Alper Ozturk on 26.11.2023.
//

import Foundation

enum SortOptions {
    case aToZ, zToA, newToOld, oldToNew
    
    func sortByTitle() -> Self {
        return if (self == .aToZ) {
            .zToA
        } else {
            .aToZ
        }
    }
    
    func sortByDate() -> Self {
        return if (self == .newToOld) {
            .oldToNew
        } else {
            .newToOld
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
