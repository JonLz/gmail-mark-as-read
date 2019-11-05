//
//  UnreadMailView.swift
//  gmail-mark-as-read
//
//  Created by Jon on 11/5/19.
//  Copyright © 2019 Product Corp. All rights reserved.
//

import Anchorage

final class UnreadMailView: UIView {
    
    struct ViewState {
        let isErrorHidden: Bool
        let isLoaderHidden: Bool
        let isUnreadMailHidden: Bool
        
        let errorDescription: String
        let unreadMailCount: Int
        
        init(isErrorHidden: Bool = true,
             isLoaderHidden: Bool = true,
             isUnreadMailHidden: Bool = true,
             errorDescription: String = "",
             unreadMailCount: Int = 0)
        {
            self.isErrorHidden = isErrorHidden
            self.isLoaderHidden = isLoaderHidden
            self.isUnreadMailHidden = isUnreadMailHidden
            self.errorDescription = errorDescription
            self.unreadMailCount = unreadMailCount
        }
        
        static func error(errorDescription: String) -> ViewState {
            return ViewState(isErrorHidden: false, errorDescription: errorDescription)
        }
        
        static let loading = ViewState(isLoaderHidden: false)
        
        static func loaded(unreadMailCount: Int) -> ViewState {
            return ViewState(isUnreadMailHidden: false, unreadMailCount: unreadMailCount)
        }
    }
    
    private let errorLabel = UILabel()
    private let loader = UIActivityIndicatorView(style: .gray)
    private let unreadMailLabel = UILabel()
    
    init() {
        super.init(frame: .zero)
        setUpLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    func configure(for viewState: ViewState) {
        errorLabel.isHidden = viewState.isErrorHidden
        loader.isHidden = viewState.isLoaderHidden
        unreadMailLabel.isHidden = viewState.isUnreadMailHidden
        
        errorLabel.text = viewState.errorDescription
        unreadMailLabel.text = "Unread mail count: \(viewState.unreadMailCount)"
    }
    
    private func setUpLayout() {
        errorLabel.edgeAnchors == edgeAnchors
        loader.centerAnchors == centerAnchors
        unreadMailLabel.edgeAnchors == edgeAnchors
    }
}
