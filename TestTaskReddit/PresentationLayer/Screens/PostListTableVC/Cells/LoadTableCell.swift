//
//  LoadTableCell.swift
//  TestTaskReddit
//
//  Created by Newcomer on 20.10.2019.
//  Copyright © 2019 Home. All rights reserved.
//

import UIKit

class LoadTableCell: UITableViewCell {
  
  @IBOutlet var activityView: UIActivityIndicatorView!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    activityView.startAnimating()
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    activityView.startAnimating()
  }
  
}
