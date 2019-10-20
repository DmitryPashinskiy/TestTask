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
}
