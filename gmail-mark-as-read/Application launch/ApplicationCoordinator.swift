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

enum LoggedInState {
    case loggedIn(user: GIDGoogleUser)
    case loggedOut
}

struct AuthenticatedDependency: HasApplicationDependency, HasUserDependency, HasGmailServiceDependency, HasLogServiceDependency {
    let applicationInteractor: ApplicationInteractable
    let GIDGoogleUser: GIDGoogleUser
    let gmailService: GTLRService
    let logService: LogServicing
}

struct UnauthenticatedDependency: HasLogServiceDependency, HasSignInServiceDependency {
    let logService: LogServicing
    let signInService: GoogleSignInService
    
    static let make: UnauthenticatedDependency = {
        struct LogContainer: HasLogServiceDependency {
            let logService: LogServicing
        }
        
        let logService = LogService()
        let logContainer = LogContainer(logService: logService)
        let signInService = GoogleSignInService(dependencies: logContainer)
        
        return UnauthenticatedDependency(logService: logService, signInService: signInService)
    }()
}

final class ApplicationCoordinator {

    weak var window: UIWindow?
    
    private lazy var loginViewController = LoginViewController(dependencies: unauthenticatedDependency)
    private lazy var signInService = unauthenticatedDependency.signInService
    
    private let unauthenticatedDependency = UnauthenticatedDependency.make
    
    init(window: UIWindow?) {
        self.window = window
    }
    
    func start() {
        signInService.delegate = self
        signInService.start()
        
        if signInService.hasPreviousSignIn {
            signInService.restorePreviousSignIn()
        } else {
            setLoginState(.loggedOut)
        }
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        return signInService.application(app, open: url, options: options)
    }
    
    private func setLoginState(_ loginState: LoggedInState) {
        switch loginState {
        case .loggedIn(let user):
            UIApplication.setRootView(makeLoggedInViewController(user: user))
        case .loggedOut:
            signInService.logout()
            UIApplication.setRootView(loginViewController)
        }
    }
    
    private func makeLoggedInViewController(user: GIDGoogleUser) -> UIViewController {
        let authenticatedDependency = AuthenticatedDependency(
            applicationInteractor: self,
            GIDGoogleUser: user,
            gmailService: GTLRGmailService(),
            logService: LogService()
        )
        return MarkAsReadViewController(dependencies: authenticatedDependency)
    }
}

// MARK: - GoogleSignInServiceDelegate

extension ApplicationCoordinator: GoogleSignInServiceDelegate {
    func didSignIn(signInService: GoogleSignInService, user: GIDGoogleUser) {
        setLoginState(.loggedIn(user: user))
    }
    
    func failedSignIn() {
        setLoginState(.loggedOut)
    }
}

// MARK: - ApplicationInteractable

extension ApplicationCoordinator: ApplicationInteractable {
    func logout() {
        setLoginState(.loggedOut)
    }
}
