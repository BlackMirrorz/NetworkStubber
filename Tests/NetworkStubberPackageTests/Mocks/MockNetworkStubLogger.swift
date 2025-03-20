//
//  MockNetworkStubLogger.swift
//  NetworkStubber
//
//  Created by Josh Robbins on 3/20/25.
//

@testable import NetworkStubberPackage
import XCTest

final class MockNetworkStubLogger: NetworkStubberLogProtocol {

  private(set) var loggedMessages: [String] = []

  func logMessage(_ message: String) {
    loggedMessages.append(message)
  }

  func lastLogMessage() -> String? {
    loggedMessages.last
  }
}
