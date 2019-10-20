//
//  PreviewImageFactory.swift
//  TestTaskReddit
//
//  Created by Newcomer on 20.10.2019.
//  Copyright © 2019 Home. All rights reserved.
//

import UIKit


class PreviewImageFactory {
  
  class func make(container: DIContainer, imageURL: URL) -> UIViewController {
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let identifier = String(describing: PreviewImageVC.self)
    guard let vc = storyboard.instantiateViewController(identifier: identifier) as? PreviewImageVC else {
      fatalError("There is no such ViewController with identifier \(identifier) in storyboard: \(storyboard)")
    }
    vc.imageURL = imageURL
    guard let photoManager = container.resolve() as PhotoLibraryManager?,
      let imageProvider = container.resolve() as ImageProvider?  else {
      fatalError("Can't obtain all necessery objects from container")
    }
    vc.photoManager = photoManager
    vc.imageProvider = imageProvider
    return vc
  }
  
}
