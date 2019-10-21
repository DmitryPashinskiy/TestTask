//
//  Database.swift
//  TestTaskReddit
//
//  Created by Newcomer on 21.10.2019.
//  Copyright © 2019 Home. All rights reserved.
//

import Foundation


protocol Database {
  func insert<T>(objects: [T])
  func remove<T>(objects: [T])
  
  func objects<T>(object: T, after: T?)
  
  /// removes all data in Database
  func wipe()
}


class StandardDatabase {
  
  var coreDataStack: CoreDataStack
  
  init(stack: CoreDataStack) {
    self.coreDataStack = stack
  }
  
  func fetchPosts(after id: String? = nil, completion: ActionBlock<Result<[Post], Error>>) {
    
    do {
      var offset = 0
      if let id = id {
        let predicate = NSPredicate(format: "id=%@", id)
        let afterPostModel = try coreDataStack.fetchObject(predicate: predicate, properties: ["order"]) as PostModel?
        offset = afterPostModel?.order.intValue ?? 0
      }
      let sortDescriptior = NSSortDescriptor(key: "order", ascending: true)
      print("offset is \(offset)")
      let models = try coreDataStack.fetch(object: PostModel.self,
                                           offset: offset,
                                           size: 25,
                                           sortDescriptior: sortDescriptior)
      completion(.success(makePosts(models: models)))
    } catch {
      Log(error)
      completion(.failure(error))
    }
  }
  
  func makePosts(models: [PostModel]) -> [Post] {
    return models.map {
      return Post(id: $0.id,
                  title: $0.title,
                  author: $0.author!,
                  createdDate: $0.created,
                  thumbnail: $0.thumbnailURL!,
                  commentsAmount: $0.commentsAmount!.intValue,
                  imageURL: $0.imageURL!)
    }
  }
  
  func savePosts(posts: [Post]) {
    
    let context = coreDataStack.persistentContainer.viewContext
    let count = try! coreDataStack.countOf(PostModel.self)
    
    posts.enumerated().forEach { index, post in
      let postModel = PostModel(context: context)
      postModel.id = post.id
      postModel.title = post.title
      postModel.author = post.author
      postModel.created = post.createdDate
      postModel.thumbnailURL = post.thumbnail
      postModel.commentsAmount = post.commentsAmount as NSNumber
      postModel.imageURL = post.imageURL
      postModel.order = NSNumber(value: count + index)
    }
    
    coreDataStack.save()
  }
  
}
