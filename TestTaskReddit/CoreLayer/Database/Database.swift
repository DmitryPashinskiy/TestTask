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
        offset = afterPostModel.map { $0.order + 1 } ?? 0
      }
      let sortDescriptior = NSSortDescriptor(key: "order", ascending: true)
      Log("offset is \(offset)")
      let models = try coreDataStack.fetch(object: PostModel.self,
                                           offset: offset,
                                           size: 0,
                                           sortDescriptior: sortDescriptior)
      completion(.success(makePosts(models: models)))
    } catch {
      Log(error)
      completion(.failure(error))
    }
  }
  
  func removePosts() {
    coreDataStack.remove(PostModel.self)
  }
  
  func updatePosts(posts: [Post]) {
    
    let models = fetchPostModels(IDs: posts.map { $0.id })
    
    if models.isEmpty {
      let count = try! coreDataStack.countOf(PostModel.self)
      createPosts(posts: posts, orderStart: count)
    } else {
      mergePosts(posts: posts, postModels: models)
    }
    
    coreDataStack.save()
  }
  
  private func fetchPostModels(IDs: [String]) -> [PostModel] {
    let models = try! coreDataStack.fetch(object: PostModel.self,
                                          predicate: NSPredicate(format: "%@ contains self.id", IDs))
    return models
  }
  
  private func createPosts(posts: [Post], orderStart: Int) {
    let context = coreDataStack.persistentContainer.viewContext
    posts.enumerated().forEach { index, post in
      let postModel = PostModel.createModel(post: post, context: context)
      postModel.order = orderStart + index
    }
  }
  
  private func mergePosts(posts: [Post], postModels: [PostModel]) {
    let modelsInfo = postModels.reduce([String: PostModel]()) { result, model -> [String: PostModel] in
      return result.merging([model.id: model], uniquingKeysWith: {(current, other) in return current})
    }
    
    var postsInfo = posts.reduce([String: Post]()) { result, post -> [String: Post] in
      return result.merging([post.id: post], uniquingKeysWith: {(current, other) in return current})
    }
    
    // updating existing
    for (key, post) in postsInfo {
      if let model = modelsInfo[key] {
        model.updateModel(post: post)
        postsInfo[key] = nil
      }
    }
    
  }
  
  private func makePosts(models: [PostModel]) -> [Post] {
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
  
  
  
}
