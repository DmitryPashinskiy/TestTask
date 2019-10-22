//
//  StandardDatabase.swift
//  TestTaskReddit
//
//  Created by Newcomer on 22.10.2019.
//  Copyright © 2019 Home. All rights reserved.
//

import Foundation

/// Provides necessery functionaly as `Database`
///
/// Based on CoreData
class StandardDatabase {
  
  var coreDataStack: CoreDataStack
  
  init(stack: CoreDataStack) {
    self.coreDataStack = stack
  }
  
}

extension StandardDatabase: Database {
  /// - Parameter completion: will be invoked on **main queue**
   func fetchPosts(completion: @escaping ActionBlock<DatabaseResult<[Post]>>) {
     let sortDescriptior = NSSortDescriptor(key: "orderNumber", ascending: true)
     coreDataStack.fetch(object: PostModel.self, sortDescriptior: sortDescriptior) { result in
       
       let mappedResult = result
         .map { self.makePosts(models: $0) }
         .mapError { DatabaseError.underlying(error: $0) }
       
       DispatchQueue.main.async {
         completion(mappedResult)
       }
     }
   }
   
   func removePosts() {
     coreDataStack.remove(PostModel.self)
   }
   
   func updatePosts(posts: [Post]) {
     
     fetchPostModels(IDs: posts.map { $0.id }) { [weak self] result in
       guard let self = self else { return }
       
       switch result {
       case .success(let models):
         if models.isEmpty {
           self.createPosts(posts: posts)
         } else {
           self.mergePosts(posts: posts, postModels: models)
         }
         self.coreDataStack.save()
         break
       case .failure(let error):
         Log(error)
       }
     }
   }
}


// MARK: - Private
private extension StandardDatabase {
  /// Fetches PostModel
  ///
  /// - Parameter completion: will be performed on context's  ** private queue**
  private func fetchPostModels(IDs: [String], completion: @escaping ActionBlock<CoreDataStackResult<[PostModel]>>) {
    let predicate = NSPredicate(format: "%@ contains self.id", IDs)
    coreDataStack.fetch(object: PostModel.self, predicate: predicate) { result in
      completion(result)
    }
  }
  
  private func createPosts(posts: [Post]) {
    coreDataStack.countOf(PostModel.self, callbackQueue: .main) { [weak self] result in
      guard let self = self else { return }
      
      switch result {
      case .success(let count):
        let context = self.coreDataStack.context
        posts.enumerated().forEach { index, post in
          let postModel = PostModel.createModel(post: post, context: context)
          postModel.order = count + index
        }
        
        self.coreDataStack.save()
      case .failure(let error):
        Log(error)

      }
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
    
    coreDataStack.save()
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
