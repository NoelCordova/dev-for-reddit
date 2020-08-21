//
//  SceneDelegate.swift
//  dev for reddit
//
//  Created by Noel Espino Córdova on 03/08/20.
//  Copyright © 2020 slingercode. All rights reserved.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    // swiftlint:disable:next line_length
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window`
        // to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new
        // (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
        // swiftlint:disable:previous unused_optional_binding

        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        if UserDefaults.standard.string(forKey: K.UD_TOKEN) != nil {
            let mainNavController = storyboard.instantiateViewController(identifier: K.mainNavControllerIdentifier)
            window?.rootViewController = mainNavController
        } else {
            let loginNavController = storyboard.instantiateViewController(identifier: K.loginNavControllerIdentifier)
            window?.rootViewController = loginNavController
        }
    }

    // swiftlint:disable:next identifier_name
    func changeRootViewController(_ vc: UIViewController, animated: Bool) {
        // Custom method
        // Use this method to change the root navigation controller
        if let window = self.window {
            window.rootViewController = vc

            if animated {
                UIView.transition(
                    with: window,
                    duration: 0.5,
                    options: [.transitionFlipFromLeft],
                    animations: nil,
                    completion: nil)
            }
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded
        // (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }

}
