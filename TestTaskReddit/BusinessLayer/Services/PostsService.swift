//
//  PostsService.swift
//  TestTaskReddit
//
//  Created by Newcomer on 19.10.2019.
//  Copyright © 2019 Home. All rights reserved.
//

import Foundation
import CoreData

class PostService {
  
//  private let networkManager: NetworkManager
  private let postsProvider: PostProvider
  private let coreData: CoreDataStack = CoreDataStack()
  
  init(postsProvider: PostProvider) {
    self.postsProvider = postsProvider
  }
  
  @discardableResult
  func fetchPosts(after post: Post? = nil, completion: @escaping ActionBlock<Result<[Post], Error>> ) -> NetworkOperation? {
    
    completion(.success(givePosts()))
    return nil
    
    postsProvider.getPosts(after: post?.id) { [weak self] result in
      guard let self = self else { return }
      switch result {
      case .success(let posts):
        self.savePosts(posts: posts)
        completion(.success(posts))
        
      case .failure(let error):
        Log(error)
        completion(.failure(error))
      }
    }
  }
  
  func savePosts(posts: [Post]) {
    
    let container = self.coreData.persistentContainer
    let context = container.viewContext
    print(context)
    let models = posts.map { post -> PostModel in
      let postModel = PostModel(context: context)
      postModel.id = post.id
      postModel.title = post.title
      postModel.author = post.author
      postModel.created = post.createdDate
      postModel.thumbnailURL = post.thumbnail
      postModel.commentsAmount = post.commentsAmount as NSNumber
      postModel.imageURL = post.imageURL
      return postModel
    }
    
    try! context.save()
  }
  
  func givePosts() -> [Post] {
    
    let context = coreData.persistentContainer.viewContext
    
    let request = PostModel.fetchRequest() as NSFetchRequest
    let models: [PostModel] = try! context.fetch(request)
    
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

