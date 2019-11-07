//
//  LoginViewController.swift
//  gmail-mark-as-read
//
//  Created by Jon Lazar on 11/2/19.
//  Copyright © 2019 Product Corp. All rights reserved.
//

import Anchorage
import GoogleSignIn

final class LoginViewController: UIViewController {

    private let signInService: GoogleSignInService
    private let signInButton = GIDSignInButton()

    init(signInService: GoogleSignInService) {
        self.signInService = signInService
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if signInService.hasPreviousSignIn {
            signInService.restorePreviousSignIn()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .gmSystemBackground
        
        signInService.GIDSignIn.presentingViewController = self

        setUpLayout()
    }

    private func setUpLayout() {
        view.addSubview(signInButton)
        signInButton.horizontalAnchors == horizontalAnchors + 30
        signInButton.bottomAnchor == view.bottomAnchor - 60
    }
}
