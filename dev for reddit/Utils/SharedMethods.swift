//
//  SharedMethods.swift
//  dev for reddit
//
//  Created by Noel Espino Córdova on 09/08/20.
//  Copyright © 2020 slingercode. All rights reserved.
//

// swiftlint:disable type_name

import Foundation

struct SM {

    static func generate_basic_authorization(with username: String, and password: String) -> String {
        return String(format: "%@:%@", username, password).data(using: String.Encoding.utf8)!.base64EncodedString()
    }

    static func generate_x_www_form_urlencoded(with params: [String: String]) -> Data {
        return params.map({String(format: "%@=%@", $0, $1)}).joined(separator: "&").data(using: .utf8)!
    }

}
