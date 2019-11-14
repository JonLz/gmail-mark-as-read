//
//  ApplicationCoordinator.swift
//  gmail-mark-as-read
//
//  Created by Jon Lazar on 11/2/19.
//  Copyright © 2019 Product Corp. All rights reserved.
//

import Anchorage
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

struct ApplicationDependency: HasGmailServiceDependency, HasLogServiceDependency, HasSignInServiceDependency {
    let gmailService: GTLRService
    let logService: LogServicing
    let signInService: GoogleSignInService
    
    static let make: ApplicationDependency = {
        struct LogContainer: HasLogServiceDependency {
            let logService: LogServicing
        }
        
        let logService = LogService()
        let logContainer = LogContainer(logService: logService)
        let signInService = GoogleSignInService(dependencies: logContainer)
        
        return ApplicationDependency(gmailService: GTLRGmailService(), logService: logService, signInService: signInService)
    }()
}

struct AuthenticatedDependency: HasApplicationDependency, HasUserDependency, HasGmailServiceDependency, HasLogServiceDependency {
    let applicationInteractor: ApplicationInteractable
    let GIDGoogleUser: GIDGoogleUser
    let gmailService: GTLRService
    let logService: LogServicing
}

final class ApplicationCoordinator {

    typealias Dependencies = HasGmailServiceDependency & HasLogServiceDependency & HasSignInServiceDependency
    
    weak var window: UIWindow?
    
    private lazy var loginViewController = LoginViewController(dependencies: dependencies)
    private var loggedInViewController: MarkAsReadViewController?
    private lazy var signInService = dependencies.signInService
    
    private let dependencies: Dependencies
    
    init(dependencies: Dependencies = ApplicationDependency.make, window: UIWindow?) {
        self.dependencies = dependencies
        self.window = window
    }
    
    func start() {
        UIApplication.setRootView(makeLoadingViewController())
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
    
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        switch ApplicationShortcut(rawValue: shortcutItem.type) {
        case .markAsRead:
            loggedInViewController?.enqueueMarkAsReadJob()
            completionHandler(true)
        default:
            completionHandler(false)
        }
    }
    
    func applicationShortcutItems() -> [UIApplicationShortcutItem] {
        if signInService.hasPreviousSignIn {
            return [ApplicationShortcut.markAsRead.shortcutItem]
        } else {
            return []
        }
    }
    
    private func setLoginState(_ loginState: LoggedInState) {
        switch loginState {
        case .loggedIn(let user):
            let loggedInViewController = makeLoggedInViewController(user: user)
            self.loggedInViewController = loggedInViewController
            UIApplication.setRootView(loggedInViewController)
        case .loggedOut:
            signInService.logout()
            UIApplication.setRootView(loginViewController)
        }
    }
    
    private func makeLoadingViewController() -> UIViewController {
        let loadingViewController = UIViewController()
        loadingViewController.view.backgroundColor = signInService.hasPreviousSignIn ? .gmSystemBackground : .white
        
        let spinner = UIActivityIndicatorView(style: loadingViewController.view.systemLoaderStyle)
        spinner.startAnimating()
        loadingViewController.view.addSubview(spinner)
        spinner.centerAnchors == loadingViewController.view.centerAnchors
        
        return loadingViewController
    }
    
    private func makeLoggedInViewController(user: GIDGoogleUser) -> MarkAsReadViewController {
        let authenticatedDependency = AuthenticatedDependency(
            applicationInteractor: self,
            GIDGoogleUser: user,
            gmailService: dependencies.gmailService,
            logService: dependencies.logService
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
