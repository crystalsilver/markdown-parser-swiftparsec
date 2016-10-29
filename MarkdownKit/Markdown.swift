//
//  Markdown.swift
//  markdown-parser
//
//  Created by James Smith on 10/3/16.
//  Copyright © 2016 James Smith. All rights reserved.
//

// Reference: http://spec.commonmark.org/0.26
// Test Playground: http://spec.commonmark.org/dingus

import Foundation
import SwiftParsec

enum Markdown: Equatable {
  case header(level: Int, text: String)
  case paragraph(String)
  case unorderedList([String])
  case orderedList([String])
  case thematicBreak // usually a horizontal rule
}

func == (lhs: Markdown, rhs: Markdown) -> Bool {
  switch (lhs, rhs) {
  case let (.header(h1), .header(h2)): return h1 == h2
  case let(.paragraph(b1), .paragraph(b2)): return b1 == b2
  case let (.unorderedList(l1), .unorderedList(l2)): return l1 == l2
  case let (.orderedList(l1), .orderedList(l2)): return l1 == l2
  case (.thematicBreak, .thematicBreak): return true
  default: return false
  }
}

// MARK: - Parser
let markdownElement = thematicBreak <|> orderedList <|> unorderedList <|> header <|> paragraph
let markdownParser = markdownElement.separatedBy(endOfLine.many)

// MARK: - Markdown Elements

// Header
let headerLevel = { $0.count } <^> character("#").many1 <* space
let header = headerLevel >>- { level in
  { Markdown.header(level: level, text: $0) } <^> line <* endOfLine
}

// Paragraph
let paragraph = line.map(Markdown.paragraph) <* endOfLine

// Unordered List
let unorderedListItem = unordedListSymbol *> space *> line <* endOfLine
let unorderedList = unorderedListItem.attempt.many1.map(Markdown.unorderedList)

// Ordered List
let orderedListItem = number *> character(".") *> space *> line <* endOfLine
let orderedList = orderedListItem.attempt.many1.map(Markdown.orderedList)

// Thematic Break
let thematicBreakTail = StringParser.oneOf("-_* ").many
let thematicBreak = ({ Markdown.thematicBreak } <^> thematicBreakSymbol <* thematicBreakTail <* endOfLine).attempt

// MARK: - Markdown Symbols
let thematicBreakCharacter = character("-") <|> character("_") <|> character("*")
let thematicBreakSymbol = thematicBreakCharacter.manyN(3).discard
let unordedListSymbol = character("*") <|> character("-") <|> character("+")

// MARK: - Utils
let character: (Character) -> StringParser = StringParser.character
let number = StringParser.digit.many1.stringValue.map { Int($0) ?? 1 }
let space = character(" ")
let line = StringParser.noneOf("\n").many1.stringValue
let endOfLine = StringParser.string("\n")

extension GenericParser {
  // Like many1, except parses at least *n* elements
  func manyN(_ n: Int) -> GenericParser<StreamType, UserState, [Result]> {
    return many.attempt.flatMap { results in
      if results.count >= n {
        return GenericParser<StreamType, UserState, [Result]>(result: results)
      }
      return GenericParser<StreamType, UserState, [Result]>.fail("Parsed \(results.count)/\(n))")
    }
  }
}
