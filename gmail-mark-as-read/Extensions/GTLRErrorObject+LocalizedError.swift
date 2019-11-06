//
//  GTLRErrorObject+LocalizedError.swift
//  gmail-mark-as-read
//
//  Created by Jon on 11/6/19.
//  Copyright © 2019 Product Corp. All rights reserved.
//

import Foundation
import GoogleAPIClientForREST

extension GTLRErrorObject: LocalizedError {
    public var errorDescription: String? {
        if let message = message {
            return NSLocalizedString(message, comment: "")
        }
        
        if let code = code {
            return NSLocalizedString("GTLR error code: \(code)", comment: "")
        }
        
        return nil
    }
}
