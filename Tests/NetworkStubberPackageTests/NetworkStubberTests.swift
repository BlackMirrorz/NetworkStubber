/// NetworkStubberIntegrationTests.swift
/// NetworkStubberTests

@testable import NetworkStubberPackage
import XCTest

final class NetworkStubberIntegrationTests: XCTestCase {

  private var session: URLSession!
  private var logger: NetworkStubLogger!

  // MARK: - LifeCycle

  override func setUp() {
    super.setUp()
    NetworkStubber.purge()
    logger = NetworkStubLogger()
    NetworkStubber.setLogger(logger)

    let config = URLSessionConfiguration.ephemeral
    config.protocolClasses = [NetworkStubber.self]
    session = URLSession(configuration: config)
  }

  override func tearDown() {
    session.invalidateAndCancel()
    super.tearDown()
  }

  // MARK: - Tests

  func testDataStubWithIsPathPredicate() async {
    await assertDataStub(
      request: requestFromString("https://twinkl.com/path/abc"),
      predicate: .isPath("/path/abc"),
      expectedData: "OK"
    )
  }

  func testErrorStubWithIsHostPredicate() async {
    await assertErrorStub(
      request: requestFromString("https://error.twinkl.com/test"),
      predicate: .isHost("error.twinkl.com")
    )
  }

  func testCodableResponseStubWithQueryPredicate() async throws {

    struct User: Codable, Equatable { let name: String }

    let user = User(name: "Test")
    try await assertCodableStub(
      request: requestFromString("https://twinkl.com/users?id=42"),
      predicate: .containsQueryItems([URLQueryItem(name: "id", value: "42")]),
      object: user
    )
  }

  func testCanInitUsesPredicateEvaluation() {
    let predicate1 = NetworkStubPredicate.hasPathPrefix("/foo")
    let predicate2 = NetworkStubPredicate.hasPathSuffix("/baz")

    NetworkStubber.addStubs([
      NetworkStub(
        predicate: predicate1,
        data: NetworkStubDataItem(statusCode: 200, data: Data())
      ),
      NetworkStub(
        predicate: predicate2,
        data: NetworkStubDataItem(statusCode: 200, data: Data())
      )
    ])

    let request = requestFromString("https://api.twinkl.co.uk/foo/bar")

    XCTAssertTrue(
      NetworkStubber.canInit(with: request),
      "At least one stub should match the request"
    )
  }

  func testHasHeaderFieldWithMatchingValue() async {
    var request = requestFromString("https://twinkggl.com/headers")
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    await assertDataStub(
      request: request,
      predicate: .hasHeaderField(name: "Content-Type", value: "application/json"),
      expectedData: "Header OK"
    )
  }

  func testPathExtensionPredicate() async {

    await assertDataStub(
      request: requestFromString("https://twinkl.com/assets/image.png"),
      predicate: .hasPathExtension("png"),
      expectedData: "PNG OK"
    )
  }

  func testHeaderFieldMatchesRegexFails() async {
    var request = requestFromString("https://twinkl.com/regex")
    request.setValue("text/html", forHTTPHeaderField: "Accept")
    await assertNoMatch(
      request: request,
      predicate: .headerFieldMatches(name: "Accept", pattern: "^application/json$"),
      expected: "Should not match"
    )
  }

  func testNotPredicateNegatesMatch() async {

    await assertDataStub(
      request: requestFromString("https://twinkl.com/test"),
      predicate: !.isHost("not-twinkl.com"),
      expectedData: "NOT OK"
    )
  }

  func testHeaderExistsPredicate() async {
    var request = requestFromString("https://twinkl.com/exists")
    request.setValue("123", forHTTPHeaderField: "X-Custom-Header")
    await assertDataStub(
      request: request,
      predicate: .hasHeaderField(name: "X-Custom-Header"),
      expectedData: "Exists OK"
    )
  }

  func testURLStringPredicate() async {
    await assertDataStub(
      request: requestFromString("https://twinkl.com/full/path?key=value"),
      predicate: .isURLString("https://twinkl.com/full/path?key=value"),
      expectedData: "URLString OK"
    )
  }

  func testExactURLPredicate() async {
    let request = requestFromString("https://twinkl.com/api/data")
    await assertDataStub(
      request: request,
      predicate: .isURL(request.url!),
      expectedData: "Exact URL OK"
    )
  }

  func testLastPathComponentPredicate() async {
    let request = requestFromString("https://twinkl.com/path/to/resource.json")
    await assertDataStub(
      request: request,
      predicate: .hasLastPathComponent("resource.json"),
      expectedData: "Last Path OK"
    )
  }

