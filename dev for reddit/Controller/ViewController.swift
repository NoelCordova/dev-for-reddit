//
//  ViewController.swift
//  dev for reddit
//
//  Created by Noel Espino Córdova on 03/08/20.
//  Copyright © 2020 slingercode. All rights reserved.
//

import UIKit
import AuthenticationServices

class ViewController: UIViewController {

    var aouthManager = OAuthManager()
    var authSession: ASWebAuthenticationSession?

    override func viewDidLoad() {
        super.viewDidLoad()

        aouthManager.delegate = self
    }

}

// MARK: - ASWebAuthenticationPresentationContextProviding

extension ViewController: ASWebAuthenticationPresentationContextProviding {

    @IBAction func logInPressed(_ sender: UIButton) {
        let url = aouthManager.createNewSessionURL()

        authSession = ASWebAuthenticationSession.init(
            url: url!,
            callbackURLScheme: K.REDIRECT_URI,
            completionHandler: aouthManager.handleAuthSession(url:error:)
        )

        authSession?.presentationContextProvider = self
        authSession?.start()
    }

    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return self.view.window ?? ASPresentationAnchor()
    }

}

// MARK: - OAuthManagerDelegate

extension ViewController: OAuthManagerDelegate {

    func didReciveToken(_ oauthManager: OAuthManager) {
        DispatchQueue.main.async {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let mainNavController = storyboard.instantiateViewController(identifier: "MainNavController")

            // This is to get the SceneDelegate custom changeRootViewController method
            (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?
                .changeRootViewController(mainNavController, animated: true)
        }
    }

    func didOAuthFailWithError(_ error: Error) {
        print("OAuth: \(error)")
    }

}
