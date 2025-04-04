//
//  NetworkStubberPredicateTests.swift
//  NetworkStubber
//
//  Created by Josh Robbins on 4/3/25.
//

@testable import NetworkStubberPackage
import XCTest

final class NetworkStubPredicateTests: XCTestCase {

  // MARK: - Always True/False

  func testAlwaysTruePredicate() {
    let predicate = NetworkStubPredicate.alwaysTrue
    let request = URLRequest(url: URL(string: "https://example.com")!)

    XCTAssertTrue(
      predicate.evaluate(request),
      "Should always return true"
    )
    XCTAssertFalse(
      !predicate.evaluate(request),
      "Negation should be false"
    )
  }

  func testAlwaysFalsePredicate() {
    let predicate = NetworkStubPredicate.alwaysFalse
    let request = URLRequest(url: URL(string: "https://example.com")!)

    XCTAssertFalse(
      predicate.evaluate(request),
      "Should always return false"
    )
    XCTAssertTrue(
      !predicate.evaluate(request),
      "Negation should be true"
    )
  }

  // MARK: - Logical Operators

  func testLogicalOrPredicate() {
    let truePredicate = NetworkStubPredicate.alwaysTrue
    let falsePredicate = NetworkStubPredicate.alwaysFalse
    let combined = falsePredicate || truePredicate

    XCTAssertTrue(
      combined.evaluate(URLRequest(url: URL(string: "https://example.com")!)),
      "OR should return true"
    )

    let doubleFalse = falsePredicate || falsePredicate

    XCTAssertFalse(
      doubleFalse.evaluate(URLRequest(url: URL(string: "https://example.com")!)),
      "OR of two false should be false"
    )
  }

  func testLogicalAndPredicate() {
    let truePredicate = NetworkStubPredicate.alwaysTrue
    let falsePredicate = NetworkStubPredicate.alwaysFalse
    let combined = falsePredicate && truePredicate

    XCTAssertFalse(
      combined.evaluate(URLRequest(url: URL(string: "https://example.com")!)),
      "AND should return false"
    )

    let doubleTrue = truePredicate && truePredicate

    XCTAssertTrue(
      doubleTrue.evaluate(URLRequest(url: URL(string: "https://example.com")!)),
      "AND of two true should be true"
    )
  }

  func testLogicalNotPredicate() {
    let falsePredicate = NetworkStubPredicate.alwaysFalse
    let notFalse = !falsePredicate

    XCTAssertTrue(
      notFalse.evaluate(URLRequest(url: URL(string: "https://example.com")!)),
      "NOT FALSE should return true"
    )

    let truePredicate = NetworkStubPredicate.alwaysTrue
    let notTrue = !truePredicate

    XCTAssertFalse(
      notTrue.evaluate(URLRequest(url: URL(string: "https://example.com")!)),
      "NOT TRUE should return false"
    )
  }

  // MARK: - HTTP Method & Headers

  func testIsHTTPMethod() {
    var request = URLRequest(url: URL(string: "https://example.com")!)
    request.httpMethod = "POST"

    let predicate = NetworkStubPredicate.isHTTPMethod(.post)

    XCTAssertTrue(
      predicate.evaluate(request),
      "Should match HTTP method POST"
    )
    request.httpMethod = "GET"

    XCTAssertFalse(
      predicate.evaluate(request),
      "Should not match HTTP method GET"
    )
  }

  func testHasHeaderField() {
    var request = URLRequest(url: URL(string: "https://example.com")!)
    request.setValue("123", forHTTPHeaderField: "Authorization")
    let predicate = NetworkStubPredicate.hasHeaderField(name: "Authorization")

    XCTAssertTrue(
      predicate.evaluate(request),
      "Should detect header field"
    )

    XCTAssertFalse(
      NetworkStubPredicate.hasHeaderField(name: "X-Unknown").evaluate(request),
      "Should not detect missing header"
    )
  }

  func testHasHeaderFieldWithValue() {
    var request = URLRequest(url: URL(string: "https://example.com")!)
    request.setValue("Bearer token", forHTTPHeaderField: "Authorization")

    let predicate = NetworkStubPredicate.hasHeaderField(name: "Authorization", value: "Bearer token")

    XCTAssertTrue(
      predicate.evaluate(request),
      "Should match header field and value"
    )

    let failPredicate = NetworkStubPredicate.hasHeaderField(name: "Authorization", value: "Invalid")

    XCTAssertFalse(
      failPredicate.evaluate(request),
      "Should not match incorrect header value"
    )
  }

  func testHeaderFieldMatches() {
    var request = URLRequest(url: URL(string: "https://example.com")!)
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")

    let predicate = NetworkStubPredicate.headerFieldMatches(name: "Content-Type", pattern: "json")

    XCTAssertTrue(
      predicate.evaluate(request),
      "Should match regex pattern"
    )

    let failPredicate = NetworkStubPredicate.headerFieldMatches(name: "Content-Type", pattern: "xml")

    XCTAssertFalse(
      failPredicate.evaluate(request),
      "Should not match incorrect regex pattern"
    )
  }

