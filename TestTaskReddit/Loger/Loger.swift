//
//  Loger.swift
//  TestTaskReddit
//
//  Created by Newcomer on 19.10.2019.
//  Copyright © 2019 Home. All rights reserved.
//

import Foundation

private var dateFormatter: DateFormatter = {
  var formatter = DateFormatter()
  formatter.timeStyle = .medium
  formatter.dateStyle = .none
  return formatter
}()

func Log(_ info: Any, _ file: String = #file, _ function: String = #function, _ line: Int = #line) {
  Loger.instance.log(info: info, file: file, function: function, line: line)
}

class Loger {
  static let instance = Loger()
  
  func log(info: Any, file: String = #file, function: String = #function, line: Int = #line) {
    let fileName = URL(string: file)?.lastPathComponent ?? file
    let dateString = dateFormatter.string(from: Date())
    print(dateString, fileName, function, "line: \(line)", info, separator: "| ")
  }
  
}
