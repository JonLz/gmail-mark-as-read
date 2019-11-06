//
//  Dependencies.swift
//  gmail-mark-as-read
//
//  Created by Jon on 11/5/19.
//  Copyright © 2019 Product Corp. All rights reserved.
//

import Foundation
import GoogleSignIn
import GoogleAPIClientForREST

/// Fulfillable dependencies
protocol HasApplicationDependency {
    var applicationInteractor: ApplicationInteractable { get }
}

protocol HasGmailServiceDependency {
    var gmailService: GTLRService { get }
}

protocol HasLogServiceDependency {
    var logService: LogServicing { get }
}

protocol HasUnreadMailServiceDependency {
    var unreadMailService: UnreadMailService { get }
}

protocol HasUserDependency {
    var GIDGoogleUser: GIDGoogleUser { get }
}
