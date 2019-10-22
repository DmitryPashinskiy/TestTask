//
//  UserError.swift
//  TestTaskReddit
//
//  Created by Newcomer on 21.10.2019.
//  Copyright © 2019 Home. All rights reserved.
//

import Foundation


enum UserError {
  case noConnection
  case userCancelled
  case noPermission
  case underlying(error: Error)
}
