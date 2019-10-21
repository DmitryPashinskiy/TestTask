//
//  PostProvider.swift
//  TestTaskReddit
//
//  Created by Newcomer on 21.10.2019.
//  Copyright © 2019 Home. All rights reserved.
//

import Foundation


protocol PostProvider {
  @discardableResult
  func getPosts(after: String?, completion: @escaping ActionBlock<Result<[Post], Error>>) -> NetworkOperation?
}



class PostProviderImpl {
  private let networkManager: NetworkManager
  private let requestBuilder: URLBuilder
  private let decoder: JSONDecoder
  
  init(networkManager: NetworkManager) {
    self.networkManager = networkManager
    requestBuilder = URLBuilder(host: "www.reddit.com")
    decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .custom { decoder -> Date in
      let timeInterval = try decoder.singleValueContainer().decode(TimeInterval.self)
      return Date(timeIntervalSince1970: timeInterval)
    }
  }
  
  @discardableResult
  func getPosts(after: String?, completion: @escaping ActionBlock<Result<[Post], Error>>) -> NetworkOperation? {
    
    let params = after.map { ["after": "t3_\($0)"] }
    guard let request = requestBuilder.makeRequest(route: "top.json", method: .GET, urlParams: params) else {
      completion(.failure(NetworkError.invalidParams))
      return nil
    }
    
    return networkManager.send(request: request) { [weak self] result in
      guard let self = self else { return }
      switch result {
      case .success(let data):
        do {
          let postsResult = try self.decoder.decode(PostsResult.self, from: data)
          let posts = postsResult.data.children.map { $0.data }
          completion(.success(posts))
        } catch {
          Log(error)
          completion(.failure(error))
        }
      case .failure(let error):
        completion(.failure(error)) // User Error
      }
    }
    
  }
  
}
