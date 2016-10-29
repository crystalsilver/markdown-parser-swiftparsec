//
//  MarkdownKitTests.swift
//  MarkdownKitTests
//
//  Created by James Smith on 10/3/16.
//  Copyright © 2016 James Smith. All rights reserved.
//

import XCTest
import SwiftParsec
import Foundation
@testable import MarkdownKit

final class MarkdownKitTests: XCTestCase {

  override func setUp() {
    
  }
  
  func testParser() {
    let markdown = string(fromMarkdownFileNamed: "basic")
    do {
      let result = try markdownParser.run(userState: (), sourceName: "", input: markdown)
      let expectedResult: [Markdown] = [
        .header(level: 1, text: "Hello"),
        .paragraph("world"),
        .thematicBreak,
        .header(level: 2, text: "Numbers"),
        .orderedList(["one", "two", "three"]),
        .header(level: 2, text: "More Numbers"),
        .orderedList(["one", "two", "three"]),
        .header(level: 2, text: "Letters"),
        .unorderedList(["a", "b", "c"])
      ]
      
      XCTAssertEqual(result, expectedResult)
    }
    catch let error as ParseError {
      print(error.description)
      XCTFail(error.description)
    }
    catch {
      XCTFail("Unknown error")
    }
  }
  
  private func string(fromMarkdownFileNamed fileName: String) -> String {
    let bundle = Bundle(for: type(of: self))
    guard let url = bundle.url(forResource: "basic", withExtension: "md") else {
      fatalError("could not find \(fileName).md")
    }
    return try! String(contentsOf: url)
  }
  
}
