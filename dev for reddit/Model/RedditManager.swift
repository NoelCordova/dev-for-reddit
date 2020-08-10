//
//  RedditManager.swift
//  dev for reddit
//
//  Created by Noel Espino Córdova on 04/08/20.
//  Copyright © 2020 slingercode. All rights reserved.
//

// swiftlint:disable identifier_name

import Foundation

protocol RedditManagerDelegate: class {

    func didUpdateUser(_ redditManager: RedditManager, user: UserModel)

    func didRedditFailWithError(_ error: Error)

}

struct RedditManager {

    weak var delegate: RedditManagerDelegate?

    private let reddit_url = "https://oauth.reddit.com/api/v1"
    private let reddit_me_url = "/me"

    private var token: String {
        return UserDefaults.standard.string(forKey: K.UD_TOKEN) ?? ""
    }

    func me() {
        let urlString = "\(reddit_url)\(reddit_me_url)"
        let url = URL(string: urlString)

        var request = URLRequest(url: url!)

        request.setValue("bearer \(token)", forHTTPHeaderField: "Authorization")

        let task = URLSession.shared.dataTask(with: request) { (data, _, error) in
            if error != nil {
                self.delegate?.didRedditFailWithError(error!)
                return
            }

            if let dataResponse = data {
                do {
                    let decoder = JSONDecoder()

                    let decodedData = try decoder.decode(UserData.self, from: dataResponse)

                    let name = decodedData.name
                    let image = decodedData.icon_img

                    let user = UserModel(name: name, icon_img: image)

                    self.delegate?.didUpdateUser(self, user: user)
                } catch {
                    self.delegate?.didRedditFailWithError(error)
                }
            }
        }

        task.resume()
    }

}
