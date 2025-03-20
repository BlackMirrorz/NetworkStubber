//
//  NetworkStubTypeTests.swift
//  NetworkStubber
//
//  Created by Josh Robbins on 3/20/25.
//

@testable import NetworkStubberPackage
import XCTest

final class NetworkStubTypeTests: XCTestCase {

  func testNetworkStubTypeError() {
    let stub = NetworkStub(
      url: URL(string: "https://api.example.com")!,
      error: NSError(domain: "Test", code: 1)
    )

    XCTAssertEqual(
      stub.type,
      .error,
      "Stub should be of type .error when an error is provided"
    )
  }

  func testNetworkStubTypeResponse() {
    let response = HTTPURLResponse(
      url: URL(string: "https://api.example.com")!,
      statusCode: 200,
      httpVersion: nil,
      headerFields: nil
    )!
    let stub = NetworkStub(url: response.url!, response: NetworkStubResponseItem(response: response, data: Data()))

    XCTAssertEqual(
      stub.type,
      .response,
      "Stub should be of type .response when a full response is provided"
    )
  }

  func testNetworkStubTypeData() {
    let stub = NetworkStub(
      url: URL(string: "https://api.example.com")!,
      data: NetworkStubDataItem(statusCode: 200, data: Data())
    )

    XCTAssertEqual(
      stub.type,
      .data,
      "Stub should be of type .data when only data is provided"
    )
  }

  func testNetworkStubTypeEmpty() {
    let stub = NetworkStub(url: URL(string: "https://api.example.com")!)

    XCTAssertEqual(
      stub.type,
      .empty,
      "Stub should be of type .empty when no data, error, or response is provided"
    )
  }
}
