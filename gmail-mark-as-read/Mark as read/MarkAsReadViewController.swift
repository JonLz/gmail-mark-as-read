//
//  MarkAsReadViewController.swift
//  gmail-mark-as-read
//
//  Created by Jon Lazar on 11/3/19.
//  Copyright © 2019 Product Corp. All rights reserved.
//

import Anchorage

final class MarkAsReadViewController: UIViewController {
    
    let applicationContext: ApplicationContext
    private lazy var logoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Logout", for: .normal)
        button.addTarget(self, action: #selector(logout), for: .touchUpInside)
        return button
    }()
    
    init(applicationContext: ApplicationContext) {
        self.applicationContext = applicationContext
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .blue
        
        setUpLayout()
    }
    
    @objc func logout() {
        applicationContext.interactor.logout()
    }
    
    private func setUpLayout() {
        view.addSubview(logoutButton)
        logoutButton.bottomAnchor == view.bottomAnchor - 60
        logoutButton.centerXAnchor == view.centerXAnchor
        logoutButton.sizeAnchors == CGSize(width: 100, height: 40)
    }
}
