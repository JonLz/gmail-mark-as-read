//
//  UIActivityIndicatorView+Extension.swift
//  gmail-mark-as-read
//
//  Created by Jon on 11/13/19.
//  Copyright © 2019 Product Corp. All rights reserved.
//

import UIKit

extension UIView {
    var systemLoaderStyle: UIActivityIndicatorView.Style {
        if #available(iOS 12, *) {
          switch traitCollection.userInterfaceStyle {
          case .dark:
            return .white
          default:
            return .gray
          }
        } else {
            return .gray
        }
    }
}
