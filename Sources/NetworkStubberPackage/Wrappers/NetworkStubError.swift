//
//  NetworkStubError.swift
//  NetworkStubberPackage
//
//  Created by Josh Robbins on 3/20/25.
//

import Foundation

/**
 A `Codable` struct that wraps `NSError`, allowing errors to be encoded and decoded.

 Since `NSError` does not conform to `Codable`, this struct extracts essential properties
 (domain, code, and userInfo) to allow serialization and deserialization.
 */
public struct NetworkStubError: Codable, Sendable {

  /// The error domain, typically representing the error source.
  let domain: String

  /// The error code associated with the error.
  let code: Int

  /// Additional error information, stored as a dictionary of key-value pairs.
  let userInfo: [String: String]?

  // MARK: - Initialization

  /**
   Creates a `NetworkStubError` from an existing `Error` instance.
   - Parameter error: The original `Error` (or `NSError`) to convert into a `Codable` form.
   */
  public init(from error: Error) {
    let nsError = error as NSError
    self.domain = nsError.domain
    self.code = nsError.code
    self.userInfo = nsError.userInfo as? [String: String]
  }
}

// MARK: - Conversion

extension NetworkStubError {

  /**
   Converts `NetworkStubError` back into an `NSError`.
   - Returns: An `NSError` instance containing the stored `domain`, `code`, and `userInfo`.
   */
  public func toNSError() -> NSError {
    return NSError(domain: domain, code: code, userInfo: userInfo)
  }
}
