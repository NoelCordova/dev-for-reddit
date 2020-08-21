//
//  ProfileViewController.swift
//  dev for reddit
//
//  Created by Noel Espino Córdova on 20/08/20.
//  Copyright © 2020 slingercode. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {

    @IBOutlet weak var tokenTextField: UITextField!
    @IBOutlet weak var profileImageView: UIImageView!

    var oauthManager = OAuthManager()
    var redditManager = RedditManager()

    override func viewDidLoad() {
        super.viewDidLoad()

        oauthManager.delegate = self
        redditManager.delegate = self

        oauthManager.validateToken()

        self.navigationItem.title = "Perrortee"
    }

}

// MARK: - OAuthManagerDelegate

extension ProfileViewController: OAuthManagerDelegate {

    @IBAction func logOutPressed(_ sender: UIButton) {
        oauthManager.closeSession()
    }

    func didReciveToken(_ oauthManager: OAuthManager) {
        redditManager.me()
    }

    func didRemoveToken(_ oauthManager: OAuthManager) {
        DispatchQueue.main.async {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let loginNavController = storyboard.instantiateViewController(identifier: K.loginNavControllerIdentifier)

            // This is to get the SceneDelegate custom changeRootViewController method
            (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?
                .changeRootViewController(loginNavController, animated: true)
        }
    }

    func didOAuthFailWithError(_ error: Error) {
        print("Oauth: \(error)")
    }

}

// MARK: - RedditManagerDelegate

extension ProfileViewController: RedditManagerDelegate {

    func didRecieveUser(_ redditManager: RedditManager, user: UserModel) {
        DispatchQueue.main.async {
            self.tokenTextField.text = UserDefaults.standard.string(forKey: K.UD_TOKEN)!

            let url = URL(string: user.icon_img)
            let data = try? Data(contentsOf: url!)
            self.profileImageView.image = UIImage(data: data!)
        }
    }

    func didRedditFailWithError(_ error: Error) {
        print("Reddit: \(error)")
    }

}
