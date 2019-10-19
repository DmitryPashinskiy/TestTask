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
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    service.fetchPosts() // stub
    
  }


}

