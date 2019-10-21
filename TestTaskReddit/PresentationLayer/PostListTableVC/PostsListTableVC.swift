//
//  PostsListTableVC.swift
//  TestTaskReddit
//
//  Created by Newcomer on 19.10.2019.
//  Copyright © 2019 Home. All rights reserved.
//

import UIKit

class PostsListTableVC: UITableViewController {

  var router: PostsListRouter!
  var service: PostService!
  var imageProvider: ImageProvider!
  
  private weak var loadingOperation: NetworkOperation?
  
  private var posts: [Post] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
    fetchPosts()
  }
  
  func loadMore() {
    fetchPosts(after: posts.last)
  }
  
  func fetchPosts(after: Post? = nil) {
    guard loadingOperation == nil else {
      Log("Loading posts operation is in progress already")
      return
    }
    
    loadingOperation = service.fetchPosts(after: after) { [weak self] result in
      guard let self = self else { return }
      switch result {
      case .success(let posts):
        self.posts.append(contentsOf: posts)
        self.tableView.reloadData()
      case .failure(let error):
        self.show(error: error)
      }
    }
  }
  
  
  // MARK: - TableViewDataSource & TableViewDelegate
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return posts.count + 1
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    if indexPath.row == posts.count {
      let loadCell = tableView.dequeueReusableCell(withIdentifier: "LoadTableCell", for: indexPath)
      return loadCell
    }
    
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
      cell.thumbImageView.showLoading()
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
        cell.thumbImageView.hideLoading()
        cell.thumbImageView.image = image
      }
    } else {
      cell.thumbImageView.isHidden = true
    }

    return cell
  }
  
  override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    if indexPath.row == posts.count {
      loadMore()
    }
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    let post = posts[indexPath.row]
    guard post.imageURL.isHTTP else {
      return
    }
    
    let url: URL
    // imgur api is not supported in current version, use thumbnail instead
    if ["i.redd.it"].contains(post.imageURL.host) {
      url = post.imageURL
    } else if post.thumbnail.isHTTP {
      url = post.thumbnail
    } else {
      return
    }
    
    router.showPreviewImage(imageURL: url, title: post.author)
  }
  
}
