//
//  NetworkStubDataItemTests.swift
//  NetworkStubber
//
//  Created by Josh Robbins on 3/20/25.
//

@testable import NetworkStubberPackage
import XCTest

final class NetworkStubDataItemTests: XCTestCase {

  func testNetworkStubDataItemInitialization() {
    let testData = "Test data".data(using: .utf8)!
    let dataItem = NetworkStubDataItem(statusCode: 200, data: testData)

    XCTAssertEqual(
      dataItem.statusCode,
      200,
      "Status code should be 200"
    )

    XCTAssertEqual(
      dataItem.data,
      testData,
      "Data should match the provided data"
    )

    XCTAssertFalse(
      dataItem.isCodable,
      "isCodable should be false for raw data"
    )
  }

  func testNetworkStubDataItemWithCodable() throws {
    struct MockObject: Codable {
      let message: String
    }

    let mockObject = MockObject(message: "Hello")
    let dataItem = try NetworkStubDataItem(statusCode: 200, codable: mockObject)

    XCTAssertEqual(
      dataItem.statusCode,
      200,
      "Status code should be 200"
    )

    XCTAssertTrue(
      dataItem.isCodable,
      "isCodable should be true when initialized with a Codable object"
    )
  }

  func testHttpURLResponseCreation() {
    let testDataItem = NetworkStubDataItem(statusCode: 404, data: Data())
    let response = testDataItem.httpURLResponse(url: URL(string: "https://api.example.com")!)

    XCTAssertEqual(
      response?.statusCode,
      404,
      "Generated HTTP response should have the expected status code"
    )
  }

  func testDebugStringForValidUTF8() {
    let testDataItem = NetworkStubDataItem(statusCode: 200, data: "Valid UTF-8".data(using: .utf8)!)

    XCTAssertEqual(
      testDataItem.debugString,
      "Valid UTF-8",
      "Debug string should correctly convert valid UTF-8 data"
    )
  }

  func testDebugStringForNonUTF8Data() {
    let nonUTF8Data = Data([0xff, 0xfe, 0xfd])
    let testDataItem = NetworkStubDataItem(statusCode: 200, data: nonUTF8Data)

    XCTAssertEqual(
      testDataItem.debugString,
      "Binary Data",
      "Debug string should return 'Binary Data' for unreadable data"
    )
  }
}
