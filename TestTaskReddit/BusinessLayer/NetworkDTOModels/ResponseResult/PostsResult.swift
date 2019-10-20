//
//  PostsResult.swift
//  TestTaskReddit
//
//  Created by Newcomer on 19.10.2019.
//  Copyright © 2019 Home. All rights reserved.
//

import Foundation


struct PostsResult: Decodable {
  var data: Data
}

extension PostsResult {
  struct Data: Decodable {
    var children: [Child]
  }
}

extension PostsResult.Data {
  struct Child: Decodable {
    var data: Post
  }
}
