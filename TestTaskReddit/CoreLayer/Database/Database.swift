//
//  Database.swift
//  TestTaskReddit
//
//  Created by Newcomer on 21.10.2019.
//  Copyright © 2019 Home. All rights reserved.
//

import Foundation


protocol Database {
  func insert<T>(objects: [T])
  func remove<T>(objects: [T])
  
  func objects<T>(object: T, after: T?)
  
  /// removes all data in Database
  func wipe()
}
