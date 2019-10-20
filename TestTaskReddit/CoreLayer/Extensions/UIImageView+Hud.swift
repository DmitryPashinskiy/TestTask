//
//  UIImageView+Hud.swift
//  TestTaskReddit
//
//  Created by Newcomer on 20.10.2019.
//  Copyright © 2019 Home. All rights reserved.
//

import UIKit

private let activityIndicatorTag = -5050

extension UIImageView {
  
  private func getCurrentActivityIndicator() -> UIActivityIndicatorView? {
    return subviews.first { $0.tag == activityIndicatorTag } as? UIActivityIndicatorView
  }
  
  func showLoading(style: UIActivityIndicatorView.Style = .large) {
    if let activityIndicator = getCurrentActivityIndicator() {
      activityIndicator.startAnimating()
      return
    }
    
    let activityIndicator = UIActivityIndicatorView(style: style)
    activityIndicator.tag = activityIndicatorTag
    activityIndicator.hidesWhenStopped = true
    activityIndicator.translatesAutoresizingMaskIntoConstraints = false
    addSubview(activityIndicator)
    
    
    let centerX = activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor)
    let centerY = activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor)
    
    NSLayoutConstraint.activate([centerX, centerY])
    
    activityIndicator.startAnimating()
  }
  
  func hideLoading() {
    getCurrentActivityIndicator()?.stopAnimating()
  }
  
}

