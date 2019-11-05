//
//  UnreadMailService.swift
//  gmail-mark-as-read
//
//  Created by Jon on 11/5/19.
//  Copyright © 2019 Product Corp. All rights reserved.
//

import GoogleAPIClientForREST.GTLRGmailService
import GoogleSignIn

protocol UnreadMailServiceDelegate: class {
    func didComplete(service: UnreadMailService, unreadMailCount: Int)
    func didFail(service: UnreadMailService)
}

final class UnreadMailService {
    
    typealias Dependencies = HasUserDependency & HasGmailServiceDependency
    
    weak var delegate: UnreadMailServiceDelegate?
    let user: GIDGoogleUser
    let service: GTLRService
    
    init(dependencies: Dependencies) {
        user = dependencies.GIDGoogleUser
        service = dependencies.gmailService
    }
    
    func fetchUnreadMail() {
        let query = GTLRGmailQuery_UsersLabelsGet.query(withUserId: user.userID, identifier: "UNREAD")
        _ = service.executeQuery(query) { [weak self] (ticket, responseObject, error) in
            guard let self = self else {
                return
            }
            
            if let error = error {
                print("UnreadMailService error:\(error.localizedDescription)")
                self.delegate?.didFail(service: self)
            } else if let label = responseObject as? GTLRGmail_Label,
                let unreadMailCount = label.messagesUnread?.intValue {
                self.delegate?.didComplete(service: self, unreadMailCount: unreadMailCount)
            } else {
                print("UnreadMailService could not process ticket:\(ticket.description) responseObject:\(responseObject.debugDescription)")
            }
        }
    }
}
