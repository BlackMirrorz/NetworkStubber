//
//  HTTPMethod.swift
//  NetworkStubber
//
//  Created by Josh Robbins on 4/3/25.
//

/// Represents common HTTP methods used in network requests.
public enum HTTPMethod: String, Codable, Sendable, CaseIterable {

  /// The `GET` method is used to request data from a specified resource.
  case get = "GET"

  /// The `POST` method is used to send data to a server to create a new resource.
  case post = "POST"

  /// The `PUT` method is used to update a current resource with new data.
  case put = "PUT"

  /// The `DELETE` method deletes the specified resource.
  case delete = "DELETE"

  /// The `PATCH` method is used to apply partial modifications to a resource.
  case patch = "PATCH"

  /// The `HEAD` method is similar to `GET`, but it transfers only the status line and header section.
  case head = "HEAD"

  /// The `OPTIONS` method describes the communication options for the target resource.
  case options = "OPTIONS"
}
