//
//  MainCoordinator.swift
//  TestTaskReddit
//
//  Created by Newcomer on 20.10.2019.
//  Copyright © 2019 Home. All rights reserved.
//

import UIKit

class MainCoordinator {
  
  func start(window: UIWindow) {
    let container = DIFactory.makePostsListContainer()
    let viewController = PostsListFactory.make(container: container)
    let navigationController = UINavigationController(rootViewController: viewController)
    window.rootViewController = navigationController
  }
  
  
}
