//
//  NetworkStubQueryItem.swift
//  NetworkStubberPackage
//
//  Created by Josh Robbins on 4/4/25.
//

@testable import NetworkStubberPackage
import XCTest

final class NetworkStubQueryItemTests: XCTestCase {

  func testInitWithNameAndValue() {
    let item = NetworkStubQueryItem(name: "user", value: "123")
    XCTAssertEqual(item.name, "user", "Name should be set correctly")
    XCTAssertEqual(item.value, "123", "Value should be set correctly")
  }

  func testInitFromURLQueryItem() {
    let queryItem = URLQueryItem(name: "token", value: "abc123")
    let codableItem = NetworkStubQueryItem(queryItem)
    XCTAssertEqual(codableItem.name, "token", "Should copy name from URLQueryItem")
    XCTAssertEqual(codableItem.value, "abc123", "Should copy value from URLQueryItem")
  }

  func testAsURLQueryItem() {
    let codableItem = NetworkStubQueryItem(name: "page", value: "5")
    let queryItem = codableItem.asURLQueryItem
    XCTAssertEqual(queryItem.name, "page", "Should match name")
    XCTAssertEqual(queryItem.value, "5", "Should match value")
  }

  func testEquatable() {
    let a = NetworkStubQueryItem(name: "lang", value: "en")
    let b = NetworkStubQueryItem(name: "lang", value: "en")
    let c = NetworkStubQueryItem(name: "lang", value: "fr")
    XCTAssertEqual(a, b, "Identical items should be equal")
    XCTAssertNotEqual(a, c, "Different values should not be equal")
  }

  func testCodableRoundTrip() throws {
    let original = NetworkStubQueryItem(name: "mode", value: "dark")
    let data = try JSONEncoder().encode(original)
    let decoded = try JSONDecoder().decode(NetworkStubQueryItem.self, from: data)
    XCTAssertEqual(decoded, original, "Decoded item should match original")
  }

  func testCodableNilValue() throws {
    let original = NetworkStubQueryItem(name: "debug", value: nil)
    let data = try JSONEncoder().encode(original)
    let decoded = try JSONDecoder().decode(NetworkStubQueryItem.self, from: data)
    XCTAssertEqual(decoded, original, "Decoded item with nil value should match original")
    XCTAssertNil(decoded.value, "Decoded value should be nil")
  }
}
