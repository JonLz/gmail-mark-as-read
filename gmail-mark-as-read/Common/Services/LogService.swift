//
//  LogService.swift
//  gmail-mark-as-read
//
//  Created by Jon on 11/6/19.
//  Copyright © 2019 Product Corp. All rights reserved.
//

import Foundation

enum LogLevel {
    case info
    case error
}

protocol LogServicing {
    func log(_ message: String)
    func log(_ message: String, level: LogLevel)
}

class LogService: LogServicing {
    func log(_ message: String) {
        log(message, level: .info)
    }
    
    func log(_ message: String, level: LogLevel) {
        #if DEBUG
        print(message)
        #endif
    }
}
