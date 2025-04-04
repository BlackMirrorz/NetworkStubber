//
//  NetworkStubTypeTests.swift
//  NetworkStubber
//
//  Created by Josh Robbins on 3/20/25.
//

@testable import NetworkStubberPackage
import XCTest

final class NetworkStubTypeTests: XCTestCase {

  func testNetworkStubTypeError() throws {
    let predicate = NetworkStubPredicate.alwaysTrue
    let stub = NetworkStub(
      predicate: predicate,
      error: NSError(domain: "Test", code: 1)
    )

    let unwrapped = try XCTUnwrap(stub, "Error stub should be successfully created")

    XCTAssertEqual(
      unwrapped.type,
      .error,
      "Stub should be of type .error when an error is provided"
    )
  }

  func testNetworkStubTypeResponse() throws {
    let url = URL(string: "https://api.example.com")!
    let response = HTTPURLResponse(
      url: url,
      statusCode: 200,
      httpVersion: nil,
      headerFields: nil
    )!

    let stub = NetworkStub(
      predicate: .isHost("api.example.com"),
      response: NetworkStubResponseItem(response: response, data: Data())
    )

    let unwrapped = try XCTUnwrap(stub, "Response stub should be successfully created")

    XCTAssertEqual(
      unwrapped.type,
      .response,
      "Stub should be of type .response when a full response is provided"
    )
  }

  func testNetworkStubTypeData() throws {

    let stub = NetworkStub(
      predicate: .isPath("/users"),
      data: NetworkStubDataItem(statusCode: 200, data: Data())
    )

    let unwrapped = try XCTUnwrap(stub, "Data stub should be successfully created")

    XCTAssertEqual(
      unwrapped.type,
      .data,
      "Stub should be of type .data when only data is provided"
    )
  }

  func testNetworkStubTypeFailsForEmpty() {
    let stub = NetworkStub(predicate: .alwaysFalse)

    XCTAssertNil(
      stub,
      "Stub should be nil when no error, data, or response is provided"
    )
  }
}
