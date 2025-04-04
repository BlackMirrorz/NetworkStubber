//
//  NetworkStub.swift
//  NetworkStubber
//
//  Created by Josh Robbins on 4/3/25.
//

import Foundation

// MARK: - NetworkStub Protocol

/**
 A protocol defining network request stubs.
 */
protocol NetworkStubProtocol {

  /// The predicate that determines whether a request matches this stub.
  var predicate: NetworkStubPredicate { get }

  /// An optional error to simulate a network failure.
  var error: NetworkStubError? { get }

  /// The mocked response data, including an HTTP status code.
  var data: NetworkStubDataItem? { get }

  /// The complete HTTP response, including headers and body.
  var response: NetworkStubResponseItem? { get }
}

// MARK: - NetworkStub

/**
 A concrete implementation of `NetworkStubProtocol` for intercepting network requests.

 This struct allows defining stubbed network responses, including simulated errors and mock response data.
 */
public struct NetworkStub: NetworkStubProtocol, Sendable, Codable {

  /// The predicate that this stub applies to.
  let predicate: NetworkStubPredicate

  /// An optional error to simulate a network failure.
  let error: NetworkStubError?

  /// The response body and status code.
  let data: NetworkStubDataItem?

  /// The full HTTP response including headers and body.
  let response: NetworkStubResponseItem?

  /// The type of network stub (`error`, `data`, or `response`).
  let type: NetworkStubType

  // MARK: - Initialization

  /**
   Initializes a `NetworkStub` with exactly one stub type: an error, data item, or response.

   If multiple values are passed (e.g., both `error` and `data`), the initializer will fail.
   If all parameters are nil, the initializer will also fail.

   - Parameters:
     - predicate: The predicate to match against incoming requests.
     - error: An optional error to simulate.
     - data: Optional data to return.
     - response: Optional full response.
   */
  public init?(
    predicate: NetworkStubPredicate,
    error: Error? = nil,
    data: NetworkStubDataItem? = nil,
    response: NetworkStubResponseItem? = nil
  ) {
    self.predicate = predicate

    switch (error, response, data) {
    case (let e?, nil, nil):
      self.error = NetworkStubError(from: e)
      self.response = nil
      self.data = nil
      self.type = .error

    case (nil, let r?, nil):
      self.response = r
      self.error = nil
      self.data = nil
      self.type = .response

    case (nil, nil, let d?):
      self.data = d
      self.error = nil
      self.response = nil
      self.type = .data
    default:
      return nil
    }
  }
}

// MARK: - NetworkStubDataItem

/**
 Represents stubbed response body and status code, used in `.data` type stubs.
 */
public struct NetworkStubDataItem: Sendable, Codable {

  /// The HTTP status code to simulate.
  let statusCode: Int

  /// The body of the stubbed response.
  let data: Data

  /// Whether this item was created from a Codable object.
  let isCodable: Bool

  /// Initializes a `NetworkStubDataItem` with raw data.
  public init(statusCode: Int, data: Data) {
    self.statusCode = statusCode
    self.data = data
    self.isCodable = false
  }

  /// Initializes a `NetworkStubDataItem` from a Codable object.
  public init<T: Codable>(statusCode: Int, codable: T) throws {
    self.statusCode = statusCode
    self.data = try JSONEncoder().encode(codable)
    self.isCodable = true
  }
}

extension NetworkStubDataItem {

  /// Generates a `HTTPURLResponse` from the given URL and status code.
  func httpURLResponse(url: URL) -> HTTPURLResponse? {
    HTTPURLResponse(url: url, statusCode: statusCode, httpVersion: nil, headerFields: nil)
  }

  /// Debug-friendly representation of the body.
  var debugString: String {
    String(data: data, encoding: .utf8) ?? "Binary Data"
  }
}

// MARK: - NetworkStubResponseItem

/**
 Represents a complete HTTP response, including headers and body.
 */
public struct NetworkStubResponseItem: Sendable, Codable {

  /// The simulated HTTPURLResponse metadata (status code, headers, etc.)
  let response: NetworkStubHTTPURLResponse

  /// The body of the response.
  let data: Data

  /// Whether this response was created from a Codable object.
  let isCodable: Bool

  /// Initializes a full response with raw data.
  public init(response: HTTPURLResponse, data: Data) {
    self.response = NetworkStubHTTPURLResponse(from: response)
    self.data = data
    self.isCodable = false
  }

  /// Initializes a full response from a Codable object.
  public init<T: Codable>(response: HTTPURLResponse, codable: T) throws {
    self.response = NetworkStubHTTPURLResponse(from: response)
    self.data = try JSONEncoder().encode(codable)
    self.isCodable = true
  }
}

extension NetworkStubResponseItem {

  /// Debug-friendly representation of the body.
  var debugString: String {
    String(data: data, encoding: .utf8) ?? "Binary Data"
  }
}

// MARK: - NetworkStubType

/**
 Represents the type of stub (error, raw data, or full response).
 */
enum NetworkStubType: Codable {
  case error
  case data
  case response
}
