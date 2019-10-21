//
//  URLBuilder.swift
//  TestTaskReddit
//
//  Created by Newcomer on 21.10.2019.
//  Copyright © 2019 Home. All rights reserved.
//

import Foundation

enum URLMethod {
  case GET
  case POST
  // we don't use in this project any more methods at least these two above
  case other(method: String)
  
  func string() -> String {
    switch self {
    case .GET: return "GET"
    case .POST: return "POST"
    case .other(method: let method): return method
    }
  }
  
}

class URLBuilder {
  
  private enum Constants {
    static let  defaultScheme = "https"
  }
  
  private(set) var scheme: String
  private(set) var host: String
  
  init(host: String, scheme: String? = nil) {
    self.host = host
    self.scheme = scheme ?? Constants.defaultScheme
  }
  
  func makeRequest(route: String, method: URLMethod, urlParams: [String: String]? = nil, body: Data? = nil) -> URLRequest? {
    
    var components = URLComponents()
    
    components.host = host
    components.scheme = scheme
    components.path = route
    
    components.queryItems = urlParams?.map { URLQueryItem(name: $0.0, value: $0.1) }
    
    var request = components.url.map { URLRequest(url: $0) }
    request?.httpMethod = method.string()
    request?.httpBody = body
      
    return request
  }
}
