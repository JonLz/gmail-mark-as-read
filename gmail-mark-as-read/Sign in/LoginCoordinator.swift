//
//  LoginCoordinator.swift
//  gmail-mark-as-read
//
//  Created by Jon Lazar on 11/2/19.
//  Copyright © 2019 Product Corp. All rights reserved.
//

import UIKit
import GoogleSignIn

protocol LoginCoordinatorDelegate: class {
    func didSignIn(coordinator: LoginCoordinator, user: GIDGoogleUser)
}

final class LoginCoordinator {

    weak var delegate: LoginCoordinatorDelegate?
    private let signInService = GoogleSignInService(dependencies: UnauthenticatedDependency.make)

    private(set) lazy var loginViewController: LoginViewController = {
        return LoginViewController(signInService: signInService)
    }()

    func start() {
        signInService.delegate = self
        signInService.start()
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        return signInService.application(app, open: url, options: options)
    }
}

extension LoginCoordinator: GoogleSignInServiceDelegate {
    func didSignIn(signInService: GoogleSignInService, user: GIDGoogleUser) {
        delegate?.didSignIn(coordinator: self, user: user)
    }
    
    func failedSignIn() {
        // no-op
    }
}
