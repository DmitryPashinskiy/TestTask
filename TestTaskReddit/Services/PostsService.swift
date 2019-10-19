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
  
  func fetchPosts() -> NetworkOperation? {
    
    let request = URLRequest(url: URL(string: "https://www.reddit.com/top.json")!)
    
    return manager.send(request: request) { result in
      switch result {
      case .success(let data):
        do {
          let info = try JSONSerialization.jsonObject(with: data, options: [])
//          Log(info)
        } catch {
          Log(error)
        }
        
      case .failure: Log("Sth went wrong")
      }
    }
    
  }
  
}

