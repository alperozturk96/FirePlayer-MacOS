//
//  StringExtensions.swift
//  FirePlayer
//
//  Created by Alper Ozturk on 18.11.2023.
//

import Foundation

extension String {
    var normalize: String {
        return self.folding(options: .diacriticInsensitive, locale: .current)
    }
}

// MARK: - Localization
extension String {
    var localized: String {
        NSLocalizedString(self, comment: "\(self)_doesntExists")
    }
    
    func argLocalized(_ placeholder: String) -> String {
        String(format: placeholder.localized, self)
    }
    
    func localized(_ args: [CVarArg]) -> String { String(format: localized, args) }
    func localized(_ args: CVarArg...) -> String { String(format: localized, args) }
}
