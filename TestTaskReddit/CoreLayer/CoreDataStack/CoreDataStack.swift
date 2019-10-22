//
//  CoreData.swift
//  TestTaskReddit
//
//  Created by Newcomer on 21.10.2019.
//  Copyright © 2019 Home. All rights reserved.
//

import CoreData
typealias CoreDataStackResult<T> = Result<T, CoreDataStackError>

enum CoreDataStackError: Error {
  case unexpectedResultType
  case underlying(error: Error)
}

class CoreDataStack {
  
  private var persistentContainer: NSPersistentContainer
  private(set) var context: NSManagedObjectContext
  
  init(storeName: String) {
    let container = NSPersistentContainer(name: storeName)
    container.loadPersistentStores { (storeDescription, error) in
      if let error = error as NSError? {
        fatalError("Unresolved error \(error), \(error.userInfo)")
      }
    }
    persistentContainer = container
    context = persistentContainer.newBackgroundContext()
  }
}


extension CoreDataStack {
  
  func save() {
    if context.hasChanges {
      context.perform { [weak self] in
        guard let self = self else { return }
        do {
          try self.context.save()
          self.saveSync(context: self.context.parent)
        } catch {
          Log(error)
        }
      }
    }
  }
  
  private func saveSync(context: NSManagedObjectContext?) {
    guard let context = context else { return }
    if context.hasChanges {
      context.performAndWait {
        do {
          try self.context.save()
        } catch {
          Log(error)
        }
      }
    }
  }
  
  func fetch<T: NSManagedObject>(object: T.Type,
                                 sortDescriptior: NSSortDescriptor? = nil,
                                 predicate: NSPredicate? = nil,
                                 completion: @escaping ActionBlock<CoreDataStackResult<[T]>>) {
    context.perform { [weak self] in
      guard let self = self else { return }
      
      let request = object.fetchRequest()
      request.sortDescriptors = sortDescriptior.map { [$0] }
      request.predicate = predicate
      let result: CoreDataStackResult<[T]>
      do {
        if let models = try self.context.fetch(request) as? [T] {
          result = .success(models)
        } else {
          result = .failure(.unexpectedResultType)
        }
      } catch {
        result = .failure(.underlying(error: error))
      }
      completion(result)
    }
  }
  
  func countOf<T: NSManagedObject>(_ type: T.Type,
                                   callbackQueue: DispatchQueue,
                                   completion: @escaping ActionBlock<CoreDataStackResult<Int>>) {
    let request = T.fetchRequest()
    let result: CoreDataStackResult<Int>
    do {
      let count = try context.count(for: request)
      result = .success(count)
    } catch {
      result = .failure(.underlying(error: error))
    }
    callbackQueue.async {
      completion(result)
    }
  }
  
  func remove<T: NSManagedObject>(_ type: T.Type) {
    context.perform { [weak self] in
      guard let self = self else { return }
      
      let fetchRequest = T.fetchRequest()
      let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
      do {
        try self.context.execute(deleteRequest)
      } catch {
        Log(error)
      }
    }
  }
  
}



