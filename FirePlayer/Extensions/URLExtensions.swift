//
//  URLExtensions.swift
//  FirePlayer
//
//  Created by Alper Ozturk on 18.11.2023.
//

import Foundation

extension [URL] {
    var supportedUrls: [URL] {
        return self.filter { url in
            let format = url.pathExtension
            return MimeTypeUtil.shared.isSupported(format: format)
        }
    }
}
