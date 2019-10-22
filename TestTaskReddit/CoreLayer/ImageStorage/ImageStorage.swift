//
//  ImageStorage.swift
//  TestTaskReddit
//
//  Created by Newcomer on 19.10.2019.
//  Copyright © 2019 Home. All rights reserved.
//

import UIKit

protocol ImageStorage {
  func image(key: String, callbackQueue: DispatchQueue, completion: @escaping ActionBlock<UIImage?>)
  func save(image: UIImage, for key: String)
}

class ImageStorageInMemoryImpl: ImageStorage {
  
  private let queue = DispatchQueue(label: "com.test.task.imageStorage_InMemory.concurrent", attributes: .concurrent)
  private var dataSource: [String: UIImage] = [:]
  
  func image(key: String, callbackQueue: DispatchQueue, completion: @escaping ActionBlock<UIImage?>) {
    queue.async {
      let image = self.dataSource[key]
      callbackQueue.async {
        completion(image)
      }
    }
  }
  
  func save(image: UIImage, for key: String) {
    queue.async(flags: .barrier) {
      self.dataSource[key] = image
    }
  }
}


class ImageStorageImpl: ImageStorage {
  
  private let fileManager = FileManager.default
  
  private let spaceName: String
  private let folderURL: URL
  
  private let queue = DispatchQueue(label: "com.test.task.imageStorage_InMemory.concurrent", attributes: .concurrent)
  
  init(spaceName: String) {
    self.spaceName = spaceName
    let cachePath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, [.userDomainMask], true).first!
    folderURL = URL(fileURLWithPath: cachePath).appendingPathComponent(spaceName)
  }
  
  func image(key: String, callbackQueue: DispatchQueue, completion: @escaping ActionBlock<UIImage?>) {
    queue.async {
      var filePath = self.folderURL
      filePath.appendPathComponent(String(key.hash))
      var image: UIImage?
      do {
        let data = try Data(contentsOf: filePath, options: [])
        image = UIImage(data: data)
      } catch {
        Log("Error: \(error)")
      }
      callbackQueue.async {
        completion(image)
      }
    }
  }
  
  func save(image: UIImage, for key: String) {
    queue.async(flags: .barrier) {
      
      do {
        if !self.fileManager.fileExists(atPath: self.folderURL.path, isDirectory: nil) {
          try self.fileManager.createDirectory(at: self.folderURL, withIntermediateDirectories: true, attributes: nil)
        }
      } catch {
        Log("Error: Can't create folder: \(error)")
        return
      }
      
      var filePath = self.folderURL
      filePath.appendPathComponent(String(key.hash))
      let data = image.jpegData(compressionQuality: 1.0)
      if !self.fileManager.createFile(atPath: filePath.path, contents: data, attributes: nil) {
        Log("Error Image hasn't been saved")
      }
    }
  }
}
