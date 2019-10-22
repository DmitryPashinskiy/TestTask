//
//  PostModel+CoreDataProperties.swift
//  TestTaskReddit
//
//  Created by Newcomer on 21.10.2019.
//  Copyright © 2019 Home. All rights reserved.
//
//

import Foundation
import CoreData


extension PostModel {
  
  @nonobjc public class func fetchRequest() -> NSFetchRequest<PostModel> {
    return NSFetchRequest<PostModel>(entityName: "PostModel")
  }
  
  @NSManaged public var id: String!
  @NSManaged public var title: String!
  @NSManaged public var author: String?
  @NSManaged public var commentsAmount: NSNumber?
  @NSManaged public var thumbnailURL: URL?
  @NSManaged public var imageURL: URL?
  @NSManaged public var created: Date!
  
  @NSManaged public var orderNumber: NSNumber!

}
