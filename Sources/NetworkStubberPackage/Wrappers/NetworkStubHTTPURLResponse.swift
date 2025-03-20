//
//  NetworkStubHTTPURLResponse.swift
//  NetworkStubberPackage
//
//  Created by Josh Robbins on 3/20/25.
//

import Foundation

/**
 A `Codable` wrapper for `HTTPURLResponse` to allow serialization.

 Since `HTTPURLResponse` does not conform to `Codable`, this struct extracts
 key properties for encoding and decoding.
 */
public struct NetworkStubHTTPURLResponse: Codable, Sendable {
  /// The URL of the response.
  let url: URL?

  /// The HTTP status code (e.g., 200, 404).
  let statusCode: Int

  /// The response headers as a dictionary.
  let headerFields: [String: String]?

  // MARK: - Initialization

  /**
   Creates a `NetworkStubHTTPURLResponse` from an existing `HTTPURLResponse`.

   - Parameter response: The `HTTPURLResponse` to convert.
   */
  public init(from response: HTTPURLResponse) {
    self.url = response.url
    self.statusCode = response.statusCode
    self.headerFields = response.allHeaderFields as? [String: String]
  }
}

// MARK: - Conversion

extension NetworkStubHTTPURLResponse {

  /**
   Converts `NetworkStubHTTPURLResponse` back into an `HTTPURLResponse`.

   - Returns: An `HTTPURLResponse` instance with the stored properties.
   */
  public func toHTTPURLResponse() -> HTTPURLResponse? {
    guard let url = url else { return nil }
    return HTTPURLResponse(url: url, statusCode: statusCode, httpVersion: nil, headerFields: headerFields)
  }
}
