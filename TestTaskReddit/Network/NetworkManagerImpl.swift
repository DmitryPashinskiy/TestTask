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
    let task = session.dataTask(with: request) { (data, response, error) in
      guard let response = response as? HTTPURLResponse else {
        Log("FAILURE: There is no response. Network Manager could be used for incorrect purposes")
        completion(.failure(CocoaError(.executableRuntimeMismatch)))
        return
      }
      Log("<--- \(response.statusCode) Response is received: \(response.url!)")
      if let error = error {
        completion(.failure(error))
      } else if let data = data {
        completion(.success(data))
      } else {
        completion(.failure(CocoaError(.featureUnsupported)))
      }
    }
    let operation = NetworkOperationImpl(task: task,
                                         manager: self,
                                         callbackQueue: callbackQueue,
                                         networkCompletion: completion)
    enqueue(operation)
    return operation
  }
  
  func cancel<O: Operation>(operation: O) where O : NetworkOperation {
    dequeue(operation)
  }
  
}



