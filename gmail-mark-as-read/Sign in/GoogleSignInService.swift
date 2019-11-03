//
//  GoogleSignInService.swift
//  gmail-mark-as-read
//
//  Created by Jon Lazar on 10/21/19.
//  Copyright © 2019 Product Corp. All rights reserved.
//

import Foundation
import GoogleSignIn

final class GoogleSignInService: NSObject {

    let GIDSignIn: GIDSignIn? = GoogleSignIn.GIDSignIn.sharedInstance()

    func start() {
        setUpGIDSignIn()
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        guard let GIDSignIn = GIDSignIn else {
            return false
        }

        return GIDSignIn.handle(url)
    }

    private func setUpGIDSignIn() {
        guard let GIDSignIn = GIDSignIn else {
            return
        }

        /// Client identifier
        let clientId = AppConfiguration().appConstants.googleSignInClientId
        GIDSignIn.clientID = clientId

        /// Scopes
        /// Requesting additional scopes: https://developers.google.com/identity/sign-in/ios/additional-scopes
        /// Gmail scopes: https://developers.google.com/gmail/api/auth/scopes
        let gmailLabelScope = "https://www.googleapis.com/auth/gmail.labels"
        let scopes = GIDSignIn.scopes + [gmailLabelScope]
        GIDSignIn.scopes = scopes

        /// Internal delegate
        GIDSignIn.delegate = self
    }
}

extension GoogleSignInService: GIDSignInDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
          if (error as NSError).code == GIDSignInErrorCode.hasNoAuthInKeychain.rawValue {
            print("The user has not signed in before or they have since signed out.")
          } else {
            print("\(error.localizedDescription)")
          }
          return
        }
        // Perform any operations on signed in user here.
        let userId = user.userID                  // For client-side use only!
        let idToken = user.authentication.idToken // Safe to send to the server
        let fullName = user.profile.name
        let givenName = user.profile.givenName
        let familyName = user.profile.familyName
        let email = user.profile.email
        // ...
    }
}
