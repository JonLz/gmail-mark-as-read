//
//  MarkAsReadViewController.swift
//  gmail-mark-as-read
//
//  Created by Jon Lazar on 11/3/19.
//  Copyright © 2019 Product Corp. All rights reserved.
//

import Anchorage
import GoogleSignIn

final class MarkAsReadViewController: UIViewController {
    
    typealias Dependencies = HasApplicationDependency & HasUserDependency & HasGmailServiceDependency
    
    let applicationInteractor: ApplicationInteractable
    let markAsReadService: MarkAsReadService
    let unreadMailService: UnreadMailService
    let user: GIDGoogleUser
    
    private lazy var unreadMailView: UnreadMailView = {
        let view = UnreadMailView()
        view.configure(for: .loading)
        return view
    }()
    
    private lazy var logoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Logout", for: .normal)
        button.addTarget(self, action: #selector(logout), for: .touchUpInside)
        return button
    }()
    
    init(dependencies: Dependencies) {
        applicationInteractor = dependencies.applicationInteractor
        markAsReadService = MarkAsReadService(dependencies: dependencies)
        unreadMailService = UnreadMailService(dependencies: dependencies)
        user = dependencies.GIDGoogleUser
        super.init(nibName: nil, bundle: nil)

        markAsReadService.delegate = self
        unreadMailView.delegate = self
        unreadMailService.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setUpLayout()
    
        unreadMailService.fetchUnreadMail()
    }
    
    @objc func logout() {
        applicationInteractor.logout()
    }
    
    private func setUpLayout() {
        view.addSubview(unreadMailView)
        view.addSubview(logoutButton)
        
        unreadMailView.topAnchor == view.verticalAnchors.first + 60
        unreadMailView.heightAnchor == 60
        unreadMailView.horizontalAnchors == view.horizontalAnchors + 20
        
        logoutButton.bottomAnchor == view.bottomAnchor - 60
        logoutButton.centerXAnchor == view.centerXAnchor
        logoutButton.sizeAnchors == CGSize(width: 100, height: 40)
    }
}

extension MarkAsReadViewController: MarkAsReadServiceDelegate {
    func didComplete(service: MarkAsReadService) {
        unreadMailView.configure(for: .loading)
        unreadMailService.fetchUnreadMail()

        let alertController = UIAlertController(
            title: "Operation complete",
            message: "All unread mail marked as read. Enjoy inbox zero!",
            preferredStyle: .alert
        )
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }

    func didFail(service: MarkAsReadService) {
        let alertController = UIAlertController(
            title: "Operation failed",
            message: "Mail could not be marked as read. Please try again later.",
            preferredStyle: .alert
        )
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
}

extension MarkAsReadViewController: UnreadMailServiceDelegate {
    func didComplete(service: UnreadMailService, unreadMailCount: Int) {
        unreadMailView.configure(for: .loaded(unreadMailCount: unreadMailCount))
    }
    
    func didFail(service: UnreadMailService) {
        unreadMailView.configure(for: .error(errorDescription: "Could not retrieve mail"))
    }
}

extension MarkAsReadViewController: UnreadMailViewDelegate {
    func didTapReloadButton(view: UnreadMailView) {
        view.configure(for: .loading)
        unreadMailService.fetchUnreadMail()
    }
}
