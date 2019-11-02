//
//  ApplicationCoordinator.swift
//  gmail-mark-as-read
//
//  Created by Jon Lazar on 11/2/19.
//  Copyright © 2019 Product Corp. All rights reserved.
//

import UIKit

final class ApplicationCoordinator {

    private let loginCoordinator = LoginCoordinator()

    func makeRootViewController() -> UIViewController {
        loginCoordinator.start()
        return loginCoordinator.loginViewController
    }

    func start() {

    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        return loginCoordinator.application(app, open: url, options: options)
    }
}
