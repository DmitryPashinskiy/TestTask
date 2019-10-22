//
//  UIViewController+Utilities.swift
//  TestTaskReddit
//
//  Created by Newcomer on 20.10.2019.
//  Copyright © 2019 Home. All rights reserved.
//

import UIKit

extension UIViewController {
  func show(error: Error) {
    let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
    alert.addAction(.init(title: "OK", style: .cancel, handler: nil))
    present(alert, animated: true, completion: nil)
  }
  
  func show(message: String) {
    let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
    alert.addAction(.init(title: "OK", style: .default, handler: nil))
    present(alert, animated: true, completion: nil)
  }
  
  func showSettings(message: String) {
    let alertController = UIAlertController(title: nil,
                                            message: message,
                                            preferredStyle: .alert)
    
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
    
    let settingsAction = UIAlertAction(title: "Settings", style: .default) { action in
      guard let url = URL(string: UIApplication.openSettingsURLString) else {
        assertionFailure("`UIApplication.openSettingsURLString` doesn't provide a correct url anymore")
        return
      }
      UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    alertController.addAction(cancelAction)
    alertController.addAction(settingsAction)
    
    self.present(alertController, animated: true, completion: nil)
  }
}
