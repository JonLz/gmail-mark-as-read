//
//  LoginCoordinator.swift
//  gmail-mark-as-read
//
//  Created by Jon Lazar on 11/2/19.
//  Copyright © 2019 Product Corp. All rights reserved.
//

import UIKit

final class LoginCoordinator {

    private let signInService = GoogleSignInService()

    private(set) lazy var loginViewController: LoginViewController = {
        return LoginViewController(signInService: signInService)
    }()

    func start() {
        signInService.start()
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        return signInService.application(app, open: url, options: options)
    }
}
