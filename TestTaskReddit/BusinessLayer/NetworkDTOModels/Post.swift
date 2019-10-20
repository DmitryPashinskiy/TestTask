//
//  Post.swift
//  TestTaskReddit
//
//  Created by Newcomer on 19.10.2019.
//  Copyright © 2019 Home. All rights reserved.
//

import Foundation

struct Post {
  let id: String
  let title: String
  let author: String
  let createdDate: Date
  let thumbnail: URL
  let commentsAmount: Int
  let imageURL: URL
}



extension Post: Decodable {
  
  enum CodingKeys: String, CodingKey {
    case id
    case title
    case author
    case createdDate = "created"
    case thumbnail
    case imageURL = "url"
    case commentsAmount = "num_comments"
  }
}
