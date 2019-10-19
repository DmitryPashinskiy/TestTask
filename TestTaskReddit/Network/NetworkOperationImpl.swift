//
//  NetworkOperationImpl.swift
//  TestTaskReddit
//
//  Created by Newcomer on 19.10.2019.
//  Copyright © 2019 Home. All rights reserved.
//

import Foundation



class NetworkOperationImpl: Operation {
  
  /// only needs to cancel the operation manually
  private weak var manager: NetworkManager?
  
  weak var task: URLSessionTask?
  var callbackQueue: DispatchQueue
  var networkCompletion: NetworkCallback
  
  init(task: URLSessionTask, manager: NetworkManager, callbackQueue: DispatchQueue, networkCompletion: @escaping NetworkCallback) {
    self.task = task
    self.manager = manager
    self.networkCompletion = networkCompletion
    self.callbackQueue = callbackQueue
    super.init()
  }
  
  override func start() {
    super.start()
    task?.resume()
    if let request = task?.originalRequest {
      Log("---> Request is sending : \(request)")
    }
  }
  
  override func cancel() {
    super.cancel()
    invokeCompletion(result: .failure(CocoaError(.userCancelled)))
  }
  
  func invokeCompletion(result: NetworkResult) {
    callbackQueue.async { [weak self] in
      self?.networkCompletion(result)
    }
  }
  
}

extension NetworkOperationImpl: NetworkOperation {
  func cancelOperation() {
    manager?.cancel(operation: self)
  }
}
