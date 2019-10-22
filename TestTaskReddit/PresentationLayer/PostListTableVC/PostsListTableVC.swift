//
//  PostsListTableVC.swift
//  TestTaskReddit
//
//  Created by Newcomer on 19.10.2019.
//  Copyright © 2019 Home. All rights reserved.
//

import UIKit

class PostsListTableVC: UITableViewController {

  struct State {
    var offset: CGPoint = .zero
    var lastPost: Post?
  }
  
  var router: PostsListRouter!
  var service: PostService!
  var imageProvider: ImageProvider!
  
  var state = State()
  
  private weak var loadingOperation: NetworkOperation?
  
  private var posts: [Post] = []
  
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupRefresher()
    Log(state)
    
    if let post = state.lastPost, state.offset != .zero {
      fetchCachedPosts()
    } else {
      reloadPosts()
    }
    
  }
  
  func setupRefresher() {
    refreshControl = UIRefreshControl()
    refreshControl?.addTarget(self, action: #selector(refreshPulled), for: .valueChanged)
  }
  
  @objc func refreshPulled() {
    reloadPosts()
  }
  
  private func reloadPosts() {
    service.removeCache()
    loadingOperation = service.fetchPosts() { [weak self] result in
      guard let self = self else { return }
      self.refreshControl?.endRefreshing()
      switch result {
      case .success(let posts):
        self.posts = posts
        self.tableView.reloadData()
      case .failure(let error):
        self.show(error: error)
      }
    }
  }
  
  private func loadMore() {
    fetchPosts(after: posts.last)
  }
  
  private func fetchCachedPosts() {
    service.fetchCachedPosts { [weak self] result in
      guard let self = self else { return }
      switch result {
      case .success(let posts):
        self.posts.append(contentsOf: posts)
        self.tableView.reloadData()
        self.tableView.setContentOffset(self.state.offset, animated: false)
      case .failure(let error):
        self.show(error: error)
      }
    }
  }
  
  private func fetchPosts(after: Post? = nil) {
    guard loadingOperation == nil else {
      Log("Loading posts operation is in progress already")
      return
    }
    
    loadingOperation = service.fetchPosts(after: after) { [weak self] result in
      guard let self = self else { return }
      self.refreshControl?.endRefreshing()
      switch result {
      case .success(let posts):
        self.posts.append(contentsOf: posts)
        self.tableView.reloadData()
      case .failure(let error):
        self.show(error: error)
      }
    }
  }
  
  
  // MARK: - UIStateRestoring
  
  override func encodeRestorableState(with coder: NSCoder) {
    let key = String(describing: State.self)
    coder.encode(state, forKey: key)
    super.encodeRestorableState(with: coder)
    Log(#function)
  }
  
  override func decodeRestorableState(with coder: NSCoder) {
    let key = String(describing: State.self)
    if let state = coder.decodeObject(forKey: key) as? State {
      self.state = state
    }
    super.decodeRestorableState(with: coder)
    Log(#function)
  }
  
  override func applicationFinishedRestoringState() {
    Log(#function)
  }
  
  func setup(activity: NSUserActivity) {
    if let offsetY = activity.userInfo?["offsetY"] as? CGFloat {
      state.offset.y = offsetY
    }
    
    if let postData = activity.userInfo?["postData"] as? Data {
      let post = try? JSONDecoder().decode(Post.self, from: postData)
      state.lastPost = post
    }
    
  }
  
  func getActivity() -> NSUserActivity {
    let activity = NSUserActivity.init(activityType: "restoration")
    activity.userInfo = ["state": state]
    return activity
  }
  
  // MARK: - TableViewDataSource & TableViewDelegate
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return posts.isEmpty ? 0 : posts.count + 1
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
      DispatchQueue.main.async {
        self.loadMore()
      }
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


extension PostsListTableVC: UIViewControllerRestoration {
  static func viewController(withRestorationIdentifierPath identifierComponents: [String], coder: NSCoder) -> UIViewController? {
    return UIViewController()
  }
}

extension PostsListTableVC: StateRestorationActivityProvider {
  func stateRestorationActivity() -> NSUserActivity? {
    Log("")
    
    state.lastPost = posts.last
    state.offset = tableView.contentOffset
    
    let activity = NSUserActivity(activityType: "restoration")
    
    var info: [String: Any] = [:]
    info["offsetY"] = state.offset.y
    Log(state.offset)
    if let post = state.lastPost {
      info["postData"] = try! JSONEncoder().encode(post)
    }
    activity.persistentIdentifier = "feed"
    
    activity.addUserInfoEntries(from: info)
    Log(activity)
    return activity
  }
}
