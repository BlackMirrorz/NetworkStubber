//
//  NetworkStubberDemoUITests.swift
//  NetworkStubberDemoUITests
//
//  Created by Josh Robbins on 3/20/25.
//


import XCTest
@testable import NetworkStubberPackage

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
      let jsonIndex = app.launchArguments.firstIndex(of: "-NetworkStubs"),
      app.launchArguments.indices.contains(jsonIndex + 1)
    else {
      XCTFail("No JSON stub data found in launch arguments")
      return
    }
    
    let jsonString = app.launchArguments[jsonIndex + 1]
    
    let decoder = JSONDecoder()
    
    guard
      let jsonData = jsonString.data(using: .utf8),
      let decodedStubs = try? decoder.decode([NetworkStub].self, from: jsonData)
    else {
      XCTFail("Failed to decode JSON stub data from launch arguments")
      return
    }
    XCTAssertEqual(decodedStubs.count, 2, "There should be two stubs in the JSON data")
  }
}

// MARK: - Helpers

extension NetworkStubberDemoUITests {
  
  /// Adds stubs as launch arguments for UI tests
  /// - Parameter stubs: Array of `NetworkStub` objects
  public func setLaunchArgumentsForStubs(_ stubs: [NetworkStub]) {

    let encoder = JSONEncoder()
    encoder.outputFormatting = .prettyPrinted

    guard
      let encodedData = try? encoder.encode(stubs),
      let jsonString = String(data: encodedData, encoding: .utf8)
    else {
      XCTFail("Failed to encode stubs into JSON string")
      return
    }

    app.launchArguments.append(contentsOf: ["-NetworkStubs", jsonString])
  }
}
