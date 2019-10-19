//
//  ImageStorage.swift
//  TestTaskReddit
//
//  Created by Newcomer on 19.10.2019.
//  Copyright © 2019 Home. All rights reserved.
//

import UIKit

protocol ImageStorage {
  func image(key: String, callbackQueue: DispatchQueue, completion: @escaping ActionBlock<UIImage?>)
  func save(image: UIImage, for key: String)
}

class ImageStorageImpl: ImageStorage {
  
  private let queue = DispatchQueue(label: "com.test.task.imageStorage.concurrent", attributes: .concurrent)
  private var dataSource: [String: UIImage] = [:]
  
  func image(key: String, callbackQueue: DispatchQueue, completion: @escaping ActionBlock<UIImage?>) {
    queue.async {
      let image = self.dataSource[key]
      callbackQueue.async {
        completion(image)
      }
    }
  }
  
  func save(image: UIImage, for key: String) {
    queue.async(flags: .barrier) {
      self.dataSource[key] = image
    }
  }
}
