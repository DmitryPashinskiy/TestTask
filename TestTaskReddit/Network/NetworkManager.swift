//
//  NetworkManager.swift
//  TestTaskReddit
//
//  Created by Newcomer on 19.10.2019.
//  Copyright © 2019 Home. All rights reserved.
//

import Foundation


typealias NetworkRequest = URLRequest
typealias NetworkResult = Result<Data, Error>
typealias NetworkCallback = (NetworkResult) -> Void

protocol NetworkManager: class {
  @discardableResult
  func send(request: NetworkRequest, completion: @escaping NetworkCallback) -> NetworkOperation
  func cancel<O: Operation>(operation: O) where O: NetworkOperation
}



protocol NetworkOperation {
  func cancelOperation()
}

