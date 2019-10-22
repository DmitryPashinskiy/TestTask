//
//  PostProvider.swift
//  TestTaskReddit
//
//  Created by Newcomer on 21.10.2019.
//  Copyright © 2019 Home. All rights reserved.
//

import Foundation


protocol PostProvider {
  @discardableResult
  func getPosts(after: String?, completion: @escaping ActionBlock<Result<[Post], Error>>) -> NetworkOperation?
}
