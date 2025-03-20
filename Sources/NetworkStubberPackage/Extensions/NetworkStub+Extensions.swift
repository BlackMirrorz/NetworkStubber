//
//  NetworkStub+Extensions.swift
//  NetworkStubber
//
//  Created by Josh Robbins on 3/20/25.
//

import Foundation

extension Dictionary where Key == URL, Value == NetworkStub {

  /**
   Retrieves the first `NetworkStub` that matches the given partial URL.

   - Parameter partialURL: The URL to search for, matching any stub that starts with this URL string.
   - Returns: The first `NetworkStub` whose key starts with `partialURL.absoluteString`, or `nil` if no match is found.
   */
  func firstMatching(partialURL: URL) -> NetworkStub? {
    sorted { $0.key.absoluteString < $1.key.absoluteString }
      .first { $0.key.absoluteString.hasPrefix(partialURL.absoluteString) }?
      .value
  }

  /**
   Retrieves a stub for the given partial URL.

   This is a convenience function that calls `firstMatching(partialURL:)`.

   - Parameter partialURL: The partial URL string to search for.
   - Returns: A `NetworkStub` if a matching stub is found, otherwise `nil`.
   */
  func stub(for partialURL: URL) -> NetworkStub? {
    firstMatching(partialURL: partialURL)
  }
}
