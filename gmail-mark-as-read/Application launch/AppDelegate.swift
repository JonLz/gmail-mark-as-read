//
//  AppDelegate.swift
//  gmail-mark-as-read
//
//  Created by Jon Lazar on 10/21/19.
//  Copyright © 2019 Product Corp. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var applicationCoordinator = ApplicationCoordinator()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        applicationCoordinator.start()
        let vc = applicationCoordinator.makeRootViewController()
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = vc
        window?.makeKeyAndVisible()
        return true
    }

    @available(iOS 9.0, *)
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        return applicationCoordinator.application(app, open: url, options: options)
    }
}

