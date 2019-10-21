//
//  AppConfiguration.swift
//  gmail-mark-as-read
//
//  Created by Jon Lazar on 10/21/19.
//  Copyright © 2019 Product Corp. All rights reserved.
//

import Foundation

final class AppConfiguration {
    private enum ServiceKey {
        static let GoogleSignInClientId = bundledValue(for: "GOOGLE_SIGN_IN_CLIENT_ID")
    }

    let appConstants: AppConstants

    init() {
        appConstants = AppConstants(googleSignInClientId: AppConfiguration.ServiceKey.GoogleSignInClientId)
    }
}

private func bundledValue(for mainBundleInfoDictionaryKey: String) -> String {
    return Bundle.main.object(forInfoDictionaryKey: mainBundleInfoDictionaryKey) as! String
}
