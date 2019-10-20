//
//  PostTableCell.swift
//  TestTaskReddit
//
//  Created by Newcomer on 19.10.2019.
//  Copyright © 2019 Home. All rights reserved.
//

import UIKit

class PostTableCell: UITableViewCell {
  
  @IBOutlet weak var thumbImageView: UIImageView!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var authorLabel: UILabel!
  @IBOutlet weak var commentsLabel: UILabel!
  @IBOutlet weak var postedDateLabel: UILabel!
  
  override func prepareForReuse() {
    super.prepareForReuse()
    thumbImageView.image = nil
    titleLabel.text = nil
    authorLabel.text = nil
    commentsLabel.text = nil
    postedDateLabel.text = nil
  }
  
}
