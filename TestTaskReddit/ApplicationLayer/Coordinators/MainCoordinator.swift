//
//  MainCoordinator.swift
//  TestTaskReddit
//
//  Created by Newcomer on 20.10.2019.
//  Copyright © 2019 Home. All rights reserved.
//

import UIKit

protocol StateRestorationActivityProvider {
  func stateRestorationActivity() -> NSUserActivity?
}

class MainCoordinator {
  
  var routeBuilder = AppRouteBuilder()
  private var navigationController: UINavigationController?
  
  func start(window: UIWindow, activity: NSUserActivity? = nil) {
    let container = DIContainerFactory.makePostsListContainer()
    let route = activity.flatMap { routeBuilder.make(activity: $0) }
    
    let viewController = PostsListFactory.make(container: container, route: route, activity: activity)
    navigationController = UINavigationController(rootViewController: viewController)
    window.rootViewController = navigationController
  }
  
  func stateRestorationActivity() -> NSUserActivity? {
    /// support restoration only those   UIViewControlers that are in stack
    if let provider = navigationController?.topViewController as? StateRestorationActivityProvider {
      return provider.stateRestorationActivity()
    }
    return nil
  }
  
}
