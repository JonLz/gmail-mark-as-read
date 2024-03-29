//
//  UnreadMailService.swift
//  gmail-mark-as-read
//
//  Created by Jon on 11/5/19.
//  Copyright © 2019 Product Corp. All rights reserved.
//

import GoogleAPIClientForREST.GTLRGmailService
import GoogleSignIn
import GTMSessionFetcher

protocol UnreadMailServiceDelegate: class {
    func didComplete(service: UnreadMailService, unreadMailCount: Int)
    func didFail(service: UnreadMailService)
}

final class UnreadMailService {
    
    typealias Dependencies = HasUserDependency & HasGmailServiceDependency & HasLogServiceDependency
    
    weak var delegate: UnreadMailServiceDelegate?
    
    private let logService: LogServicing
    private let service: GTLRService
    private let user: GIDGoogleUser
    
    init(dependencies: Dependencies) {
        logService = dependencies.logService
        service = dependencies.gmailService
        user = dependencies.GIDGoogleUser
        
        service.authorizer = user.authentication.fetcherAuthorizer()
    }
    
    func fetchUnreadMail() {
        let query = GTLRGmailQuery_UsersLabelsGet.query(withUserId: user.userID, identifier: "UNREAD")
        _ = service.executeQuery(query) { [weak self] (ticket, responseObject, error) in
            if let error = error {
                self?.logService.log("UnreadMailService query:\(query) error:\(error.localizedDescription)")
                self?.delegate?.didFail(service: self!)
            } else if let label = responseObject as? GTLRGmail_Label,
                let unreadMailCount = label.messagesUnread?.intValue {
                self?.delegate?.didComplete(service: self!, unreadMailCount: unreadMailCount)
            } else {
                self?.logService.log("UnreadMailService could not process query:\(query) ticket:\(ticket.description) responseObject:\(responseObject.debugDescription)")
            }
        }
    }
}
