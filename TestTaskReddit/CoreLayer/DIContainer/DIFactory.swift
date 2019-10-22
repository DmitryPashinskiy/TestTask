//
//  DIFactory.swift
//  TestTaskReddit
//
//  Created by Newcomer on 20.10.2019.
//  Copyright © 2019 Home. All rights reserved.
//

import Foundation

class DIFactory {
  
  class func makePostsListContainer() -> DIContainer {
    let imageStorage = ImageStorageImpl(spaceName: "NetworkImageCache")
    let imageProvider = ImageProviderImpl(storage: imageStorage, networkManager: NetworkManagerImpl())
    let postProvider = PostProviderImpl(networkManager: NetworkManagerImpl())
    let database = StandardDatabase(stack: CoreDataStack())
    
    let container = DIContainerImpl()
    container.register(imageProvider as ImageProvider)
    container.register(PostService(postProvider: postProvider, database: database))
    
    container.register(PhotoLibraryManager())
    
    return container
  }
  
}

