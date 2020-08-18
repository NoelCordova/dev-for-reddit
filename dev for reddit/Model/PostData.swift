//
//  PostData.swift
//  dev for reddit
//
//  Created by Noel Espino Córdova on 18/08/20.
//  Copyright © 2020 slingercode. All rights reserved.
//

import Foundation

struct PostData: Codable {

    let data: PostBody

}

struct PostBody: Codable {

    let children: [PostChildren]

}

struct PostChildren: Codable {

    let data: PostChildrenData

}

struct PostChildrenData: Codable {

    let subreddit: String
    let title: String

}
