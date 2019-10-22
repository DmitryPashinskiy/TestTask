//
//  DIFactory.swift
//  TestTaskReddit
//
//  Created by Newcomer on 20.10.2019.
//  Copyright © 2019 Home. All rights reserved.
//

import Foundation

class DIContainerFactory {
  
  class func makePostsListContainer() -> DIContainer {
    let imageStorage = ImageStorageImpl(spaceName: "NetworkImageCache")
    let imageService = ImageServiceImpl(storage: imageStorage, networkManager: NetworkManagerImpl())
    let postProvider = PostProviderImpl(networkManager: NetworkManagerImpl())
    let database = StandardDatabase(stack: CoreDataStack(storeName: "TestTask"))
    
    let container = DIContainerImpl()
    container.register(imageService as ImageService)
    container.register(PostServiceImpl(postProvider: postProvider, database: database) as PostService)
    
    container.register(PhotoLibraryManager())
    
    return container
  }
  
}

