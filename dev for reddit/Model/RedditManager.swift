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

    func didRecieveUser(_ redditManager: RedditManager, user: UserModel)

    func didRecievePosts(_ redditManager: RedditManager, posts: [PostModel])

    func didRedditFailWithError(_ error: Error)

}

struct RedditManager {

    weak var delegate: RedditManagerDelegate?

    private let reddit_url = "https://oauth.reddit.com"
    private let reddit_me_url = "/api/v1/me"
    private let reddit_hot_subreddit = "/r/${SUBREDDIT}/hot"

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

                    self.delegate?.didRecieveUser(self, user: user)
                } catch {
                    self.delegate?.didRedditFailWithError(error)
                }
            }
        }

        task.resume()
    }

    func getHotPost(from subreddit: String) {
        let urlString = "\(reddit_url)\(reddit_hot_subreddit)".replacingOccurrences(of: "${SUBREDDIT}", with: subreddit)
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

                    let decodedData = try decoder.decode(PostData.self, from: dataResponse)

                    var posts: [PostModel] = []

                    for postChildren in decodedData.data.children {
                        let subreddit = postChildren.data.subreddit
                        let prefixedSubreddit = postChildren.data.subreddit_name_prefixed
                        let title = postChildren.data.title

                        let post = PostModel(subreddit: subreddit, prefixedSubreddit: prefixedSubreddit, title: title)

                        posts.append(post)
                    }

                    self.delegate?.didRecievePosts(self, posts: posts)
                } catch {
                    self.delegate?.didRedditFailWithError(error)
                }
            }
        }

        task.resume()
    }

}
