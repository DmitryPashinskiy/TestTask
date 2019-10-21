//
//  NetworkManagerImpl.swift
//  TestTaskReddit
//
//  Created by Newcomer on 19.10.2019.
//  Copyright © 2019 Home. All rights reserved.
//

import Foundation

class NetworkManagerImpl: NetworkManager {
  
  private var session: URLSession
  private var operationQueue: OperationQueue
  private var queue = DispatchQueue(label: "com.test.task.network.serial")
  
  
  init() {
    session = URLSession.shared
    operationQueue = OperationQueue()
    operationQueue.maxConcurrentOperationCount = ProcessInfo.processInfo.activeProcessorCount
  }
 
  /// Adds operation into the `operationQueue`
  fileprivate func enqueue<O: Operation>(_ operation: O) where O: NetworkOperation {
    queue.async { [weak self] in
      self?.operationQueue.addOperation(operation)
    }
  }
  
  /// Cancels the operation. After cancelling it will be automatically removed from the `operationQueue`
  fileprivate func dequeue<O: Operation>(_ operation: O) where O: NetworkOperation {
    queue.async {
      operation.cancel()
    }
  }
  
  
  // MARK: - NetworkManager
  
  func send(request: NetworkRequest, callbackQueue: DispatchQueue, completion: @escaping NetworkCallback) -> NetworkOperation {
    let operation = NetworkOperationImpl(request: request,
                                         session: session, manager: self,
                                         callbackQueue: callbackQueue,
                                         networkCompletion: completion)
    
    enqueue(operation)
    return operation
  }
  
  func cancel<O: Operation>(operation: O) where O : NetworkOperation {
    dequeue(operation)
  }
  
}



