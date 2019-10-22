//
//  PostTableCell.swift
//  TestTaskReddit
//
//  Created by Newcomer on 19.10.2019.
//  Copyright © 2019 Home. All rights reserved.
//

import UIKit

protocol PostTableCellDelegate: class {
  func cellDidTapImage(_ cell: PostTableCell)
}

class PostTableCell: UITableViewCell {
  
  @IBOutlet weak var thumbImageView: UIImageView!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var authorLabel: UILabel!
  @IBOutlet weak var commentsLabel: UILabel!
  @IBOutlet weak var postedDateLabel: UILabel!
  
  weak var delegate: PostTableCellDelegate?
  
  override func awakeFromNib() {
    super.awakeFromNib()
    let tap = UITapGestureRecognizer(target: self, action: #selector(imageTapped(_:)))
    thumbImageView.addGestureRecognizer(tap)
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    thumbImageView.hideLoading()
    thumbImageView.image = nil
    thumbImageView.isHidden = false
    titleLabel.text = nil
    authorLabel.text = nil
    commentsLabel.text = nil
    postedDateLabel.text = nil
  }
  
  @IBAction func imageTapped(_ gesture: UITapGestureRecognizer) {
    delegate?.cellDidTapImage(self)
  }
  
}