  func testAlwaysFalsePredicate() async {
    let request = requestFromString("https://twinkl.com/wontmatch")
    await assertNoMatch(
      request: request,
      predicate: .alwaysFalse,
      expected: "No Match"
    )
  }

  func testPredicateWithMissingURLFailsGracefully() async {
    var request = requestFromString("https://placeholder.com")
    request.url = nil
    let predicate = NetworkStubPredicate.isPath("/some/path")
    await assertNoMatch(
      request: request,
      predicate: predicate,
      expected: "Should not match"
    )
  }

  func testHeaderFieldMatchesRegexSuccess() async {
    var request = requestFromString("https://twinkl.com/assets")
    request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
    let predicate = NetworkStubPredicate.headerFieldMatches(
      name: "Content-Type",
      pattern: "application/json.*"
    )
    await assertDataStub(
      request: request,
      predicate: predicate,
      expectedData: "Regex match success"
    )
  }

  func testHeaderFieldMatchesWithInvalidPattern() async {
    var request = requestFromString("https://twinkl.com/assets")
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    let predicate = NetworkStubPredicate.headerFieldMatches(name: "Content-Type", pattern: "[unterminated")
    await assertNoMatch(
      request: request,
      predicate: predicate,
      expected: "Invalid pattern should not match"
    )
  }

  func testNotHostPredicateMatchesDifferentHost() async {
    let predicate = !.isHost("some-other-host.com")
    let request = requestFromString("https://twinkl.com/api/test")

    await assertDataStub(
      request: request,
      predicate: predicate,
      expectedData: "Matched NOT predicate"
    )
  }

  func testNotPredicateOnAnd() async {
    let request = requestFromString("https://foo.local/api/data")
    let inner = .isHost("foo.local") && .isPath("/api/data")
    let predicate = !inner

    await assertNoMatch(
      request: request,
      predicate: predicate,
      expected: "Should not match"
    )
  }
}

// MARK: - Helpers

extension NetworkStubberIntegrationTests {

  private func requestFromString(_ value: String) -> URLRequest {
    URLRequest(url: URL(string: value)!)
  }

  private func assertDataStub(
    request: URLRequest,
    predicate: NetworkStubPredicate,
    expectedData: String,
    statusCode: Int = 200
  ) async {
    let stub = NetworkStub(
      predicate: predicate,
      data: NetworkStubDataItem(statusCode: statusCode, data: Data(expectedData.utf8))
    )
    NetworkStubber.add(stub)

    let (data, response) = try! await session.data(for: request)
    XCTAssertEqual(String(data: data, encoding: .utf8), expectedData)
    XCTAssertEqual((response as? HTTPURLResponse)?.statusCode, statusCode)
  }

  private func assertErrorStub(
    request: URLRequest,
    predicate: NetworkStubPredicate,
    errorDomain: String = "test",
    errorCode: Int = 404
  ) async {
    let error = NSError(domain: errorDomain, code: errorCode, userInfo: nil)
    let stub = NetworkStub(predicate: predicate, error: error)
    NetworkStubber.add(stub)

    do {
      _ = try await session.data(for: request)
      XCTFail("Expected error but got success")
    } catch {
      XCTAssertNotNil(error)
    }
  }

  private func assertCodableStub<T: Codable & Equatable>(
    request: URLRequest,
    predicate: NetworkStubPredicate,
    object: T,
    statusCode: Int = 200
  ) async throws {
    guard let url = request.url else {
      XCTFail("Request must contain a URL")
      return
    }
    let response = HTTPURLResponse(url: url, statusCode: statusCode, httpVersion: nil, headerFields: nil)!
    let stub = try NetworkStub(predicate: predicate, response: NetworkStubResponseItem(response: response, codable: object))
    NetworkStubber.add(stub)

    let (data, resp) = try await session.data(for: request)
    let decoded = try JSONDecoder().decode(T.self, from: data)
    XCTAssertEqual(decoded, object)
    XCTAssertEqual((resp as? HTTPURLResponse)?.statusCode, statusCode)
  }

  private func assertNoMatch(
    request: URLRequest,
    predicate: NetworkStubPredicate,
    expected: String
  ) async {
    let stub = NetworkStub(
      predicate: predicate,
      data: NetworkStubDataItem(statusCode: 200, data: Data(expected.utf8))
    )
    NetworkStubber.add(stub)

    // Add a fallback that will cause failure if the stub isn't hit
    NetworkStubber.add(NetworkStub(
      predicate: .alwaysTrue,
      error: URLError(.notConnectedToInternet)
    ))

    do {
      let (data, _) = try await session.data(for: request)
      let actual = String(data: data, encoding: .utf8)

      XCTFail("Request unexpectedly matched stub. Returned: \(actual ?? "<nil>")")
    } catch {}
  }
}
