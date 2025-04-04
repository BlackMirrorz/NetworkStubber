//
//  NetworkStubberLogProtocol.swift
//  NetworkStubber
//
//  Created by Josh Robbins on 3/20/25.
//

import OSLog

/**
 A protocol for handling log messages in `NetworkStubber`.
 */
public protocol NetworkStubberLogProtocol: Sendable {
  func logMessage(_ message: String)
}

// MARK: - Default OSLog Logger

/**
 Provides default logging using `OSLog`.
 */
public struct NetworkStubLogger: NetworkStubberLogProtocol {

  private let logger = Logger(subsystem: "networkStubber", category: "networkStubs")

  public init() {}
  public func logMessage(_ message: String) {
    #if DEBUG
    print(message)
    #else
    logger.info("\(message, privacy: .public)")
    #endif
  }
}
