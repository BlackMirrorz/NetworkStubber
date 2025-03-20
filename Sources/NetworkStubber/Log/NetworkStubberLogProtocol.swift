//
//  NetworkStubberLogProtocol.swift
//  NetworkStubber
//
//  Created by Josh Robbins on 3/20/25.
//

import OSLog

/**
 A protocol for handling log messages in `NetworkStubber`.
 This allows the `NetworkStubber` class to log messages using any logging mechanism, such as `OSLog`, console printing, or a remote logging service.
 */

public protocol NetworkStubberLogProtocol: Sendable {
  func logMessage(_ message: String)
}

// MARK: - Default OSLog Logger

/**
 Provides default logging using `OSLog`.
 */
struct NetworkStubLogger: NetworkStubberLogProtocol {

  private let logger = Logger(subsystem: "networkStubber", category: "networkStubs")

  func logMessage(_ message: String) {
    logger.info("\(message, privacy: .public)")
  }
}
