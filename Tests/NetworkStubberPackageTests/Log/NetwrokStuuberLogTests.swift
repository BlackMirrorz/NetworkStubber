//
//  NetwrokStuuberLogTests.swift
//  NetworkStubber
//
//  Created by Josh Robbins on 3/20/25.
//

@testable import NetworkStubber
import os
import XCTest

// MARK: - NetworkStubLoggerTests

final class NetworkStubLoggerTests: XCTestCase {

  func testMockLoggerCapturesLogMessage() {
    let mockLogger = MockNetworkStubLogger()
    let testMessage = "Test log entry"

    mockLogger.logMessage(testMessage)

    XCTAssertEqual(
      mockLogger.lastLogMessage(),
      testMessage,
      "Mock logger should capture the logged message correctly"
    )
  }

  func testOSLoggerDoesNotCrash() {
    let osLogger = NetworkStubLogger()

    osLogger.logMessage("This is a test log message")

    XCTAssertTrue(
      true,
      "Logging a message with OSLog should not cause a crash"
    )
  }
}
