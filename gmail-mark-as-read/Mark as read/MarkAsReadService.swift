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
    func didFail(service: MarkAsReadService, error: MarkAsReadServiceError)
}

enum MarkAsReadServiceError: LocalizedError {
    case GTLRError(Error)
    case noUnreadMessages
    case unknownError
    
    var errorDescription: String? {
        switch self {
        case .GTLRError(let error):
            if let gtlrErrorMessage = GTLRErrorObject(foundationError: error).errorDescription {
                return gtlrErrorMessage
            } else {
                return MarkAsReadServiceError.unknownError.errorDescription
            }
        case .noUnreadMessages: return NSLocalizedString("No unread messages found.", comment: "")
        case .unknownError: return NSLocalizedString("Mail could not be marked as read. Please try again later.", comment: "")
        }
    }
}

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
        let completion: (Result<Void, MarkAsReadServiceError>) -> () = { [weak self] result in
            switch result {
            case .success:
                self?.delegate?.didComplete(service: self!)
            case .failure(let error):
                self?.delegate?.didFail(service: self!, error: error)
            }
        }

        listUnreadMessages() { [weak self] result in
            switch result {
            case .success(let messages):
                self?.batchMarkMessagesAsRead(messages: messages, completion: completion)
            case .failure(let error):
                self?.delegate?.didFail(service: self!, error: error)
            }
        }
    }

    private func batchMarkMessagesAsRead(messages: [GTLRGmail_Message], completion: @escaping (Result<Void, MarkAsReadServiceError>) -> ()) {
        let batchRequest = GTLRGmail_BatchModifyMessagesRequest()
        batchRequest.removeLabelIds = ["UNREAD"]
        batchRequest.ids = messages.compactMap { $0.identifier }
        let query = GTLRGmailQuery_UsersMessagesBatchModify.query(withObject: batchRequest, userId: user.userID)

        _ = service.executeQuery(query) { (ticket, responseObject, error) in
            if let error = error {
                print("MarkAsReadService query:\(query) error:\(error.localizedDescription)")
                completion(.failure(.GTLRError(error)))
            } else if ticket.statusCode.isSuccessfulHTTPStatusCode {
                completion(.success(()))
            } else {
                print("MarkAsReadService could not process query:\(query) ticket:\(ticket.description) responseObject:\(responseObject.debugDescription)")
                completion(.failure(.unknownError))
            }
        }
    }

    private func listUnreadMessages(_ completion: @escaping (Result<[GTLRGmail_Message], MarkAsReadServiceError>) -> ()) {
        let query = GTLRGmailQuery_UsersMessagesList.query(withUserId: user.userID)
        query.labelIds = ["UNREAD"]
        
        _ = service.executeQuery(query) { (ticket, responseObject, error) in
            if let error = error {
                print("MarkAsReadService query:\(query) error:\(error.localizedDescription)")
                completion(.failure(.GTLRError(error)))
            } else if let response = responseObject as? GTLRGmail_ListMessagesResponse {
                if let messages = response.messages {
                    completion(.success(messages))
                } else {
                    completion(.failure(.noUnreadMessages))
                }
            } else {
                print("MarkAsReadService could not process query:\(query) ticket:\(ticket.description) responseObject:\(responseObject.debugDescription)")
                completion(.failure(.unknownError))
            }
        }
    }
}
