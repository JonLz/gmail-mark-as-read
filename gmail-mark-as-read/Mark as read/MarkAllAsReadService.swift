//
//  MarkAllAsReadService.swift
//  gmail-mark-as-read
//
//  Created by Jon on 11/19/19.
//  Copyright © 2019 Product Corp. All rights reserved.
//

import GoogleAPIClientForREST.GTLRGmailService
import GoogleSignIn
import GTMSessionFetcher

protocol MarkAllAsReadServiceDelegate: class {
    func didComplete(service: MarkAllAsReadService, totalMarkedAsRead: Int)
    func didProgress(lastBatchMarkedCount: Int, totalMarkedAsRead: Int)
    func didFail(service: MarkAllAsReadService, error: MarkAllAsReadServiceError)
}

enum MarkAllAsReadServiceError: LocalizedError {
    case GTLRError(Error)
    case noUnreadMessages
    case unknownError
    
    var errorDescription: String? {
        switch self {
        case .GTLRError(let error):
            if let gtlrErrorMessage = GTLRErrorObject(foundationError: error).errorDescription {
                return gtlrErrorMessage
            } else {
                return MarkAllAsReadServiceError.unknownError.errorDescription
            }
        case .noUnreadMessages: return NSLocalizedString("No unread messages found.", comment: "")
        case .unknownError: return NSLocalizedString("Mail could not be marked as read. Please try again later.", comment: "")
        }
    }
}


/// Attempts to marks all messages as read in batches of 1000 messages at a time
final class MarkAllAsReadService {

    typealias Dependencies = HasUserDependency & HasGmailServiceDependency & HasLogServiceDependency

    weak var delegate: MarkAllAsReadServiceDelegate?
    
    private let logService: LogServicing
    private let service: GTLRService
    private let user: GIDGoogleUser
    private var markedAsReadCount: Int = 0
    
    private let maxIdsAllowedPerBatchModifyRequest: UInt = 1000
    
    init(dependencies: Dependencies) {
        logService = dependencies.logService
        service = dependencies.gmailService
        user = dependencies.GIDGoogleUser
        
        service.authorizer = user.authentication.fetcherAuthorizer()
    }

    func batchMarkAsRead() {
        markedAsReadCount = 0
        _batchMarkAsRead()
    }
    
    private func _batchMarkAsRead() {
        let singleBatchCompletion: (Result<Int, MarkAllAsReadServiceError>) -> () = { [weak self] result in
            switch result {
            case .success(let count):
                self?.markedAsReadCount += count
                self?.delegate?.didProgress(lastBatchMarkedCount: count, totalMarkedAsRead: self?.markedAsReadCount ?? 0)
                self?._batchMarkAsRead()
            case .failure(let error):
                self?.delegate?.didFail(service: self!, error: error)
            }
        }

        return listUnreadMessages() { [weak self] result in
            switch result {
            case .success(let messages):
                if messages.count == 0 {
                    self?.delegate?.didComplete(service: self!, totalMarkedAsRead: self?.markedAsReadCount ?? 0)
                } else {
                    self?.batchMarkMessagesAsRead(messages: messages, completion: singleBatchCompletion)
                }
            case .failure(let error):
                self?.delegate?.didFail(service: self!, error: error)
            }
        }
    }

    private func batchMarkMessagesAsRead(messages: [GTLRGmail_Message], completion: @escaping (Result<Int, MarkAllAsReadServiceError>) -> ()) {
        let batchRequest = GTLRGmail_BatchModifyMessagesRequest()
        batchRequest.removeLabelIds = ["UNREAD"]
        batchRequest.ids = messages.compactMap { $0.identifier }
        let query = GTLRGmailQuery_UsersMessagesBatchModify.query(withObject: batchRequest, userId: user.userID)

        _ = service.executeQuery(query) { [weak self] (ticket, responseObject, error) in
            if let error = error {
                self?.logService.log("MarkAllAsReadService query:\(query) error:\(error.localizedDescription)")
                completion(.failure(.GTLRError(error)))
            } else if ticket.statusCode.isSuccessfulHTTPStatusCode {
                completion(.success(messages.count))
            } else {
                self?.logService.log("MarkAllAsReadService could not process query:\(query) ticket:\(ticket.description) responseObject:\(responseObject.debugDescription)")
                completion(.failure(.unknownError))
            }
        }
    }

    private func listUnreadMessages(_ completion: @escaping (Result<[GTLRGmail_Message], MarkAllAsReadServiceError>) -> ()) {
        let query = GTLRGmailQuery_UsersMessagesList.query(withUserId: user.userID)
        query.labelIds = ["UNREAD"]
        query.maxResults = maxIdsAllowedPerBatchModifyRequest
        query.executionParameters.shouldFetchNextPages = true
        
        _ = service.executeQuery(query) { [weak self] (ticket, responseObject, error) in
            if let error = error {
                self?.logService.log("MarkAllAsReadService query:\(query) error:\(error.localizedDescription)")
                completion(.failure(.GTLRError(error)))
            } else if let response = responseObject as? GTLRGmail_ListMessagesResponse {
                if let messages = response.messages {
                    completion(.success(messages))
                } else {
                    completion(.success([]))
                }
            } else {
                self?.logService.log("MarkAllAsReadService could not process query:\(query) ticket:\(ticket.description) responseObject:\(responseObject.debugDescription)")
                completion(.failure(.unknownError))
            }
        }
    }
}
