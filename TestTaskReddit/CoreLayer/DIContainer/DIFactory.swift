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
    let imageProvider = ImageProviderImpl(storage: ImageStorageImpl(), networkManager: NetworkManagerImpl())
    
    let container = DIContainerImpl()
    container.register(imageProvider as ImageProvider)
    container.register(PostService(networkManager: NetworkManagerImpl()))
    
    container.register(PhotoLibraryManager())
    
    return container
  }
  
}

