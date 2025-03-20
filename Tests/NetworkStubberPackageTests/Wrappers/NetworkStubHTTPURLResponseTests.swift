//
//  NetworkStubHTTPURLResponseTests.swift
//  NetworkStubberPackage
//
//  Created by Josh Robbins on 3/20/25.
//

@testable import NetworkStubberPackage
import XCTest

final class NetworkStubHTTPURLResponseTests: XCTestCase {

  func testNetworkStubHTTPURLResponseInitialization() {
    let url = URL(string: "https://api.example.com")!
    let headerFields = ["Content-Type": "application/json"]
    let httpResponse = HTTPURLResponse(url: url, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: headerFields)!

    let stubResponse = NetworkStubHTTPURLResponse(from: httpResponse)

    XCTAssertEqual(stubResponse.url, url, "URL should match")
    XCTAssertEqual(stubResponse.statusCode, 200, "Status code should match")
    XCTAssertEqual(stubResponse.headerFields?["Content-Type"], "application/json", "Header fields should match")
  }

  func testNetworkStubHTTPURLResponseToHTTPURLResponse() {
    let url = URL(string: "https://api.example.com")!
    let httpResponse = HTTPURLResponse(url: url, statusCode: 201, httpVersion: "HTTP/2", headerFields: ["Cache-Control": "no-cache"])!

    let stubResponse = NetworkStubHTTPURLResponse(from: httpResponse)
    guard
      let convertedResponse = stubResponse.toHTTPURLResponse()
    else {
      XCTFail("Failed to convert back to HTTPURLResponse")
      return
    }

    XCTAssertEqual(convertedResponse.url, url, "Converted URL should match")
    XCTAssertEqual(convertedResponse.statusCode, 201, "Converted status code should match")
    XCTAssertEqual(convertedResponse.allHeaderFields["Cache-Control"] as? String, "no-cache", "Converted header fields should match")
  }
}
