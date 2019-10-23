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
  var imageService: ImageService!
  
  private weak var loadingOperation: NetworkOperation? // it should be CancellableOperation
  
  private var posts: [Post] = []
  private var expectedRow: Int?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupRefresher()
    
    if expectedRow != nil {
      fetchCachedPosts()
    } else {
      reloadPosts()
    }
    
  }
  
  func configure(activity: NSUserActivity) {
    guard let row = activity.userInfo?["row"] as? Int else {
      return
    }
    expectedRow = row
  }

  // MARK: - TableViewDataSource & TableViewDelegate
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return posts.isEmpty ? 0 : posts.count + 1
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    /// Infinite scroll
    if indexPath.row == posts.count {
      let loadCell = tableView.dequeueReusableCell(withIdentifier: String(describing: LoadTableCell.self), for: indexPath)
      return loadCell
    }
    
    let identifier = String(describing: PostTableCell.self)
    guard let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? PostTableCell else {
      fatalError("There is no such cell with identifier \(identifier)")
    }
    
    configure(cell: cell, at: indexPath)

    return cell
  }
  
  override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    if indexPath.row == posts.count {
        self.loadMore()
    }
  }
  
  func configure(cell: PostTableCell, at indexPath: IndexPath) {
    let post = posts[indexPath.row]

    cell.topLabel.text = "Posted by \(post.author) \(post.createdTimeAgo)"
    cell.titleLabel.text = post.title
    cell.commentsLabel.text = "\(post.commentsAmount) Comments"
    
    cell.delegate = self
    
    if post.thumbnail.isHTTP {
      let thumbnail = post.thumbnail
      cell.thumbImageView.showLoading()
      imageService.fetchImage(url: post.thumbnail) { [weak self] result in
        guard let self = self else { return }
        cell.thumbImageView.hideLoading()
        
        guard case let .success(image) = result else {
          return
        }
        // Check whether the post exists at the same indexPath or no
        guard let cell = self.tableView.cellForRow(at: indexPath) as? PostTableCell,
          indexPath.row < self.posts.count,
          self.posts[indexPath.row].thumbnail == thumbnail else {
            return
        }
        
        cell.thumbImageView.image = image
      }
    } else {
      cell.thumbImageView.isHidden = true
    }
  }
  
  // MARK: - Actions
  
  @objc func refreshPulled() {
    reloadPosts()
  }
  
}


private extension PostsListTableVC {
  func setupRefresher() {
    refreshControl = UIRefreshControl()
    refreshControl?.addTarget(self, action: #selector(refreshPulled), for: .valueChanged)
  }
  
  private func reloadPosts() {
    
    guard loadingOperation == nil else {
      Log("Loading posts operation is in progress already")
      return
    }
    
    service.wipeCache()
    refreshControl?.beginRefreshing()
    loadingOperation = service.fetchPosts() { [weak self] result in
      guard let self = self else { return }
      self.refreshControl?.endRefreshing()
      self.posts = []
      self.handlePostsResult(result)
    }
  }
  
  private func fetchCachedPosts() {
    refreshControl?.beginRefreshing()
    service.fetchCachedPosts { [weak self] result in
      guard let self = self else { return }
      self.refreshControl?.endRefreshing()
      self.handlePostsResult(result)
      self.scrollIfNeeded()
    }
  }
  
  private func fetchPosts(after: Post? = nil) {
    guard loadingOperation == nil else {
      Log("Loading posts operation is in progress already")
      return
    }
    
    loadingOperation = service.fetchPosts(after: after) { [weak self] result in
      guard let self = self else { return }
      self.handlePostsResult(result)
    }
  }

  private func loadMore() {
    fetchPosts(after: posts.last)
  }
  
  private func scrollIfNeeded() {
    if let row = expectedRow {
      tableView.scrollToRow(at: IndexPath(row: row, section: 0), at: .top, animated: true)
      expectedRow = nil
    }
  }
  
  private func handlePostsResult(_ result: Result<[Post], Error>) {
    switch result {
    case .success(let posts):
      self.posts.append(contentsOf: posts)
      self.tableView.reloadData()
    case .failure(let error):
      self.show(error: error)
    }
  }
  
}


// MARK: - StateRestorationActivityProvider
extension PostsListTableVC: StateRestorationActivityProvider {
  func stateRestorationActivity() -> NSUserActivity? {
    // preventing saving state if current page is not visible
    guard self.view.window != nil else {
      return nil
    }
    
    let activity = router.restorationActivity()
    guard let row = tableView.indexPathsForVisibleRows?.first?.row else {
      return nil
    }
    activity.addUserInfoEntries(from: ["row": row])
    return activity
  }
}


// MARK: - PostTableCellDelegate
extension PostsListTableVC: PostTableCellDelegate {
  func cellDidTapImage(_ cell: PostTableCell) {
    guard let indexPath = tableView.indexPath(for: cell) else {
      return
    }
    
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
