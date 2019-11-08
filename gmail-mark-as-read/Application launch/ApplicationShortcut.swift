//
//  ApplicationShortcut.swift
//  gmail-mark-as-read
//
//  Created by Jon on 11/7/19.
//  Copyright © 2019 Product Corp. All rights reserved.
//

import UIKit

enum ApplicationShortcut: String {
    case markAsRead = "mark-as-read"
    
    var shortcutItem: UIApplicationShortcutItem {
        switch self {
        case .markAsRead:
            return UIApplicationShortcutItem(
                type: rawValue,
                localizedTitle: "Mark as read",
                localizedSubtitle: "Mark all unread mail read",
                icon: .init(type: .mail),
                userInfo: nil
            )
        }
    }
}
