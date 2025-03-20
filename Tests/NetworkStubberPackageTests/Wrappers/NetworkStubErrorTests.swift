//
//  NetworkStubErrorTests.swift
//  NetworkStubberPackage
//
//  Created by Josh Robbins on 3/20/25.
//

@testable import NetworkStubberPackage
import XCTest

final class NetworkStubErrorTests: XCTestCase {

  func testNetworkStubErrorInitialization() {
    let nsError = NSError(domain: "TestDomain", code: 404, userInfo: ["Key": "Value"])
    let stubError = NetworkStubError(from: nsError)

    XCTAssertEqual(stubError.domain, "TestDomain", "Domain should match")
    XCTAssertEqual(stubError.code, 404, "Code should match")
    XCTAssertEqual(stubError.userInfo?["Key"], "Value", "UserInfo should match")
  }

  func testNetworkStubErrorToNSError() {
    let nsError = NSError(domain: "TestDomain", code: 500, userInfo: ["ErrorKey": "ErrorValue"])
    let stubError = NetworkStubError(from: nsError)

    let expectedError = stubError.toNSError()

    XCTAssertEqual(expectedError.domain, "TestDomain", "Converted NSError domain should match")
    XCTAssertEqual(expectedError.code, 500, "Converted NSError code should match")
    XCTAssertEqual(expectedError.userInfo["ErrorKey"] as? String, "ErrorValue", "Converted NSError userInfo should match")
  }
}
