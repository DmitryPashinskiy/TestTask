//
//  CoreData.swift
//  TestTaskReddit
//
//  Created by Newcomer on 21.10.2019.
//  Copyright © 2019 Home. All rights reserved.
//

import CoreData


class CoreDataStack {
  
  var persistentContainer: NSPersistentContainer
  
  init() {
    let container = NSPersistentContainer(name: "TestTask")
    container.loadPersistentStores { (storeDescription, error) in
      if let error = error as NSError? {
        fatalError("Unresolved error \(error), \(error.userInfo)")
      }
    }
    persistentContainer = container
    
  }
  
}

