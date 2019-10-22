//
//  PreviewVC.swift
//  TestTaskReddit
//
//  Created by Newcomer on 20.10.2019.
//  Copyright © 2019 Home. All rights reserved.
//

import UIKit
import Photos

class PreviewImageVC: UIViewController {
  
  var photoManager: PhotoLibraryManager!
  var imageProvider: ImageProvider!
  
  @IBOutlet weak var barNavigationItem: UINavigationItem!
  @IBOutlet weak var shareButton: UIBarButtonItem!
  @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
  @IBOutlet weak var imageView: UIImageView!
  private var image: UIImage? {
    return imageView.image
  }
  var imageURL: URL!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    barNavigationItem.title = title
    
    shareButton.isEnabled = false
    activityIndicator.startAnimating()
    
    self.imageProvider.fetchImage(url: imageURL) { result in
      assert(Thread.isMainThread)
      self.activityIndicator.stopAnimating()
      switch result {
      case .success(let image):
        self.imageView.image = image
        self.shareButton.isEnabled = true
      case .failure(let error):
        self.show(error: error)
      }
    }
    
  }
  
  // MARK: - Actions
  @IBAction func shareTapped(_ sender: UIBarButtonItem) {
    photoManager.requestPermissionIfNeeded { [weak self] result in
      guard let self = self else { return }
      guard let image = self.image else { return }
      
      switch result {
      case .success:
        self.shareButton.isEnabled = false
        self.imageView.showLoading()
        self.photoManager.saveToPhotos(image: image, isHighPriority: true) { result in
          self.imageView.hideLoading()
          self.shareButton.isEnabled = true
          switch result {
          case .success:
            Log("Image has been successfuly saved")
            self.show(message: "Image has been successfuly saved into Library")
          case .failure(let error):
            self.show(error: error)
          }
        }
      case .failure(let error):
        if case .photoPermissionDenied = error {
          self.showSettings(message: "Please enable access in Settings to save the image")
        } else {
          self.show(error: error)
        }
      }
    }
  }
  
}

extension PreviewImageVC: UINavigationBarDelegate {
  func position(for bar: UIBarPositioning) -> UIBarPosition {
    return .topAttached
  }
}
