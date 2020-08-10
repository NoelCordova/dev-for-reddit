//
//  AccessTokenData.swift
//  dev for reddit
//
//  Created by Noel Espino Córdova on 04/08/20.
//  Copyright © 2020 slingercode. All rights reserved.
//

// swiftlint:disable identifier_name

import Foundation

struct AccessTokenData: Codable {

    let access_token: String
    let refresh_token: String?

}
