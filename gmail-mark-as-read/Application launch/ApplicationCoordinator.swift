//
//  ApplicationCoordinator.swift
//  gmail-mark-as-read
//
//  Created by Jon Lazar on 11/2/19.
//  Copyright © 2019 Product Corp. All rights reserved.
//

import UIKit
import GoogleSignIn
import GoogleAPIClientForREST

/// Invocable methods for child contexts
protocol ApplicationInteractable {
    func logout()
}

struct AppDependency: HasApplicationDependency, HasUserDependency, HasGmailServiceDependency {
    let applicationInteractor: ApplicationInteractable
    let GIDGoogleUser: GIDGoogleUser
    let gmailService: GTLRService
}

final class ApplicationCoordinator {

    weak var window: UIWindow?
    private let loginCoordinator = LoginCoordinator()
    private let signInService = GoogleSignInService()
    
    init(window: UIWindow?) {
        self.window = window
    }
    
    func start() {
        window?.rootViewController = makeLoginViewController()
        signInService.delegate = self
        signInService.start()
        signInService.restorePreviousSignIn()
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        return loginCoordinator.application(app, open: url, options: options)
    }

    private func makeLoggedInViewController(user: GIDGoogleUser) -> UIViewController {
        let appDependency = AppDependency(
            applicationInteractor: self,
            GIDGoogleUser: user,
            gmailService: GTLRGmailService()
        )
        return MarkAsReadViewController(dependencies: appDependency)
    }
    
    private func makeLoginViewController() -> UIViewController {
        loginCoordinator.start()
        loginCoordinator.delegate = self
        return loginCoordinator.loginViewController
    }
}

// MARK: - GoogleSignInDelegate

extension ApplicationCoordinator: GoogleSignInServiceDelegate  {
    func didSignIn(signInService: GoogleSignInService, user: GIDGoogleUser) {
        let loggedInViewController = makeLoggedInViewController(user: user)
        window?.rootViewController?.present(loggedInViewController, animated: false, completion: nil)
    }
    
    func failedSignIn() {
        // no-op
    }
}

// MARK: - LoginCoordinatorDelegate

extension ApplicationCoordinator: LoginCoordinatorDelegate {
    func didSignIn(coordinator: LoginCoordinator, user: GIDGoogleUser) {
        let loggedInViewController = makeLoggedInViewController(user: user)
        window?.rootViewController?.present(loggedInViewController, animated: false, completion: nil)
    }
}

// MARK: - ApplicationInteractable

extension ApplicationCoordinator: ApplicationInteractable {
    func logout() {
        signInService.logout()
        window?.rootViewController?.dismiss(animated: true, completion: nil)
    }
}
