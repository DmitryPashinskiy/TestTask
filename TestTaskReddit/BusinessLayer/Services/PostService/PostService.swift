//
//  PostsService.swift
//  TestTaskReddit
//
//  Created by Newcomer on 19.10.2019.
//  Copyright © 2019 Home. All rights reserved.
//

import Foundation
import CoreData

typealias PostsCompletion = ActionBlock<Result<[Post], Error>>

protocol PostService {
  /// Fetches posts
  ///
  /// Fetches posts remotly and cache them
  @discardableResult
  func fetchPosts(after post: Post?, completion: @escaping PostsCompletion) -> NetworkOperation?
  
  /// Fetches all cached posts
  func fetchCachedPosts(completion: @escaping PostsCompletion)
  
  /// Removes all cached posts
  func wipeCache()
}

extension PostService {
  @discardableResult
  func fetchPosts(completion: @escaping PostsCompletion) -> NetworkOperation? {
    return self.fetchPosts(after: nil, completion: completion)
  }
}
