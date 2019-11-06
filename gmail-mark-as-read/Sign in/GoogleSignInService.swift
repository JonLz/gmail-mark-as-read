//
//  GoogleSignInService.swift
//  gmail-mark-as-read
//
//  Created by Jon Lazar on 10/21/19.
//  Copyright © 2019 Product Corp. All rights reserved.
//

import Foundation
import GoogleSignIn
import GoogleAPIClientForREST.GTLRGmailService

protocol GoogleSignInServiceDelegate: class {
    func didSignIn(signInService: GoogleSignInService, user: GIDGoogleUser)
    func failedSignIn()
}

final class GoogleSignInService: NSObject {

    typealias Dependencies = HasLogServiceDependency
    
    weak var delegate: GoogleSignInServiceDelegate?
    let GIDSignIn: GIDSignIn = GoogleSignIn.GIDSignIn.sharedInstance()
    private let logService: LogServicing
    
    init(dependencies: Dependencies) {
        logService = dependencies.logService
    }
    
    func start() {
        setUpGIDSignIn()
    }
    
    func logout() {
        GIDSignIn.signOut()
    }
    
    func restorePreviousSignIn() {
        GIDSignIn.restorePreviousSignIn()
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        return GIDSignIn.handle(url)
    }

    private func setUpGIDSignIn() {
        /// Client identifier
        let clientId = AppConfiguration().appConstants.googleSignInClientId
        GIDSignIn.clientID = clientId

        /// Scopes
        /// Requesting additional scopes: https://developers.google.com/identity/sign-in/ios/additional-scopes
        /// Gmail scopes: https://developers.google.com/gmail/api/auth/scopes
        let scopes = GIDSignIn.scopes + [kGTLRAuthScopeGmailLabels, kGTLRAuthScopeGmailModify]
        GIDSignIn.scopes = scopes

        /// Internal delegate
        GIDSignIn.delegate = self
    }
}

extension GoogleSignInService: GIDSignInDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            if (error as NSError).code == GIDSignInErrorCode.hasNoAuthInKeychain.rawValue {
                logService.log("The user has not signed in before or they have since signed out.")
            } else {
                logService.log("\(error.localizedDescription)")
            }
            delegate?.failedSignIn()
            return
        } else if let user = user {
            delegate?.didSignIn(signInService: self, user: user)
        } else {
            logService.log("GoogleSignInService#sign(signIn:didSignInFor:withError could not handle result.")
        }
    }
}
