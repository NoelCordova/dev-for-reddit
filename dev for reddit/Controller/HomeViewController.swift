//
//  HomeViewController.swift
//  dev for reddit
//
//  Created by Noel Espino Córdova on 05/08/20.
//  Copyright © 2020 slingercode. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    @IBOutlet weak var postsTableView: UITableView!

    var oauthManager = OAuthManager()
    var redditManager = RedditManager()

    var posts: [PostModel] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        oauthManager.delegate = self
        redditManager.delegate = self
        postsTableView.dataSource = self

        postsTableView.register(UINib(nibName: K.postCell, bundle: nil), forCellReuseIdentifier: K.postCellIdentifier)

        oauthManager.validateToken()
    }

}

// MARK: - OAuthManagerDelegate

extension HomeViewController: OAuthManagerDelegate {

    func didReciveToken(_ oauthManager: OAuthManager) {
        redditManager.getHotPost(from: "redditdev")
    }

    func didOAuthFailWithError(_ error: Error) {
        print("OAuth: \(error)")
    }

}

// MARK: - RedditManagerDelegate

extension HomeViewController: RedditManagerDelegate {

    func didRecievePosts(_ redditManager: RedditManager, posts: [PostModel]) {
        DispatchQueue.main.async {
            self.posts.append(contentsOf: posts)
            self.postsTableView.reloadData()
        }
    }

    func didRedditFailWithError(_ error: Error) {
        print("Reddit: \(error)")
    }

}

// MARK: - UITableViewDataSource

extension HomeViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // swiftlint:disable:next force_cast
        let cell = tableView.dequeueReusableCell(withIdentifier: K.postCellIdentifier, for: indexPath) as! PostCell
        cell.subredditLabel.text = posts[indexPath.row].prefixedSubreddit
        cell.postLabel.text = posts[indexPath.row].title

        return cell
    }

}
