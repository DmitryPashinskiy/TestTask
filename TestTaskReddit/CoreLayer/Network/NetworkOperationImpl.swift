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
  unowned var session: URLSession
  var request: URLRequest
  var callbackQueue: DispatchQueue
  var networkCompletion: NetworkCallback
  
  let timeout: TimeInterval = 15
  private var condition = NSCondition()
  
  init(request: URLRequest, session: URLSession, manager: NetworkManager, callbackQueue: DispatchQueue, networkCompletion: @escaping NetworkCallback) {
    self.request = request
    self.session = session
    self.manager = manager
    self.networkCompletion = networkCompletion
    self.callbackQueue = callbackQueue
    super.init()
  }
  
  override func main() {
    task = session.dataTask(with: request) { [weak self] (data, response, error) in
      guard let self = self else { return }
      
      let result: NetworkResult
      if let error = error {
        result = .failure(error)
      } else if let data = data {
        result = .success(data)
      } else {
        result = .failure(CocoaError(.featureUnsupported))
      }
      
      if let response = response as? HTTPURLResponse {
        Log("<--- \(response.statusCode) Response is received: \(response.url?.absoluteString ?? "")")
      }
      
      self.invokeCompletion(result: result)
      self.condition.signal()
    }
    
    task?.resume()
    if let request = task?.originalRequest {
      Log("---> Request is sending : \(request)")
    }
    
    if condition.wait(until: Date() + timeout) == false {
      self.invokeCompletion(result: .failure(NetworkError.timeout))
    }
    
  }
  
  override func cancel() {
    super.cancel()
    invokeCompletion(result: .failure(CocoaError(.userCancelled)))
  }
  
  func invokeCompletion(result: NetworkResult) {
    callbackQueue.async { //[weak self] in
      print("OperationCompletion: thumb: \(self.request.url!)")
      self.networkCompletion(result)
    }
  }
  
}

extension NetworkOperationImpl: NetworkOperation {
  func cancelOperation() {
    manager?.cancel(operation: self)
  }
}
