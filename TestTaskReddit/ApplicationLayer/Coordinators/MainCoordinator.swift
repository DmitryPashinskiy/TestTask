//
//  MainCoordinator.swift
//  TestTaskReddit
//
//  Created by Newcomer on 20.10.2019.
//  Copyright © 2019 Home. All rights reserved.
//

import UIKit

enum AppRoute {
  case feed(activity: NSUserActivity)
  case preview(imageURL: URL)
}

class AppRouteBuilder {
  func make(activity: NSUserActivity) -> AppRoute? {
    if activity.activityType == "restoration" {
      return .feed(activity: activity)
    }
    return nil
  }
}

protocol StateRestorationActivityProvider {
  func stateRestorationActivity() -> NSUserActivity?
}

class MainCoordinator {
  
  var builder = AppRouteBuilder()
  private var navigationController: UINavigationController?
  
  func start(window: UIWindow, activity: NSUserActivity? = nil) {
    let container = DIContainerFactory.makePostsListContainer()
    let route = activity.flatMap { builder.make(activity: $0) }
    
    let viewController = PostsListFactory.make(container: container, route: route)
    navigationController = UINavigationController(rootViewController: viewController)
    window.rootViewController = navigationController
  }
  
  func stateRestorationActivity() -> NSUserActivity? {
    if let provider = navigationController?.topViewController as? StateRestorationActivityProvider {
      return provider.stateRestorationActivity()
    }
    return nil
  }
  
}
