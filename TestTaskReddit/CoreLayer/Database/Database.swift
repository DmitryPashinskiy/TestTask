//
//  Database.swift
//  TestTaskReddit
//
//  Created by Newcomer on 21.10.2019.
//  Copyright © 2019 Home. All rights reserved.
//

import Foundation
typealias DatabaseResult<T> = Result<T, DatabaseError>

enum DatabaseError: Error {
  case underlying(error: Error)
}

protocol Database {
  
  /// - Parameter completion: will be invoked on **main queue**
  func fetchPosts(completion: @escaping ActionBlock<DatabaseResult<[Post]>>)
  
  func removePosts()
  
  /// if post exists, it will be updated, otherwise it creates a new one
  func updatePosts(posts: [Post])
}

