//
//  NetwrokStubCodableTests.swift
//  NetworkStubberPackage
//
//  Created by Josh Robbins on 4/3/25.
//

@testable import NetworkStubberPackage
import XCTest

final class NetworkStubPredicateCodableTests: XCTestCase {

  func testCodableEncodingDecodingOfEachPredicateType() throws {

    let predicates: [NetworkStubPredicate] = [
      .isHTTPMethod(.get),
      .hasHeaderField(name: "Authorization"),
      .hasHeaderField(name: "Content-Type", value: "application/json"),
      .headerFieldMatches(name: "User-Agent", pattern: ".*Safari.*"),
      .isURL(URL(string: "https://example.com/test")!),
      .isURLString("https://example.com/test?q=123"),
      .isHost("example.com"),
      .isPath("/path/to/resource"),
      .hasPathPrefix("/prefix"),
      .hasPathSuffix("/suffix"),
      .hasPathExtension("json"),
      .hasLastPathComponent("component"),
      .containsQueryItems([URLQueryItem(name: "q", value: "test")]),
      .alwaysTrue,
      .alwaysFalse,
      .isHTTPMethod(.post) && .hasHeaderField(name: "X-Test") || !.isHost("evil.com")
    ]

    for predicate in predicates {
      let stub = NetworkStub(
        predicate: predicate,
        data: NetworkStubDataItem(statusCode: 200, data: Data())
      )

      let encoded = try JSONEncoder().encode(stub)
      let decoded = try JSONDecoder().decode(NetworkStub.self, from: encoded)

      guard
        let stub = stub
      else {
        XCTFail("Stub should not be nil")
        return
      }

      XCTAssertEqual(
        decoded.predicate.description,
        stub.predicate.description,
        "Predicate description should remain consistent after encoding and decoding"
      )
    }
  }
}

// MARK: - Helper

private struct CodableStub: Codable, Equatable {
  let id: Int
  let name: String
}
