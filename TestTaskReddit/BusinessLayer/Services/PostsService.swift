//
//  PostsService.swift
//  TestTaskReddit
//
//  Created by Newcomer on 19.10.2019.
//  Copyright © 2019 Home. All rights reserved.
//

import Foundation


class PostService {
  
  private let networkManager: NetworkManager
  
  init(networkManager: NetworkManager) {
    self.networkManager = networkManager
  }
  
  @discardableResult
  func fetchPosts(after post: Post? = nil, completion: @escaping ActionBlock<Result<[Post], Error>> ) -> NetworkOperation? {
    
    var components = URLComponents(string: "https://www.reddit.com/top.json")!
    
    if let postID = post?.id {
      let query = URLQueryItem(name: "after", value: "t3_\(postID)")
      components.queryItems = [query]
    }
    
    let request = URLRequest(url: components.url!)
    
    return networkManager.send(request: request) { result in
      switch result {
      case .success(let data):
        do {
          let decoder = JSONDecoder()
          decoder.dateDecodingStrategy = .custom { decoder -> Date in
            let container = try decoder.singleValueContainer()
            let timeInterval = try container.decode(TimeInterval.self)
            return Date(timeIntervalSince1970: timeInterval)
          }
          let postsResult = try decoder.decode(PostsResult.self, from: data)
          let posts = postsResult.data.children.map { $0.data }
          completion(.success(posts))
        } catch {
          Log(error)
          completion(.failure(error))
        }
        
      case .failure(let error):
      completion(.failure(error))
      }
    }
    
  }
  
}

