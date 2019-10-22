//
//  PostModel+CoreDataClass.swift
//  TestTaskReddit
//
//  Created by Newcomer on 21.10.2019.
//  Copyright © 2019 Home. All rights reserved.
//
//

import Foundation
import CoreData

@objc(PostModel)
public class PostModel: NSManagedObject {

}


extension PostModel {
  var order: Int {
    get { orderNumber.intValue ?? 0 }
    set { orderNumber = newValue as NSNumber }
  }
}


extension PostModel {
  class func createModel(post: Post, context: NSManagedObjectContext) -> PostModel {
    let postModel = PostModel(context: context)
    postModel.updateModel(post: post)
    return postModel
  }
  
  func updateModel(post: Post) {
    id = post.id
    title = post.title
    author = post.author
    created = post.createdDate
    thumbnailURL = post.thumbnail
    commentsAmount = post.commentsAmount as NSNumber
    imageURL = post.imageURL
  }
}
