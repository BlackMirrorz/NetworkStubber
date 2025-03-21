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

  func testSetLaunchArgumentsForStubs() {
    let stubA = NetworkStub(
      url: URL(string: "https://api.example.com/data")!,
      data: NetworkStubDataItem(statusCode: 200, data: Data("{ \"message\": \"Hello!\" }".utf8))
    )

    let stubB = NetworkStub(
      url: URL(string: "https://api.example.com/data")!,
      data: NetworkStubDataItem(statusCode: 400, data: Data("{ \"message\": \"Hello!\" }".utf8))
    )

    setLaunchArgumentsForStubs([stubA, stubB])

    app.launch()

    XCTAssertTrue(
      app.launchArguments.contains("-NetworkStubs"),
      "Launch arguments should contain the network stubs flag"
    )

    guard
      let base64Index = app.launchArguments.firstIndex(of: "-NetworkStubs"),
      app.launchArguments.indices.contains(base64Index + 1)
    else {
      XCTFail("No Base64 stub data found in launch arguments")
      return
    }

    let base64String = app.launchArguments[base64Index + 1]

    guard
      let jsonData = Data(base64Encoded: base64String)
    else {
      XCTFail("Failed to decode Base64 stub data from launch arguments")
      return
    }

    let decoder = JSONDecoder()

    guard
      let decodedStubs = try? decoder.decode([NetworkStub].self, from: jsonData)
    else {
      XCTFail("Failed to decode JSON stub data from Base64-decoded string")
      return
    }

    XCTAssertEqual(
      decodedStubs.count, 2,
      "There should be two stubs in the JSON data"
    )
  }
}

// MARK: - Helpers

extension NetworkStubberDemoUITests {

  /// Adds stubs as launch arguments for UI tests
  /// - Parameter stubs: Array of `NetworkStub` objects
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
