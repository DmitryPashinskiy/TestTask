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
  var context: NSManagedObjectContext {
    return persistentContainer.viewContext
  }
  
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


extension CoreDataStack {
  
  func save() {
    if context.hasChanges {
      do {
        try self.context.save()
      } catch {
        Log(error)
      }
    }
  }
  
  func fetch<T: NSManagedObject>(object: T.Type,
                                 offset: Int = 0,
                                 size: Int? = nil,
                                 predicate: NSPredicate? = nil,
                                 sortDescriptior: NSSortDescriptor? = nil) throws -> [T] {

    let request = object.fetchRequest()
    request.fetchLimit = size ?? request.fetchBatchSize
    request.fetchOffset = offset
    request.sortDescriptors = sortDescriptior.map { [$0] }
    request.predicate = predicate
    
    return try context.fetch(request) as! [T]
  }
  
  func fetchObject<T: NSManagedObject>(predicate: NSPredicate, properties: [String]? = nil) throws -> T? {

    let request = T.fetchRequest()
    request.predicate = predicate
    request.fetchLimit = 1
    request.propertiesToFetch = properties
    
  let models = try context.fetch(request) as! [T]
  return models.first
  }
  
  func countOf<T: NSManagedObject>(_ type: T.Type) throws -> Int {
    let request = T.fetchRequest()
    return try context.count(for: request)
  }
  
  func remove<T: NSManagedObject>(_ type: T.Type) {
    let fetchRequest = T.fetchRequest()
    let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
    try! context.execute(deleteRequest)
    
    save()
  }
  
}



