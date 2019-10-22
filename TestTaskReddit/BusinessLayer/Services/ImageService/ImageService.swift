//
//  ImageProvider.swift
//  TestTaskReddit
//
//  Created by Newcomer on 19.10.2019.
//  Copyright © 2019 Home. All rights reserved.
//

import UIKit

typealias ImageResult = Result<UIImage, Error>

protocol ImageService {
  
  /// Fetches Image
  ///
  /// Fetches image from local storage at specified `url`. If there is no such image
  /// `ImageProvider` will make a network request to get it and then will save it into the local storage
  /// - Parameter completion: will be invoked asynchronous when image will be fetched
  func fetchImage(url: URL, completion: @escaping ActionBlock<ImageResult>)
}
