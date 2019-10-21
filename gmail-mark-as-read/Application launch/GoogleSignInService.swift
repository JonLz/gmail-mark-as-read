//
//  GoogleSignInService.swift
//  gmail-mark-as-read
//
//  Created by Jon Lazar on 10/21/19.
//  Copyright © 2019 Product Corp. All rights reserved.
//

import Foundation
import GoogleSignIn

final class GoogleSignInService {
    func start() {
        let clientId = AppConfiguration().appConstants.googleSignInClientId
        GIDSignIn.sharedInstance()?.clientID = clientId
    }
}
