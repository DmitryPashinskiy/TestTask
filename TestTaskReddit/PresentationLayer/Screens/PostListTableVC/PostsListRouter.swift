//
//  PostsListRouter.swift
//  TestTaskReddit
//
//  Created by Newcomer on 20.10.2019.
//  Copyright © 2019 Home. All rights reserved.
//

import UIKit

class PostsListRouter {
  
  private var container: DIContainer
  private unowned var viewController: UIViewController
  
  init(container: DIContainer, viewController: UIViewController) {
    self.container = container
    self.viewController = viewController
  }
  
  func showPreviewImage(imageURL: URL, title: String) {
    let vc = PreviewImageFactory.make(container: container, imageURL: imageURL)
    vc.title = title
    viewController.present(vc, animated: true, completion: nil)
  }
  
  
}


