//
//  Post.swift
//  TestTaskReddit
//
//  Created by Newcomer on 19.10.2019.
//  Copyright © 2019 Home. All rights reserved.
//

import Foundation

private let minute: TimeInterval = 60
private let hour: TimeInterval = 60 * minute
private let day: TimeInterval = 24 * hour

struct Post {
  let id: String
  let title: String
  let author: String
  let createdDate: Date
  let thumbnail: URL
  let commentsAmount: Int
  let imageURL: URL
}

extension Post {
  init(postDTO: PostDTO) {
    id = postDTO.id
    title = postDTO.title
    author = postDTO.author
    createdDate = postDTO.createdDate
    thumbnail = postDTO.thumbnail
    commentsAmount = postDTO.commentsAmount
    imageURL = postDTO.imageURL
  }
}

extension Post {
  var createdTimeAgo: String {
    let finalDate = Date().timeIntervalSince(createdDate)

    switch finalDate {
    case 0..<hour:
      return "recently"
    case hour..<day:
      return "\(Int(finalDate / hour)) hours ago"
    case day...:
      return "\(Int(finalDate / day)) days ago"
      
    default:
      return "Some time ago"
      
    }
  }
}
