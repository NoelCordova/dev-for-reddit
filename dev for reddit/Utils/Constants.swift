//
//  Constants.swift
//  dev for reddit
//
//  Created by Noel Espino Córdova on 04/08/20.
//  Copyright © 2020 slingercode. All rights reserved.
//

// swiftlint:disable type_name identifier_name

import Foundation

struct K {

    static var REDDIT_CLIENT_ID: String {
        if let envFilePath = Bundle.main.path(forResource: "env", ofType: "plist") {
            if let keys: NSDictionary = NSDictionary.init(contentsOfFile: envFilePath) {
                // swiftlint:disable:next force_cast
                return keys["REDDIT_CLIENT_ID"] as! String
            } else {
                return ""
            }
        } else {
            return ""
        }
    }

    static let REDIRECT_URI = "devforreddit://redirect"

    // UserDefaults
    static let UD_TOKEN = "TOKEN"
    static let UD_REFRESH_TOKEN = "REFRESH_TOKEN"
    static let UD_TOKEN_DATE = "TOKEN_DATE"
    static let UD_URL_STATE = "URL_STATE"

    // Identifiers
    static let postCellIdentifier = "PostCell"

    // Files
    static let postCell = "PostCell"

}
