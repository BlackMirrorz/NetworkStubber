//  NetworkStubberTests.swift
//  NetworkStubberTests
//
//  Created by Josh Robbins on 3/20/25.
//

@testable import NetworkStubberPackage
import XCTest

final class NetworkStubberTests: XCTestCase {

  private var logger: MockNetworkStubLogger!
  private var session: URLSession!

  // MARK: - Lifecycle

  override func setUp() {
    super.setUp()

    logger = MockNetworkStubLogger()
    NetworkStubber.setLogger(logger)

    let configuration = URLSessionConfiguration.ephemeral
    configuration.protocolClasses = [NetworkStubber.self]
    session = URLSession(configuration: configuration)
  }

  override func tearDown() {
    super.tearDown()
    NetworkStubber.purge()
    session.invalidateAndCancel()
  }

  // MARK: - Tests

  func testCanInitWithMatchingStub() {
    let url = URL(string: "https://api.example.com")!
    let stub = NetworkStub(url: url, data: NetworkStubDataItem(statusCode: 200, data: Data()))

    NetworkStubber.add(stub)

    let request = URLRequest(url: url)
    let canHandle = NetworkStubber.canInit(with: request)

    XCTAssertTrue(canHandle, "NetworkStubber should return true for a request that has a registered stub")
    XCTAssertEqual(logger.lastLogMessage(), adddedStubMessage(url))
  }

  func testCanInitWithNoMatchingStub() {
    let url = URL(string: "https://api.example.com")!
    let request = URLRequest(url: url)
    let canHandle = NetworkStubber.canInit(with: request)
    XCTAssertFalse(canHandle, "NetworkStubber should return false for a request with no registered stub")
  }

  func testHandleStubError() {
    let url = URL(string: "https://api.example.com/error")!
    let stubError = NSError(domain: "TestError", code: -1, userInfo: nil)
    let stub = NetworkStub(url: url, error: stubError)

    let (_, _, error) = performRequest(url: url, stub: stub, expectationDescription: "Error response received")
    XCTAssertEqual((error as NSError?)?.code, -1, "Returned error should match the stubbed error")

    let expectedLog = [
      adddedStubMessage(url),
      stubbingRequest(url),
      stubbingErrorMessage(stubError),
      completionStubMessage(url)
    ]
    assertLogSequence(expected: expectedLog)
  }

  func testHandleStubDataResponse() {
    let url = URL(string: "https://api.example.com/data")!
    guard let responseData = "Hello, World!".data(using: .utf8) else {
      XCTFail("Data error")
      return
    }

    let stub = NetworkStub(url: url, data: NetworkStubDataItem(statusCode: 200, data: responseData))
    let (data, status, _) = performRequest(url: url, stub: stub, expectationDescription: "Data response received")

    XCTAssertEqual(status, 200, "HTTP response status code should match stubbed value")
    XCTAssertEqual(data, responseData, "Returned data should match the stubbed data")

    let expectedLog = [
      adddedStubMessage(url),
      stubbingRequest(url),
      stubDataMessage(stub.data!, url: url),
      completionStubMessage(url)
    ]
    assertLogSequence(expected: expectedLog)
  }

  func testHandleStubResponse() {
    let url = URL(string: "https://api.example.com/fullresponse")!
    guard let responseData = """
    { "message": "Success" }
    """.data(using: .utf8) else {
      XCTFail("Data error")
      return
    }

    let httpResponse = HTTPURLResponse(
      url: url,
      statusCode: 201,
      httpVersion: nil,
      headerFields: ["Content-Type": "application/json"]
    )!

    let stub = NetworkStub(url: url, response: NetworkStubResponseItem(response: httpResponse, data: responseData))

    let (data, status, _) = performRequest(url: url, stub: stub, expectationDescription: "Full response received")
    XCTAssertEqual(status, 201, "HTTP response status code should match stubbed value")
    XCTAssertEqual(data, responseData, "Returned data should match the stubbed response body")

    let expectedLog = [
      adddedStubMessage(url),
      stubbingRequest(url),
      stubResponseMessage(stub.response!, url: url),
      completionStubMessage(url)
    ]
    assertLogSequence(expected: expectedLog)
  }

  func testRegisterStubs() {
    let url1 = URL(string: "https://api.example.com/first")!
    let url2 = URL(string: "https://api.example.com/second")!

    let stub1 = NetworkStub(url: url1, data: NetworkStubDataItem(statusCode: 200, data: Data()))
    let stub2 = NetworkStub(url: url2, error: NSError(domain: "TestError", code: -1, userInfo: nil))

    NetworkStubber.addStubs([stub1, stub2])

    let request1 = URLRequest(url: url1)
    let request2 = URLRequest(url: url2)

    XCTAssertTrue(NetworkStubber.canInit(with: request1), "NetworkStubber should return true for the first registered stub")
    XCTAssertTrue(NetworkStubber.canInit(with: request2), "NetworkStubber should return true for the second registered stub")

    let expectedLog = [
      adddedStubMessage(url1),
      adddedStubMessage(url2)
    ]
    assertLogSequence(expected: expectedLog)
  }

  func testPurgeStubs() {
    let url = URL(string: "https://api.example.com")!
    let stub = NetworkStub(url: url, data: NetworkStubDataItem(statusCode: 200, data: Data()))

    NetworkStubber.add(stub)
    NetworkStubber.purge()

    let request = URLRequest(url: url)
    XCTAssertFalse(NetworkStubber.canInit(with: request), "NetworkStubber should return false after purging stubs")
  }
}

// MARK: - Helpers

extension NetworkStubberTests {

  @discardableResult
  private func performRequest(
    url: URL,
    stub: NetworkStub,
    expectationDescription: String
  ) -> (Data?, Int?, Error?) {
    NetworkStubber.add(stub)
    let expectation = expectation(description: expectationDescription)

    var responseData: Data?
    var responseStatus: Int?
    var responseError: Error?

    let request = URLRequest(url: url)
    let task = session.dataTask(with: request) { data, response, error in
      responseData = data
      responseError = error
      responseStatus = (response as? HTTPURLResponse)?.statusCode
      expectation.fulfill()
    }

    task.resume()
    wait(for: [expectation], timeout: 2)
    return (responseData, responseStatus, responseError)
  }

  private func assertLogSequence(expected: [String]) {
    XCTAssertEqual(
      logger.loggedMessages,
      expected,
      "Logger messages should match expected sequence"
    )
  }

  private func adddedStubMessage(_ url: URL) -> String {
    "✅ URL: \(url) added to NetworkStubber"
  }

  private func stubbingRequest(_ url: URL) -> String {
    "🧪 Stubbing request for \(url)"
  }

  private func stubbingErrorMessage(_ error: Error) -> String {
    "⚠️ Stubbing error: \(error.localizedDescription)"
  }

  private func stubDataMessage(_ dataStub: NetworkStubDataItem, url: URL) -> String {
    dataStub.isCodable
      ? "📡 Stubbing sending Codable response for \(url): \(dataStub.debugString)"
      : "📡 Stubbing sending Data response for \(url): \(dataStub.debugString)"
  }

  private func stubResponseMessage(_ responseStub: NetworkStubResponseItem, url: URL) -> String {
    "📡 Stubbing response for \(url): \(responseStub.debugString)"
  }

  private func emptyStubMessage(_ url: URL) -> String {
    "⚠️ Stub is empty for \(url), returning without modification"
  }

  private func completionStubMessage(_ url: URL) -> String {
    "🧪 Stubbing completed for \(url)"
  }
}
