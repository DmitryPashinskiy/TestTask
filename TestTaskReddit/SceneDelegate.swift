//
//  SceneDelegate.swift
//  TestTaskReddit
//
//  Created by Newcomer on 19.10.2019.
//  Copyright © 2019 Home. All rights reserved.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

  var window: UIWindow?
  let mainCoordinator = MainCoordinator()

  func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    guard let windowScene = (scene as? UIWindowScene) else { return }
    
    let window = UIWindow(windowScene: windowScene)
    self.window = window
    
    mainCoordinator.start(window: window, activity: session.stateRestorationActivity)
    window.makeKeyAndVisible()
  }
  
  func stateRestorationActivity(for scene: UIScene) -> NSUserActivity? {
    return mainCoordinator.stateRestorationActivity()
  }

}

