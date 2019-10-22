//
//  PostServiceImpl.swift
//  TestTaskReddit
//
//  Created by Newcomer on 22.10.2019.
//  Copyright © 2019 Home. All rights reserved.
//

import Foundation

class PostServiceImpl {
  typealias PostsCompletion = ActionBlock<Result<[Post], Error>>
  
  private let postProvider: PostProvider
  private let database: Database
  
  init(postProvider: PostProvider, database: Database) {
    self.postProvider = postProvider
    self.database = database
  }
}


extension PostServiceImpl: PostService {
  
  /// Fetches posts
  ///
  /// Fetches posts remotly and cache them
  @discardableResult
  func fetchPosts(after post: Post? = nil, completion: @escaping PostsCompletion) -> NetworkOperation? {
    
    return postProvider.getPosts(after: post?.id) { [weak self] result in
      guard let self = self else { return }
      switch result {
      case .success(let posts):
        self.database.updatePosts(posts: posts)
        completion(.success(posts))
        
      case .failure(let error):
        Log(error)
        completion(.failure(error))
      }
    }
  }
  
  /// Fetches all cached posts
  func fetchCachedPosts(completion: @escaping PostsCompletion) {
    self.database.fetchPosts { result in
      switch result {
      case .success(let posts):
        completion(.success(posts))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }
  
  /// Removes all cached posts
  func wipeCache() {
    database.removePosts()
  }
  
}
