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
    
    typealias Dependencies = HasApplicationDependency & HasUserDependency & HasGmailServiceDependency & HasLogServiceDependency
    
    let applicationInteractor: ApplicationInteractable
    let markAsReadService: MarkAsReadService
    let unreadMailService: UnreadMailService
    let user: GIDGoogleUser
    
    private lazy var unreadMailView: UnreadMailView = {
        let view = UnreadMailView()
        view.configure(for: .loading)
        return view
    }()
    
    private lazy var markAsReadButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Mark all mail read", for: .normal)
        button.addTarget(self, action: #selector(markAsRead), for: .touchUpInside)
        return button
    }()
    
    private lazy var logoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Logout", for: .normal)
        button.addTarget(self, action: #selector(logout), for: .touchUpInside)
        return button
    }()
    
    // Set by an application shortcut to trigger a mark as read operation
    private var isMarkAsReadJobEnqueued: Bool = false
    
    init(dependencies: Dependencies) {
        applicationInteractor = dependencies.applicationInteractor
        markAsReadService = MarkAsReadService(dependencies: dependencies)
        unreadMailService = UnreadMailService(dependencies: dependencies)
        user = dependencies.GIDGoogleUser
        super.init(nibName: nil, bundle: nil)

        markAsReadService.delegate = self
        unreadMailView.delegate = self
        unreadMailService.delegate = self
        
        registerObservers()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .gmSystemBackground
        
        setUpLayout()
    
        unreadMailService.fetchUnreadMail()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        handleEnqueuedJobs()
    }
    
    @objc func markAsRead() {
        markAsReadService.batchMarkAsRead()
    }
    
    @objc func logout() {
        applicationInteractor.logout()
    }
    
    func enqueueMarkAsReadJob() {
        isMarkAsReadJobEnqueued = true
    }
    
    private func setUpLayout() {
        view.addSubview(unreadMailView)
        view.addSubview(markAsReadButton)
        view.addSubview(logoutButton)
        
        unreadMailView.topAnchor == view.verticalAnchors.first + 60
        unreadMailView.heightAnchor == 60
        unreadMailView.horizontalAnchors == view.horizontalAnchors + 20
        
        markAsReadButton.centerAnchors == view.centerAnchors
        
        logoutButton.bottomAnchor == view.bottomAnchor - 60
        logoutButton.centerXAnchor == view.centerXAnchor
        logoutButton.sizeAnchors == CGSize(width: 100, height: 40)
    }
    
    @objc private func handleEnqueuedJobs() {
        if isMarkAsReadJobEnqueued {
            isMarkAsReadJobEnqueued = false
            markAsRead()
        }
    }
    
    private func registerObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleEnqueuedJobs), name: UIApplication.willEnterForegroundNotification, object: nil)
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

    func didFail(service: MarkAsReadService, error: MarkAsReadServiceError) {
        let alertController = UIAlertController(
            title: "Operation failed",
            message: error.errorDescription,
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
