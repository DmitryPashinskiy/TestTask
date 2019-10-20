//
//  PhotoLibraryManager.swift
//  TestTaskReddit
//
//  Created by Newcomer on 20.10.2019.
//  Copyright © 2019 Home. All rights reserved.
//

import UIKit
import Photos

typealias PhotoLibraryResult = Result<Void, PhotoLibraryError>

enum PhotoLibraryError: Error {
  case photoPermissionDenied
  // could be occured due to parent control
  case photoPermissionRestricted
  case timeExpired
  case underlying(error: Error?)
}


class PhotoLibraryManager {
  
  private let queue = OperationQueue()
  
  init() {
    queue.maxConcurrentOperationCount = ProcessInfo.processInfo.processorCount
  }
  
  func requestPermissionIfNeeded(completion: @escaping ActionBlock<PhotoLibraryResult>) {

    switch PHPhotoLibrary.authorizationStatus() {
    case .authorized:
      completion(.success(()))
      return
    case .denied:
      completion(.failure(.photoPermissionDenied))
      return
    case .restricted:
      completion(.failure(.photoPermissionRestricted))
      return
    case .notDetermined: break // requestAuthorization
    @unknown default: break // requestAuthorization
    }
    
    PHPhotoLibrary.requestAuthorization { status in
      if status == .authorized {
        completion(.success(()))
      } else {
        completion(.failure(.underlying(error: CocoaError(.userCancelled))))
      }
    }
  }
  
  /// Saves an image into the PhotoLibrary
  ///
  /// - Parameter isHighPriority: images are saved concurrently, if this property set as `true` it will increase priority, otherwise priority is `default`. Use this property  for user initiated action
  func saveToPhotos(image: UIImage, isHighPriority: Bool = false, completion: @escaping ActionBlock<PhotoLibraryResult>) {
    guard PHPhotoLibrary.authorizationStatus() == .authorized else {
      completion(.failure(.photoPermissionDenied))
      return
    }
    
    let operation = SaveImageInLibraryOperation(image: image)
    if isHighPriority {
      operation.queuePriority = .veryHigh
    }
    operation.completionBlock = { [unowned operation] in
      assert(operation.result != nil)
      guard let result = operation.result else {
        return
      }
      completion(result)
    }
    queue.addOperation(operation)
  }
  
}


private class SaveImageInLibraryOperation: Operation {
  
  let image: UIImage
  let timeExpiration: TimeInterval = 15
  
  var result: PhotoLibraryResult?
  
  private var condition = NSCondition()
  
  init(image: UIImage) {
    self.image = image
    super.init()
  }
  
  override func main() {
    UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    assert(Thread.isMainThread)
    if condition.wait(until: Date() + timeExpiration) == false {
      result = .failure(.timeExpired)
    }
  }
  
  @objc private func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo info: Any) {
    if let error = error {
      result = .failure(.underlying(error: error))
    } else {
      result = .success(())
    }
    condition.signal()
  }
  
}
