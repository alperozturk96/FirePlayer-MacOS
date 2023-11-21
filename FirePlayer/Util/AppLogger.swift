//
//  AppLogger.swift
//  FirePlayer
//
//  Created by Alper Ozturk on 21.11.2023.
//

import OSLog

struct AppLogger {
    static let shared = AppLogger()
    private init() {}
    
    private let logger = Logger()
    
    func info(_ message: String) {
        logger.info("\(message)")
    }
}
