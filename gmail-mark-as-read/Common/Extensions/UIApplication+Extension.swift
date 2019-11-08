//
//  UIApplication+Extension.swift
//  gmail-mark-as-read
//
//  Created by Jon on 11/7/19.
//  Copyright © 2019 Product Corp. All rights reserved.
//

import UIKit

extension UIApplication {
    public static func setRootView(
        _ viewController: UIViewController,
        options: UIView.AnimationOptions = .transitionCrossDissolve,
        animated: Bool = true,
        duration: TimeInterval = 0.5,
        completion: (() -> Void)? = nil) {
        
        guard let keyWindow = UIApplication.shared.keyWindow else {
            return
        }
        
        guard animated else {
            keyWindow.rootViewController = viewController
            return
        }
        
        let animations: () -> Void = {
            let previousAnimationsEnabled = UIView.areAnimationsEnabled
            UIView.setAnimationsEnabled(false)
            keyWindow.rootViewController = viewController
            UIView.setAnimationsEnabled(previousAnimationsEnabled)
        }
        
        UIView.transition(
            with: keyWindow,
            duration: duration,
            options: options,
            animations: animations,
            completion: { _ in completion?() }
        )
    }
}
