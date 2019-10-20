//
//  URL+Utilities.swift
//  TestTaskReddit
//
//  Created by Newcomer on 19.10.2019.
//  Copyright © 2019 Home. All rights reserved.
//

import Foundation


extension URL {
  /// Checks whether current `URL` has scheme is  **https or https**
  var isHTTP: Bool {
    guard let components = URLComponents(url: self, resolvingAgainstBaseURL: false) else {
      return false
    }
    return components.scheme == "http" || components.scheme == "https"
  }
}
