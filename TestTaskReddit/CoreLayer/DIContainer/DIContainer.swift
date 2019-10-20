//
//  DIContainer.swift
//  TestTaskReddit
//
//  Created by Newcomer on 20.10.2019.
//  Copyright © 2019 Home. All rights reserved.
//

import Foundation

protocol DIContainer {
  func register<T>(_ object: T)
  func resolve<T>() -> T?
}


class DIContainerImpl: DIContainer {
  private var store: [String: Any] = [:]

  func register<T>(_ object: T) {
    let key = String(describing: T.Type.self)
    store[key] = object
  }
  
  func resolve<T>() -> T? {
    let key = String(describing: T.Type.self)
    return store[key] as? T
  }

}
