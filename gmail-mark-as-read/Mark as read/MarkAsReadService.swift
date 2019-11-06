//
//  MarkAsReadService.swift
//  gmail-mark-as-read
//
//  Created by Jon Lazar on 11/5/19.
//  Copyright © 2019 Product Corp. All rights reserved.
//

import GoogleAPIClientForREST.GTLRGmailService
import GoogleSignIn
import GTMSessionFetcher

protocol MarkAsReadServiceDelegate: class {
    func didComplete(service: MarkAsReadService)
    func didFail(service: MarkAsReadService)
}

struct NilError: CustomNSError { }

final class MarkAsReadService {

    typealias Dependencies = HasUserDependency & HasGmailServiceDependency

    weak var delegate: MarkAsReadServiceDelegate?
    let user: GIDGoogleUser
    let service: GTLRService

    init(dependencies: Dependencies) {
        user = dependencies.GIDGoogleUser
        service = dependencies.gmailService
        service.authorizer = user.authentication.fetcherAuthorizer()
    }

    func batchMarkAsRead() {
        let completion: (Result<Void, Error>) -> () = { [weak self] result in
            switch result {
            case .success:
                self?.delegate?.didComplete(service: self!)
            case .failure:
                self?.delegate?.didFail(service: self!)
            }
        }

        listUnreadMessages() { [weak self] result in
            switch result {
            case .success(let messages):
                self?.batchMarkMessagesAsRead(messages: messages, completion: completion)
            case .failure:
                self?.delegate?.didFail(service: self!)
            }
        }
    }

    private func batchMarkMessagesAsRead(messages: [GTLRGmail_Message], completion: @escaping (Result<Void, Error>) -> ()) {
        let batchRequest = GTLRGmail_BatchModifyMessagesRequest()
        batchRequest.removeLabelIds = ["UNREAD"]
        let query = GTLRGmailQuery_UsersMessagesBatchModify.query(withObject: batchRequest, userId: user.userID)

        _ = service.executeQuery(query) { (ticket, responseObject, error) in
            if let error = error {
                print("MarkAsReadService query:\(query) error:\(error.localizedDescription)")
                completion(.failure(error))
            } else if ticket.statusCode.isSuccessfulHTTPStatusCode {
                completion(.success(()))
            } else {
                print("MarkAsReadService could not process query:\(query) ticket:\(ticket.description) responseObject:\(responseObject.debugDescription)")
                completion(.failure(NilError()))
            }
        }
    }

    private func listUnreadMessages(_ completion: @escaping (Result<[GTLRGmail_Message], Error>) -> ()) {
        let query = GTLRGmailQuery_UsersMessagesList.query(withUserId: user.userID)
        query.labelIds = ["UNREAD"]

        _ = service.executeQuery(query) { (ticket, responseObject, error) in
            if let error = error {
                print("MarkAsReadService query:\(query) error:\(error.localizedDescription)")
                completion(.failure(error))
            } else if let messages = responseObject as? [GTLRGmail_Message] {
                completion(.success(messages))
            } else {
                print("MarkAsReadService could not process query:\(query) ticket:\(ticket.description) responseObject:\(responseObject.debugDescription)")
                completion(.failure(NilError()))
            }
        }
    }
}
