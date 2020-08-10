//
//  ViewController2.swift
//  dev for reddit
//
//  Created by Noel Espino Córdova on 05/08/20.
//  Copyright © 2020 slingercode. All rights reserved.
//

import UIKit

class ViewController2: UIViewController {

    @IBOutlet weak var profileImageView: UIImageView!

    var oauthManager = OAuthManager()
    var redditManager = RedditManager()

    override func viewDidLoad() {
        super.viewDidLoad()

        oauthManager.delegate = self
        redditManager.delegate = self

        oauthManager.validateToken()
    }

}

// MARK: - OAuthManagerDelegate

extension ViewController2: OAuthManagerDelegate {

    @IBAction func logOutPressed(_ sender: UIBarButtonItem) {
        oauthManager.closeSession()
    }

    func didReciveToken(_ oauthManager: OAuthManager) {
        redditManager.me()
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

extension ViewController2: RedditManagerDelegate {

    func didUpdateUser(_ redditManager: RedditManager, user: UserModel) {
        DispatchQueue.main.async {
            self.title = user.name

            let url = URL(string: user.icon_img)
            let data = try? Data(contentsOf: url!)
            self.profileImageView.image = UIImage(data: data!)
        }
    }

    func didRedditFailWithError(_ error: Error) {
        print("Reddit: \(error)")
    }

}
