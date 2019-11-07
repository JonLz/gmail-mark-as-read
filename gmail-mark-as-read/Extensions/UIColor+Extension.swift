//
//  UIColor+Extension.swift
//  gmail-mark-as-read
//
//  Created by Jon on 11/6/19.
//  Copyright © 2019 Product Corp. All rights reserved.
//

import UIKit

extension UIColor {
    static let gmLabel: UIColor = {
        if #available(iOS 13, *) {
            return UIColor.label
        }
        else { return UIColor.black }
    }()
    
    static let gmSystemBackground: UIColor = {
        if #available(iOS 13, *) {
            return UIColor.systemBackground
        }
        else { return UIColor.white }
    }()
}
