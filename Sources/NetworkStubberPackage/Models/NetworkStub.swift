//
//  NetworkStub.swift
//  NetworkStubber
//
//  Created by Josh Robbins on 3/20/25.
//

import Foundation

// MARK: - NetworkStub Protocol

/**
 A protocol defining network request stubs.
 */
protocol NetworkStubProtocol {

  /// The URL that this stub applies to.
  var url: URL { get }

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

  /// The URL that this stub applies to.
  let url: URL

  /// An optional error to simulate a network failure.
  let error: NetworkStubError?

  /// The response body and status code.
  let data: NetworkStubDataItem?

  /// The full HTTP response including headers and body.
  let response: NetworkStubResponseItem?

  /// The type of network stub (`error`, `data`, `response`, or `empty`).
  let type: NetworkStubType

  // MARK: - Initialization

  /**
   Initializes a `NetworkStub` with optional response data and an error.

   - Parameters:
     - url: The URL to be stubbed.
     - error: An optional `Error` to simulate a network failure.
     - data: An optional `NetworkStubDataItem` for the response body and status code.
     - response: An optional `NetworkStubResponseItem` for a full HTTP response.
   */
  public init(
    url: URL,
    error: Error? = nil,
    data: NetworkStubDataItem? = nil,
    response: NetworkStubResponseItem? = nil
  ) {
    self.url = url

    if let error {
      self.error = NetworkStubError(from: error)
    } else {
      self.error = nil
    }

    self.data = data
    self.response = response

    if error != nil {
      self.type = .error
    } else if response != nil {
      self.type = .response
    } else if data != nil {
      self.type = .data
    } else {
      self.type = .empty
    }
  }
}

// MARK: - NetworkStubDataItem

/**
 A struct representing the body of a stubbed HTTP response.
 */
public struct NetworkStubDataItem: Sendable, Codable {

  /// The HTTP status code of the response.
  let statusCode: Int

  /// The raw data to be returned as the response body.
  let data: Data

  /// Indicates whether the data was encoded from a `Codable` object.
  let isCodable: Bool

  // MARK: - Initialization

  /**
   Initializes a `NetworkStubDataItem` with raw data.

   - Parameters:
     - statusCode: The HTTP status code for the response.
     - data: The response body in raw `Data` format.
   */
  public init(statusCode: Int, data: Data) {
    self.statusCode = statusCode
    self.data = data
    self.isCodable = false
  }

  /**
   Initializes a `NetworkStubDataItem` with a `Codable` object, encoding it as JSON.

   - Parameters:
     - statusCode: The HTTP status code for the response.
     - codable: A `Codable` object that will be JSON-encoded into `Data`.
   - Throws: An error if encoding fails.
   */
  public init<T: Codable>(statusCode: Int, codable: T) throws {
    self.statusCode = statusCode
    self.data = try JSONEncoder().encode(codable)
    self.isCodable = true
  }
}

// MARK: - NetworkStubDataItem + Helpers

extension NetworkStubDataItem {

  /**
   Creates an `HTTPURLResponse` from the stored status code.

   - Parameter url: The URL associated with the response.
   - Returns: An optional `HTTPURLResponse` with the stored status code.
   */
  func httpURLResponse(url: URL) -> HTTPURLResponse? {
    HTTPURLResponse(url: url, statusCode: statusCode, httpVersion: nil, headerFields: nil)
  }

  /**
   Attempts to convert the response data into a readable `String`.

   - Returns: A formatted `String` representation of the data if possible, otherwise `"Binary Data"`.
   */
  var debugString: String {
    String(data: data, encoding: .utf8) ?? "Binary Data"
  }
}

// MARK: - NetworkStubResponseItem

/**
 A struct that combines an `HTTPURLResponse` with response data.
 */
public struct NetworkStubResponseItem: Sendable, Codable {

  /// The HTTP response headers and status code.
  let response: NetworkStubHTTPURLResponse

  /// The response body data.
  let data: Data

  /// Indicates whether the data was encoded from a `Codable` object.
  let isCodable: Bool

  // MARK: - Initialization

  /**
   Initializes a `NetworkStubResponseItem` with raw response data.

   - Parameters:
     - response: The `HTTPURLResponse` containing headers and status code.
     - data: The response body in raw `Data` format.
   */
  public init(response: HTTPURLResponse, data: Data) {
    self.response = NetworkStubHTTPURLResponse(from: response)
    self.data = data
    self.isCodable = false
  }

  /**
   Initializes a `NetworkStubResponseItem` with a `Codable` object, encoding it as JSON.

   - Parameters:
     - response: The `HTTPURLResponse` containing headers and status code.
     - codable: A `Codable` object that will be JSON-encoded into `Data`.
   - Throws: An error if encoding fails.
   */
  public init<T: Codable>(response: HTTPURLResponse, codable: T) throws {
    self.response = NetworkStubHTTPURLResponse(from: response)
    self.data = try JSONEncoder().encode(codable)
    self.isCodable = true
  }
}

// MARK: - NetworkStubResponseItem + Helpers

extension NetworkStubResponseItem {

  /**
   Attempts to convert the response data into a readable `String`.

   - Returns: A formatted `String` representation of the data if possible, otherwise `"Binary Data"`.
   */
  var debugString: String {
    String(data: data, encoding: .utf8) ?? "Binary Data"
  }
}

// MARK: - NetworkStubType

/**
 An enumeration representing different types of network stubs.

 - `error`: Simulates a network error.
 - `data`: Provides only response data without headers.
 - `response`: Provides a full HTTP response including headers and body.
 - `empty`: Represents a stub with no error, data, or response.
 */
enum NetworkStubType: Codable {
  case error
  case data
  case response
  case empty
}
