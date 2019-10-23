//
//  AppRoute.swift
//  TestTaskReddit
//
//  Created by Newcomer on 22.10.2019.
//  Copyright © 2019 Home. All rights reserved.
//

import Foundation


enum AppRoute: String, RawRepresentable {
  case feed
  case preview
}

class AppRouteBuilder {
  func make(activity: NSUserActivity) -> AppRoute? {
    var components = activity.activityType.components(separatedBy: ".")
    guard components.first == "restoration" else {
      return nil
    }
    
    return components.last.flatMap { AppRoute(rawValue: $0) }
  }
}
