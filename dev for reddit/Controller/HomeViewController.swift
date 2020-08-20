//
//  HomeViewController.swift
//  dev for reddit
//
//  Created by Noel Espino Córdova on 05/08/20.
//  Copyright © 2020 slingercode. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    @IBOutlet weak var tokenTextField: UITextField!
    @IBOutlet weak var postTableView: UITableView!

    var oauthManager = OAuthManager()
    var redditManager = RedditManager()

    var posts: [PostModel] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        oauthManager.delegate = self
        redditManager.delegate = self
        postTableView.dataSource = self

        postTableView.register(UINib(nibName: K.postCell, bundle: nil), forCellReuseIdentifier: K.postCellIdentifier)

        oauthManager.validateToken()
    }

}

// MARK: - OAuthManagerDelegate

extension HomeViewController: OAuthManagerDelegate {

    @IBAction func logOutPressed(_ sender: UIBarButtonItem) {
        oauthManager.closeSession()
    }

    func didReciveToken(_ oauthManager: OAuthManager) {
        redditManager.me()
        redditManager.getHotPost(from: "redditdev")
    }

    func didRemoveToken(_ oauthManager: OAuthManager) {
        DispatchQueue.main.async {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let loginNavController = storyboard.instantiateViewController(identifier: "LoginNavController")

            // This is to get the SceneDelegate custom changeRootViewController method
            (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?
                .changeRootViewController(loginNavController, animated: true)
        }
    }

    func didOAuthFailWithError(_ error: Error) {
        print("OAuth: \(error)")
    }

}

// MARK: - RedditManagerDelegate

extension HomeViewController: RedditManagerDelegate {

    func didRecieveUser(_ redditManager: RedditManager, user: UserModel) {
        DispatchQueue.main.async {
            self.title = user.name
            self.tokenTextField.text = UserDefaults.standard.string(forKey: K.UD_TOKEN)!

//            let url = URL(string: user.icon_img)
//            let data = try? Data(contentsOf: url!)
//            self.profileImageBarButtonItem.image = UIImage(data: data!)
        }
    }

    func didRecievePosts(_ redditManager: RedditManager, posts: [PostModel]) {
        DispatchQueue.main.async {
            self.posts.append(contentsOf: posts)
            self.postTableView.reloadData()
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
