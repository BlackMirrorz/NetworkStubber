//
//  NetworkStubResponseItemTests.swift
//  NetworkStubber
//
//  Created by Josh Robbins on 3/20/25.
//

@testable import NetworkStubberPackage
import XCTest

final class NetworkStubResponseItemTests: XCTestCase {

  func testNetworkStubResponseItemInitialization() {
    let response = HTTPURLResponse(
      url: URL(string: "https://api.example.com")!,
      statusCode: 200,
      httpVersion: nil,
      headerFields: nil
    )!
    guard
      let testData = "Response body".data(using: .utf8)
    else {
      XCTFail("Data error")
      return
    }
    let responseItem = NetworkStubResponseItem(response: response, data: testData)

    XCTAssertEqual(
      responseItem.response.statusCode,
      200,
      "Response status code should be 200"
    )

    XCTAssertEqual(
      responseItem.data,
      testData,
      "Response data should match the provided data"
    )

    XCTAssertFalse(
      responseItem.isCodable,
      "isCodable should be false for raw data"
    )
  }

  func testNetworkStubResponseItemWithCodable() throws {
    struct MockResponse: Codable {
      let status: String
    }

    let mockResponse = MockResponse(status: "success")
    let httpResponse = HTTPURLResponse(
      url: URL(string: "https://api.example.com")!,
      statusCode: 201,
      httpVersion: nil,
      headerFields: nil
    )!
    let responseItem = try NetworkStubResponseItem(response: httpResponse, codable: mockResponse)

    XCTAssertEqual(
      responseItem.response.statusCode,
      201,
      "Response status code should be 201"
    )

    XCTAssertTrue(
      responseItem.isCodable,
      "isCodable should be true when initialized with a Codable object"
    )
  }

  func testDebugStringForValidUTF8() {
    let response = HTTPURLResponse(
      url: URL(string: "https://api.example.com")!,
      statusCode: 200,
      httpVersion: nil,
      headerFields: nil
    )!

    guard
      let testData = "Valid response".data(using: .utf8)
    else {
      XCTFail("Data error")
      return
    }

    let responseItem = NetworkStubResponseItem(response: response, data: testData)

    XCTAssertEqual(
      responseItem.debugString,
      "Valid response",
      "Debug string should correctly convert valid UTF-8 data"
    )
  }

  func testDebugStringForNonUTF8Data() {
    let response = HTTPURLResponse(
      url: URL(string: "https://api.example.com")!,
      statusCode: 200,
      httpVersion: nil,
      headerFields: nil
    )!
    let nonUTF8Data = Data([0xff, 0xfe, 0xfd])
    let responseItem = NetworkStubResponseItem(response: response, data: nonUTF8Data)

    XCTAssertEqual(
      responseItem.debugString,
      "Binary Data",
      "Debug string should return 'Binary Data' for unreadable data"
    )
  }
}
