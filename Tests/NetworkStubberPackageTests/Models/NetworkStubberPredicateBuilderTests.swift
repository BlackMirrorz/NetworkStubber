//
//  NetworkStubberPredicateBuilderTests.swift
//  NetworkStubber
//
//  Created by Josh Robbins on 4/3/25.
//

@testable import NetworkStubberPackage
import XCTest

final class NetworkStubPredicateBuilderTests: XCTestCase {

  func testMethodBuilder() {
    let request = URLRequest(url: URL(string: "https://example.com")!)
    var postRequest = request
    postRequest.httpMethod = "POST"

    let predicate = NetworkStubPredicateBuilder()
      .method(.post)
      .build()

    XCTAssertTrue(
      predicate.evaluate(postRequest),
      "Should match HTTP method POST"
    )

    XCTAssertFalse(
      predicate.evaluate(request),
      "Should not match when method is missing"
    )
  }

  func testHeaderNameBuilder() {
    var request = URLRequest(url: URL(string: "https://example.com")!)
    request.setValue("value", forHTTPHeaderField: "X-Test")

    let predicate = NetworkStubPredicateBuilder()
      .header("X-Test")
      .build()

    XCTAssertTrue(
      predicate.evaluate(request),
      "Should detect header presence"
    )

    XCTAssertFalse(
      predicate.evaluate(URLRequest(url: request.url!)),
      "Should fail when header is missing"
    )
  }

  func testHeaderNameAndValueBuilder() {
    var request = URLRequest(url: URL(string: "https://example.com")!)
    request.setValue("token", forHTTPHeaderField: "Authorization")

    let predicate = NetworkStubPredicateBuilder()
      .header("Authorization", equals: "token")
      .build()

    XCTAssertTrue(
      predicate.evaluate(request),
      "Should match header name and value"
    )

    request.setValue("wrong", forHTTPHeaderField: "Authorization")

    XCTAssertFalse(
      predicate.evaluate(request),
      "Should not match incorrect header value"
    )
  }

  func testURLBuilder() {
    let url = URL(string: "https://example.com/api")!
    let predicate = NetworkStubPredicateBuilder()
      .url(url)
      .build()

    XCTAssertTrue(
      predicate.evaluate(URLRequest(url: url)),
      "Should match exact URL"
    )

    XCTAssertFalse(
      predicate.evaluate(URLRequest(url: URL(string: "https://wrong.com")!)),
      "Should not match wrong URL"
    )
  }

  func testURLStringBuilder() {
    let predicate = NetworkStubPredicateBuilder()
      .urlString("https://example.com/api")
      .build()

    XCTAssertTrue(
      predicate.evaluate(URLRequest(url: URL(string: "https://example.com/api")!)),
      "Should match full URL string"
    )

    XCTAssertFalse(
      predicate.evaluate(URLRequest(url: URL(string: "https://example.com/other")!)),
      "Should not match incorrect URL string"
    )
  }

  func testHostBuilder() {
    let predicate = NetworkStubPredicateBuilder()
      .host("api.example.com")
      .build()

    XCTAssertTrue(
      predicate.evaluate(URLRequest(url: URL(string: "https://api.example.com/test")!)),
      "Should match host"
    )

    XCTAssertFalse(
      predicate.evaluate(URLRequest(url: URL(string: "https://wrong.com")!)),
      "Should not match incorrect host"
    )
  }

  func testPathBuilder() {
    let predicate = NetworkStubPredicateBuilder()
      .path("/test")
      .build()

    XCTAssertTrue(
      predicate.evaluate(URLRequest(url: URL(string: "https://example.com/test")!)),
      "Should match path"
    )

    XCTAssertFalse(
      predicate.evaluate(URLRequest(url: URL(string: "https://example.com/other")!)),
      "Should not match incorrect path"
    )
  }

  func testPathPrefixBuilder() {
    let predicate = NetworkStubPredicateBuilder()
      .pathPrefix("/api")
      .build()

    XCTAssertTrue(
      predicate.evaluate(URLRequest(url: URL(string: "https://example.com/api/v1")!)),
      "Should match path prefix"
    )

    XCTAssertFalse(
      predicate.evaluate(URLRequest(url: URL(string: "https://example.com/foo")!)),
      "Should not match incorrect path prefix"
    )
  }

  func testPathSuffixBuilder() {
    let predicate = NetworkStubPredicateBuilder()
      .pathSuffix(".json")
      .build()

    XCTAssertTrue(
      predicate.evaluate(URLRequest(url: URL(string: "https://example.com/file.json")!)),
      "Should match path suffix"
    )

    XCTAssertFalse(
      predicate.evaluate(URLRequest(url: URL(string: "https://example.com/file.xml")!)),
      "Should not match incorrect path suffix"
    )
  }

  func testPathExtensionBuilder() {
    let predicate = NetworkStubPredicateBuilder()
      .pathExtension("json")
      .build()

    XCTAssertTrue(
      predicate.evaluate(URLRequest(url: URL(string: "https://example.com/file.json")!)),
      "Should match path extension"
    )

    XCTAssertFalse(
      predicate.evaluate(URLRequest(url: URL(string: "https://example.com/file.txt")!)),
      "Should not match incorrect path extension"
    )
  }

  func testLastPathComponentBuilder() {
    let predicate = NetworkStubPredicateBuilder()
      .lastPathComponent("file.txt")
      .build()

    XCTAssertTrue(
      predicate.evaluate(URLRequest(url: URL(string: "https://example.com/path/file.txt")!)),
      "Should match last path component"
    )

    XCTAssertFalse(
      predicate.evaluate(URLRequest(url: URL(string: "https://example.com/path/other.txt")!)),
      "Should not match incorrect last path component"
    )
  }

  func testQueryItemsBuilder() {
    let predicate = NetworkStubPredicateBuilder()
      .containsQueryItems([URLQueryItem(name: "q", value: "1")])
      .build()

    XCTAssertTrue(
      predicate.evaluate(URLRequest(url: URL(string: "https://example.com?q=1")!)),
      "Should match query items"
    )

    XCTAssertFalse(
      predicate.evaluate(URLRequest(url: URL(string: "https://example.com?x=2")!)),
      "Should not match incorrect query items"
    )
  }
}
