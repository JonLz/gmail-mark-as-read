//
//  ServiceRegistry.swift
//  gmail-mark-as-read
//
//  Created by Jon Lazar on 10/21/19.
//  Copyright © 2019 Product Corp. All rights reserved.
//

import Foundation

final class ServiceRegistry {
    static func ensureStarted() {
        GoogleSignInService().start()
    }
}
