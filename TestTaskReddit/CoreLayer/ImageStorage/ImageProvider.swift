//
//  ImageProvider.swift
//  TestTaskReddit
//
//  Created by Newcomer on 19.10.2019.
//  Copyright © 2019 Home. All rights reserved.
//

import UIKit

typealias ImageResult = Result<UIImage, Error>

protocol ImageProvider {
  
  /// Fetches Image
  ///
  /// Fetches image from local storage at specified `url`. If there is no such image
  /// `ImageProvider` will make a network request to get it and then will save it into the local storage
  /// - Parameter completion: will be invoked asynchronous when image will be fetched
  func fetchImage(url: URL, completion: @escaping ActionBlock<ImageResult>)
}


class ImageProviderImpl: ImageProvider {
  
  private var networkManager: NetworkManager
  private var storage: ImageStorage
  private var callbackQueue: DispatchQueue = .main
  
  private var requestCompletionStorage: [URL: [ActionBlock<ImageResult>]] = [:]
  private var queue = DispatchQueue(label: "com.test.task.imageProvider.serial")
  
  init(storage: ImageStorage, networkManager: NetworkManager) {
    self.storage = storage
    self.networkManager = networkManager
  }
  
  func fetchImage(url: URL, completion: @escaping ActionBlock<ImageResult>) {
    
    guard !url.isFileURL else {
      callbackQueue.async {
        completion(.failure(CocoaError(.featureUnsupported)))
      }
      return
    }
    
    guard url.isHTTP else {
      callbackQueue.async {
        completion(.failure(CocoaError(.executableRuntimeMismatch)))
      }
      return
    }
    
    storage.image(key: url.absoluteString, callbackQueue: queue) { [weak self] image in
      guard let self = self else { return }
      if let image = image {
        self.callbackQueue.async {
          completion(.success(image))
        }
        return
      }
      self.requestImage(url: url, completion: completion)
    }
  }
  
  private func requestImage(url: URL, completion: @escaping ActionBlock<ImageResult>) {
    enqueueCompletion(for: url, completion: completion)
    networkManager.send(request: .init(url: url), callbackQueue: queue) { result in
      let imageResult: ImageResult
      switch result {
      case .success(let data):
        if let image = UIImage(data: data) {
          self.storage.save(image: image, for: url.absoluteString)
          imageResult = .success(image)
        } else {
          imageResult = .failure(CocoaError(.executableRuntimeMismatch))
        }
      case .failure(let error):
        imageResult = .failure(error)
        Log(error)
      }
      self.dequeueCompletions(for: url, imageResult: imageResult, callbackQueue: self.callbackQueue)
    }
  }

  private func enqueueCompletion(for key: URL, completion: @escaping ActionBlock<ImageResult>) {
    queue.async { [weak self] in
      guard let self = self else { return }
      var completions = self.requestCompletionStorage[key] ?? []
      completions.append(completion)
      self.requestCompletionStorage[key] = completions
    }
  }
  
  private func dequeueCompletions(for key: URL, imageResult: ImageResult, callbackQueue: DispatchQueue) {
    queue.async { [weak self] in
      guard let self = self else { return }
      let completions = self.requestCompletionStorage[key]
      self.requestCompletionStorage[key] = nil
      callbackQueue.async {
        completions?.forEach { block in
          block(imageResult)
        }
      }
    }
  }
  
}
