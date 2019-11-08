//
//  Int+Extension.swift
//  gmail-mark-as-read
//
//  Created by Jon Lazar on 11/6/19.
//  Copyright © 2019 Product Corp. All rights reserved.
//

import Foundation

extension Int {

    /// Returns true if self is within 200 - 299
    var isSuccessfulHTTPStatusCode: Bool {
        return (200...299).contains(self)
    }
}
