//
//  NetworkStubError.swift
//  NetworkStubberPackage
//
//  Created by Josh Robbins on 3/20/25.
//

import Foundation

/**
 A `Codable` struct that wraps `NSError`, allowing errors to be encoded and decoded.
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

// MARK: - Internal Error

/**
 A set of internal errors that may occur within the `NetworkStubber`.
 */
enum NetworkStubberInternalError: Error, CustomStringConvertible {

  /**
   Indicates that a stored response could not be converted to an `HTTPURLResponse`.

   This usually means that the underlying response structure was invalid or improperly formed,
   which prevents `URLProtocol` from completing the stubbing process successfully.

   - Parameter url: The URL associated with the failing stub.
   */
  case failedToConvertStoredResponse(URL)

  /**
   Indicates that the request has no valid URL.

   This may happen when a `URLRequest` is mutated or constructed improperly,
   causing its `url` property to be `nil`, which breaks stubbing logic.
   */
  case invalidURL

  /**
   A textual description of the error, useful for logging and debugging.
   */
  var description: String {
    switch self {
    case .failedToConvertStoredResponse(let url):
      return "Failed to convert stored response to HTTPURLResponse for \(url)"
    case .invalidURL:
      return "The request has an invalid or missing URL."
    }
  }
}
