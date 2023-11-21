//
//  MimeTypeUtil.swift
//  FirePlayer
//
//  Created by Alper Ozturk on 18.11.2023.
//

import Foundation

struct MimeTypeUtil {
    static let shared = MimeTypeUtil()
    
    private init() {}
    
    let unsupportedFormats = ["ape", "opus", "wv", "dsf", ""]

    func isSupported(format: String) -> Bool {
        !unsupportedFormats.contains(format)
    }
}
