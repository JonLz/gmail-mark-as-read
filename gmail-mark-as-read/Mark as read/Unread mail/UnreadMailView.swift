//
//  UnreadMailView.swift
//  gmail-mark-as-read
//
//  Created by Jon on 11/5/19.
//  Copyright © 2019 Product Corp. All rights reserved.
//

import Anchorage

protocol UnreadMailViewDelegate: class {
    func didTapReloadButton(view: UnreadMailView)
}

final class UnreadMailView: UIView {
    
    struct ViewState {
        let isErrorHidden: Bool
        let isLoaderHidden: Bool
        let isUnreadMailHidden: Bool
        let isReloadButtonHidden: Bool
        
        let errorDescription: String
        let unreadMailCount: Int
        
        init(isErrorHidden: Bool = true,
             isLoaderHidden: Bool = true,
             isUnreadMailHidden: Bool = true,
             isReloadButtonHidden: Bool = true,
             errorDescription: String = "",
             unreadMailCount: Int = 0)
        {
            self.isErrorHidden = isErrorHidden
            self.isLoaderHidden = isLoaderHidden
            self.isUnreadMailHidden = isUnreadMailHidden
            self.isReloadButtonHidden = isReloadButtonHidden
            self.errorDescription = errorDescription
            self.unreadMailCount = unreadMailCount
        }
        
        static func error(errorDescription: String) -> ViewState {
            return ViewState(isErrorHidden: false, isReloadButtonHidden: false, errorDescription: errorDescription)
        }
        
        static let loading = ViewState(isLoaderHidden: false)
        
        static func loaded(unreadMailCount: Int) -> ViewState {
            return ViewState(isUnreadMailHidden: false, isReloadButtonHidden: false, unreadMailCount: unreadMailCount)
        }
    }
    
    weak var delegate: UnreadMailViewDelegate?
    private let errorLabel = UILabel()
    private let loader = UIActivityIndicatorView(style: .gray)
    
    private lazy var reloadButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Reload", for: .normal)
        button.addTarget(self, action: #selector(handleReload), for: .touchUpInside)
        button.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        return button
    }()
    
    private let unreadMailLabel = UILabel()
    
    init() {
        super.init(frame: .zero)
        setUpLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    @objc func handleReload() {
        delegate?.didTapReloadButton(view: self)
    }
    
    func configure(for viewState: ViewState) {
        errorLabel.isHidden = viewState.isErrorHidden
        loader.isHidden = viewState.isLoaderHidden
        reloadButton.isHidden = viewState.isReloadButtonHidden
        unreadMailLabel.isHidden = viewState.isUnreadMailHidden
        
        errorLabel.text = viewState.errorDescription
        unreadMailLabel.text = "Unread mail count: \(viewState.unreadMailCount)"
    }
    
    private func setUpLayout() {
        addSubview(errorLabel)
        addSubview(loader)
        addSubview(reloadButton)
        addSubview(unreadMailLabel)
        
        loader.centerAnchors == centerAnchors
        
        unreadMailLabel.verticalAnchors == verticalAnchors
        unreadMailLabel.leadingAnchor == leadingAnchor + 10
        unreadMailLabel.trailingAnchor == reloadButton.leadingAnchor - 10
        
        errorLabel.edgeAnchors == unreadMailLabel.edgeAnchors
        
        reloadButton.verticalAnchors == verticalAnchors
        reloadButton.trailingAnchor == trailingAnchor - 10
    }
}
