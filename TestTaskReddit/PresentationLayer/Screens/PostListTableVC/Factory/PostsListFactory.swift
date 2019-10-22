//
//  PostsListFactory.swift
//  TestTaskReddit
//
//  Created by Newcomer on 20.10.2019.
//  Copyright © 2019 Home. All rights reserved.
//

import UIKit

class PostsListFactory {
  
  class func make(container: DIContainer, route: AppRoute? = nil) -> UIViewController {
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let identifier = String(describing: PostsListTableVC.self)
    guard let vc = storyboard.instantiateViewController(identifier: identifier) as? PostsListTableVC else {
      fatalError("There is no such ViewController with identifier \(identifier) in storyboard: \(storyboard)")
    }
    
    
    guard let imageService = container.resolve() as ImageService?,
      let service = container.resolve() as PostService? else {
        fatalError("Can't obtain all necessery objects from container")
    }
    vc.imageService = imageService
    vc.service = service
    
    let router = PostsListRouter(container: container, viewController: vc)
    
    vc.router = router
    if let route = route {
      switch route {
      case .feed(activity: let activity):
        vc.setup(activity: activity)
      default:
        assertionFailure("Route is unsupported: \(route)")
      }
    }
    
    return vc
  }
  
}

