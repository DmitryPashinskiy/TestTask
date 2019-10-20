//
//  PostsListFactory.swift
//  TestTaskReddit
//
//  Created by Newcomer on 20.10.2019.
//  Copyright © 2019 Home. All rights reserved.
//

import UIKit

class PostsListFactory {
  
  class func make(container: DIContainer) -> UIViewController {
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let identifier = String(describing: PostsListTableVC.self)
    guard let vc = storyboard.instantiateViewController(identifier: identifier) as? PostsListTableVC else {
      fatalError("There is no such ViewController with identifier \(identifier) in storyboard: \(storyboard)")
    }
    
    
    guard let imageProvider = container.resolve() as ImageProvider?,
      let service = container.resolve() as PostService? else {
        fatalError("Can't obtain all necessery objects from container")
    }
    vc.imageProvider = imageProvider
    vc.service = service
    return vc
  }
  
}

