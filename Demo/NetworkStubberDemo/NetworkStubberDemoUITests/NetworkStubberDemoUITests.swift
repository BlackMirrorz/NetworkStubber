//
//  NetworkStubberDemoUITests.swift
//  NetworkStubberDemoUITests
//
//  Created by Josh Robbins on 3/20/25.
//

@testable import NetworkStubberPackage
import XCTest

final class NetworkStubberDemoUITests: XCTestCase {

  let app = XCUIApplication()

  func testLaunchArgumentDecodingCoversMultiplePredicateTypes() {
    let predicates: [NetworkStubPredicate] = [
      NetworkStubPredicate.isHost("api.example.com"),
      NetworkStubPredicate.isPath("/v1/data"),
      NetworkStubPredicate.hasHeaderField(name: "Authorization", value: "Bearer test"),
      NetworkStubPredicate.hasPathPrefix("/v1"),
      NetworkStubPredicate.hasPathSuffix("json"),
      NetworkStubPredicate.hasPathExtension("json"),
      NetworkStubPredicate.hasLastPathComponent("file.json"),
      NetworkStubPredicate.containsQueryItems([URLQueryItem(name: "id", value: "123")]),
      NetworkStubPredicate.isURLString("https://api.example.com/v1/data?id=123"),
      NetworkStubPredicate.isURL(URL(string: "https://api.example.com/v1/data?id=123")!),
      NetworkStubPredicate.headerFieldMatches(name: "Content-Type", pattern: "application/json.*"),
      NetworkStubPredicate.hasHeaderField(name: "X-Test-Header"),
      NetworkStubPredicate.alwaysTrue,
      NetworkStubPredicate.alwaysFalse,
      NetworkStubPredicate.isHTTPMethod(.get),
      NetworkStubPredicate.isHTTPMethod(.post),
      NetworkStubPredicate.isHost("not-this.com")
    ]

    let stubs: [NetworkStub] = predicates.compactMap {
      NetworkStub(
        predicate: $0,
        data: NetworkStubDataItem(
          statusCode: 200,
          data: Data("{\"ok\": true}".utf8)
        )
      )
    }

    setLaunchArgumentsForStubs(stubs)

    app.launch()

    XCTAssertTrue(app.launchArguments.contains("-NetworkStubs"), "Launch arguments should contain the stubs flag")

    guard
      let base64Index = app.launchArguments.firstIndex(of: "-NetworkStubs"),
      app.launchArguments.indices.contains(base64Index + 1),
      let base64Data = Data(base64Encoded: app.launchArguments[base64Index + 1])
    else {
      XCTFail("Base64 stub data not found or invalid")
      return
    }

    let decoded = try? JSONDecoder().decode([NetworkStub].self, from: base64Data)
    XCTAssertEqual(decoded?.count, predicates.count, "Decoded stubs should match predicate count")
  }
}

// MARK: - Helpers

extension NetworkStubberDemoUITests {

  public func setLaunchArgumentsForStubs(_ stubs: [NetworkStub]) {
    let encoder = JSONEncoder()
    encoder.outputFormatting = .prettyPrinted

    do {
      let encodedData = try encoder.encode(stubs)
      let base64String = encodedData.base64EncodedString()
      app.launchArguments.append(contentsOf: ["-NetworkStubs", base64String])
    } catch {
      XCTFail("Failed to encode JSON for stubs: \(error)")
    }
  }
}