  // MARK: - URL Matching

  func testIsURL() {
    let url = URL(string: "https://example.com/test")!
    let request = URLRequest(url: url)

    let predicate = NetworkStubPredicate.isURL(url)

    XCTAssertTrue(
      predicate.evaluate(request),
      "Should match exact URL"
    )
    let failPredicate = NetworkStubPredicate.isURL(URL(string: "https://wrong.com")!)

    XCTAssertFalse(
      failPredicate.evaluate(request),
      "Should not match different URL"
    )
  }

  func testIsHost() {
    let url = URL(string: "https://api.example.com/path")!
    let request = URLRequest(url: url)

    let predicate = NetworkStubPredicate.isHost("api.example.com")

    XCTAssertTrue(
      predicate.evaluate(request),
      "Should match host"
    )
    XCTAssertFalse(
      NetworkStubPredicate.isHost("example.com").evaluate(request),
      "Should not match incorrect host"
    )
  }

  func testIsPath() {
    let url = URL(string: "https://api.example.com/test/path")!
    let request = URLRequest(url: url)

    let predicate = NetworkStubPredicate.isPath("/test/path")

    XCTAssertTrue(
      predicate.evaluate(request),
      "Should match path"
    )
    XCTAssertFalse(
      NetworkStubPredicate.isPath("/wrong").evaluate(request),
      "Should not match incorrect path"
    )
  }

  func testIsURLString() {
    let url = URL(string: "https://example.com/test")!
    let request = URLRequest(url: url)

    let predicate = NetworkStubPredicate.isURLString("https://example.com/test")
    XCTAssertTrue(
      predicate.evaluate(request),
      "Should match full URL string"
    )

    let failPredicate = NetworkStubPredicate.isURLString("https://wrong.com")
    XCTAssertFalse(
      failPredicate.evaluate(request),
      "Should not match incorrect URL string"
    )
  }

  // MARK: - Path Analysis

  func testHasPathPrefix() {
    let url = URL(string: "https://example.com/api/v1/resource")!
    let request = URLRequest(url: url)

    let predicate = NetworkStubPredicate.hasPathPrefix("/api")
    XCTAssertTrue(
      predicate.evaluate(request),
      "Should match path prefix"
    )

    let failPredicate = NetworkStubPredicate.hasPathPrefix("/wrong")
    XCTAssertFalse(
      failPredicate.evaluate(request),
      "Should not match incorrect path prefix"
    )
  }

  func testHasPathSuffix() {
    let url = URL(string: "https://example.com/api/resource.json")!
    let request = URLRequest(url: url)

    let predicate = NetworkStubPredicate.hasPathSuffix("resource.json")
    XCTAssertTrue(
      predicate.evaluate(request),
      "Should match path suffix"
    )

    let failPredicate = NetworkStubPredicate.hasPathSuffix("wrong.json")
    XCTAssertFalse(
      failPredicate.evaluate(request),
      "Should not match incorrect path suffix"
    )
  }

  func testHasPathExtension() {
    let url = URL(string: "https://example.com/file.json")!
    let request = URLRequest(url: url)

    let predicate = NetworkStubPredicate.hasPathExtension("json")
    XCTAssertTrue(
      predicate.evaluate(request),
      "Should match path extension"
    )

    let failPredicate = NetworkStubPredicate.hasPathExtension("xml")
    XCTAssertFalse(
      failPredicate.evaluate(request),
      "Should not match incorrect path extension"
    )
  }

  func testHasLastPathComponent() {
    let url = URL(string: "https://example.com/path/to/file.txt")!
    let request = URLRequest(url: url)

    let predicate = NetworkStubPredicate.hasLastPathComponent("file.txt")
    XCTAssertTrue(
      predicate.evaluate(request),
      "Should match last path component"
    )

    let failPredicate = NetworkStubPredicate.hasLastPathComponent("wrong.txt")
    XCTAssertFalse(
      failPredicate.evaluate(request),
      "Should not match incorrect last path component"
    )
  }

  func testContainsQueryItems() {
    let url = URL(string: "https://example.com?foo=bar&baz=qux")!
    let request = URLRequest(url: url)
    let predicate = NetworkStubPredicate.containsQueryItems([
      URLQueryItem(name: "foo", value: "bar"),
      URLQueryItem(name: "baz", value: "qux")
    ])

    XCTAssertTrue(
      predicate.evaluate(request),
      "Should match query items"
    )

    let failPredicate = NetworkStubPredicate.containsQueryItems([
      URLQueryItem(name: "foo", value: "bar"),
      URLQueryItem(name: "missing", value: "none")
    ])

    XCTAssertFalse(
      failPredicate.evaluate(request),
      "Should not match missing query item"
    )
  }
}
