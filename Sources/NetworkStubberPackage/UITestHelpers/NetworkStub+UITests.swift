//
//  NetworkStub+UITests.swift
//  NetworkStubberPackage
//
//  Created by Josh Robbins on 3/20/25.
//

import XCTest

extension XCUIApplication {

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

    launchArguments.append(contentsOf: ["-NetworkStubs", jsonString])
  }
}
