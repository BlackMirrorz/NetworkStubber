//
//  NetworkStubDictionaryTests.swift
//  NetworkStubberTests
//
//  Created by Josh Robbins on 3/20/25.
//

@testable import NetworkStubber
import XCTest

final class NetworkStubDictionaryTests: XCTestCase {

  func testFirstMatchingReturnsCorrectStub() {
    let url1 = URL(string: "https://api.example.com/users")!
    let url2 = URL(string: "https://api.example.com/posts")!
    let stub1 = NetworkStub(url: url1)
    let stub2 = NetworkStub(url: url2)
    let stubDictionary: [URL: NetworkStub] = [url1: stub1, url2: stub2]

    let result = stubDictionary.firstMatching(
      partialURL: URL(string: "https://api.example.com/users")!
    )

    XCTAssertEqual(
      result?.url,
      url1,
      "Expected firstMatching to return the stub with URL \(url1)"
    )
  }

  func testFirstMatchingReturnsNilForNonMatchingURL() {
    let url1 = URL(string: "https://api.example.com/users")!
    let url2 = URL(string: "https://api.example.com/posts")!
    let stub1 = NetworkStub(url: url1)
    let stub2 = NetworkStub(url: url2)
    let stubDictionary: [URL: NetworkStub] = [url1: stub1, url2: stub2]

    let result = stubDictionary.firstMatching(
      partialURL: URL(string: "https://api.example.com/comments")!
    )

    XCTAssertNil(
      result,
      "Expected firstMatching to return nil for a non-matching URL"
    )
  }

  func testStubForReturnsCorrectStub() {
    let url1 = URL(string: "https://api.example.com/users")!
    let url2 = URL(string: "https://api.example.com/posts")!
    let stub1 = NetworkStub(url: url1)
    let stub2 = NetworkStub(url: url2)
    let stubDictionary: [URL: NetworkStub] = [url1: stub1, url2: stub2]

    let result = stubDictionary.stub(for: URL(string: "https://api.example.com/users")!)

    XCTAssertEqual(
      result?.url,
      url1,
      "Expected stub(for:) to return the stub with URL \(url1)"
    )
  }

  func testStubForReturnsNilForNonMatchingURL() {
    let url1 = URL(string: "https://api.example.com/users")!
    let url2 = URL(string: "https://api.example.com/posts")!
    let stub1 = NetworkStub(url: url1)
    let stub2 = NetworkStub(url: url2)
    let stubDictionary: [URL: NetworkStub] = [url1: stub1, url2: stub2]

    let result = stubDictionary.stub(for: URL(string: "https://api.example.com/comments")!)

    XCTAssertNil(
      result,
      "Expected stub(for:) to return nil for a non-matching URL"
    )
  }

  func testFirstMatchingReturnsFirstStubWhenMultipleMatches() {
    let url1 = URL(string: "https://api.example.com/users")!
    let url2 = URL(string: "https://api.example.com/users/details")!
    let stub1 = NetworkStub(url: url1)
    let stub2 = NetworkStub(url: url2)
    let stubDictionary: [URL: NetworkStub] = [url1: stub1, url2: stub2]

    let result = stubDictionary.firstMatching(partialURL: URL(string: "https://api.example.com/users")!)

    XCTAssertEqual(
      result?.url,
      url1,
      "Expected firstMatching to return the first stub that matches the partial URL"
    )
  }
}
