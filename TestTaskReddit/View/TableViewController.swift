//
//  ViewController.swift
//  TestTaskReddit
//
//  Created by Newcomer on 19.10.2019.
//  Copyright © 2019 Home. All rights reserved.
//

import UIKit

private let dateFormatter: DateFormatter = {
  var formatter = DateFormatter()
  formatter.dateStyle = .full
  return formatter
}()

class TableViewController: UITableViewController {

  var service = PostService()
  var imageProvider: ImageProvider = ImageProviderImpl(storage: ImageStorageImpl(),
                                                     networkManager: NetworkManagerImpl())
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
    
    let finalDate = Date().timeIntervalSince(post.createdDate)
    
    let minute: TimeInterval = 60
    let hour: TimeInterval = 60 * minute
    let day: TimeInterval = 24 * hour
    
    let postedDateText: String
    switch finalDate {
    case 0..<hour:
      postedDateText = "recently"
    case hour..<day:
      postedDateText = "\(Int(finalDate / hour)) hours ago"
      
    default:
      let day = finalDate / day
      let dayInt = Int(day)
      postedDateText = "\(dayInt) days ago"
    }

    cell.authorLabel.text = "Posted by \(post.author) \(postedDateText)"
    cell.titleLabel.text = post.title
    cell.commentsLabel.text = "\(post.commentsAmount) Comments"
    
    if post.thumbnail.isHTTP {
      let thumbnail = post.thumbnail
      imageProvider.fetchImage(url: post.thumbnail) { result in
        guard case let .success(image) = result else {
          return
        }
        // Check whether the post exists at the same indexPath or no
        guard let cell = tableView.cellForRow(at: indexPath) as? PostTableCell,
          indexPath.row < self.posts.count,
          self.posts[indexPath.row].thumbnail == thumbnail else {
            return
        }
        cell.thumbImageView.image = image
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
