//
//  NetworkStubQueryItem.swift
//  NetworkStubberPackage
//
//  Created by Josh Robbins on 4/4/25.
//

import Foundation

/**
 A `Codable` wrapper for `URLQueryItem` to allow serialization.

 Since `URLQueryItem` does not conform to `Codable`, this struct extracts
 key properties for encoding and decoding.
 */
public struct NetworkStubQueryItem: Codable, Equatable {

  /// The name of the query item.
  public let name: String

  /// The optional value of the query item.
  public let value: String?

  // MARK: - Initialization

  /**
   Initializes a new codable query item with the given name and value.

   - Parameters:
     - name: The name of the query item.
     - value: The optional value of the query item.
   */
  public init(name: String, value: String?) {
    self.name = name
    self.value = value
  }

  /**
   Initializes a new codable query item from an existing `URLQueryItem`.

   - Parameter item: The `URLQueryItem` to wrap.
   */
  public init(_ item: URLQueryItem) {
    self.name = item.name
    self.value = item.value
  }
}

// MARK: - Conversion

extension NetworkStubQueryItem {

  /// Returns a `URLQueryItem` representation of the codable wrapper.
  public var asURLQueryItem: URLQueryItem {
    URLQueryItem(name: name, value: value)
  }
}
