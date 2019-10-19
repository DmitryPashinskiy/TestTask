//
//  ViewController.swift
//  TestTaskReddit
//
//  Created by Newcomer on 19.10.2019.
//  Copyright © 2019 Home. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {

  var service = PostService()
  var posts: [Post] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
    service.fetchPosts { [weak self] result in
      guard let self = self else { return }
      switch result {
      case .success(let posts):
        self.posts = posts
        self.tableView.reloadData()
      case .failure(let error):
        self.show(error: error)
      }
    }
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return posts.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let identifier = "PostTableCell"
    guard let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? PostTableCell else {
      fatalError("There is no such cell with identifier \(identifier)")
    }
    let post = posts[indexPath.row]
    
    cell.authorLabel.text = post.author
    cell.titleLabel.text = post.title
    cell.commentsLabel.text = "\(post.commentsAmount) Comments"
    cell.postedDateLabel.text = "3 hours ago"
    DispatchQueue.global().async {
      let data = try? Data(contentsOf: post.thumbnail)
      let image = data.flatMap { UIImage(data: $0) }
      DispatchQueue.main.async {
        cell.thumbImageView?.image = image
        cell.setNeedsLayout()
      }
    }
    
    return cell
  }
  

}

extension UIViewController {
  func show(error: Error) {
    let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
    alert.addAction(.init(title: "OK", style: .cancel, handler: nil))
    present(alert, animated: true, completion: nil)
  }
}
