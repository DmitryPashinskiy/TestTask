//
//  PostProviderImpl.swift
//  TestTaskReddit
//
//  Created by Newcomer on 22.10.2019.
//  Copyright © 2019 Home. All rights reserved.
//

import Foundation

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
}

extension PostProviderImpl {
  private enum HTTPRoute: String {
    case top = "top.json"
  }
}

extension PostProviderImpl: PostProvider {
  
  @discardableResult
  func getPosts(after: String?, completion: @escaping ActionBlock<Result<[Post], Error>>) -> NetworkOperation? {
    
    let params = after.map { ["after": "t3_\($0)"] }
    guard let request = requestBuilder.makeRequest(route: HTTPRoute.top.rawValue, method: .GET, urlParams: params) else {
      completion(.failure(NetworkError.invalidParams))
      return nil
    }
    
    return networkManager.send(request: request) { [weak self] result in
      guard let self = self else { return }
      switch result {
      case .success(let data):
        do {
          let postsResult = try self.decoder.decode(PostsResult.self, from: data)
          let posts = postsResult.data.children.map { Post(postDTO: $0.data) }
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
