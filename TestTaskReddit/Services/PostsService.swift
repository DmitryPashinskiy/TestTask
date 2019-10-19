//
//  PostsService.swift
//  TestTaskReddit
//
//  Created by Newcomer on 19.10.2019.
//  Copyright © 2019 Home. All rights reserved.
//

import Foundation


class PostService {
  
  var manager: NetworkManager = NetworkManagerImpl()
  
  @discardableResult
  func fetchPosts(completion: @escaping ActionBlock<Result<[Post], Error>> ) -> NetworkOperation? {
    
    let request = URLRequest(url: URL(string: "https://www.reddit.com/top.json")!)
    
    return manager.send(request: request) { result in
      switch result {
      case .success(let data):
        do {
          var decoder = JSONDecoder()
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

