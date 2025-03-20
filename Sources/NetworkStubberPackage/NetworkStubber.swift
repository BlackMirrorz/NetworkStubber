//
//  NetworkStubber.swift
//  NetworkStubber
//
//  Created by Josh Robbins on 3/20/25.
//

import Foundation

/**
 A URL protocol subclass that intercepts and stubs network requests.
 */
public class NetworkStubber: URLProtocol {

  private static var stubStore: [URL: NetworkStub] = [:]
  private static var logger: NetworkStubberLogProtocol?

  /**
   Determines whether this protocol can handle the given request.
   */
  public override class func canInit(with request: URLRequest) -> Bool {
    guard let url = request.url else { return false }
    let stubExists = stubStore.stub(for: url) != nil
    return stubExists
  }

  /**
   Returns a canonical version of the request.
   */
  public override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

  /**
   Starts loading the request.
   */
  public override func startLoading() {

    guard
      let url = request.url,
      let store = NetworkStubber.stubStore.stub(for: url)
    else {
      NetworkStubber.logger?.logMessage(
        "❌ Failed to stub request for \(String(describing: request.url))"
      )
      return
    }

    NetworkStubber.logger?.logMessage("🧪 Stubbing request for \(url)")

    switch store.type {
    case .error:
      guard let error = store.error else { return }
      handleStubError(error)
    case .data:
      guard let dataStub = store.data, let response = dataStub.httpURLResponse(url: url) else { return }
      handleStubData(dataStub, response: response, url: url)
    case .response:
      guard let stubResponse = store.response else { return }
      handleStubResponse(stubResponse, url: url)
    case .empty:
      NetworkStubber.logger?.logMessage(
        "⚠️ Stub is empty for \(url), returning without modification"
      )
      client?.urlProtocolDidFinishLoading(self)
    }

    NetworkStubber.logger?.logMessage(
      "🧪 Stubbing completed for \(url)"
    )
  }

  /**
   Stops loading the request.
   */
  public override func stopLoading() {}
}

// MARK: - Public Methods

extension NetworkStubber {

  /// Adds a single network stub to the stub store.
  /// - Parameter stub: The `NetworkStub` instance to be added.
  public static func add(_ stub: NetworkStub) {
    stubStore[stub.url] = stub
    logger?.logMessage("✅ URL: \(stub.url) added to NetworkStubber")
  }

  /// Adds multiple network stubs to the stub store.
  /// - Parameter stubs: An array of `NetworkStub` instances to be added.
  public static func addStubs(_ stubs: [NetworkStub]) {
    stubs.forEach { add($0) }
  }

  /// Sets a custom logger for the `NetworkStubber`.
  /// - Parameter customLogger: A logger conforming to `NetworkStubberLogProtocol` to handle log messages.
  public static func setLogger(_ customLogger: NetworkStubberLogProtocol) {
    logger = customLogger
  }

  /// Removes all stored network stubs from the stub store.
  public static func purge() {
    stubStore.removeAll()
  }
}

// MARK: - Internal Helper Functions

extension NetworkStubber {

  /**
   Handles a stubbed network error by logging the issue and sending a failure response to the client.
   - Parameter error: The simulated network error that should be returned.
   */
  private func handleStubError(_ error: Error) {
    NetworkStubber.logger?.logMessage("⚠️ Stubbing error: \(error.localizedDescription)")
    client?.urlProtocol(self, didFailWithError: error)
  }

  /**
   Handles a stubbed response containing **only data** (without HTTP headers).

   This function logs the response and sends it to the client, determining if the data is
   from a `Codable` object or raw `Data`.

   - Parameters:
   - dataStub: The stubbed data response, including HTTP status code.
   - response: The automatically generated `HTTPURLResponse` associated with the data.
   - url: The URL that was stubbed.
   */
  private func handleStubData(_ dataStub: NetworkStubDataItem, response: HTTPURLResponse, url: URL) {
    let logMessage = dataStub.isCodable
      ? "📡 Stubbing sending Codable response for \(url): \(dataStub.debugString)"
      : "📡 Stubbing sending Data response for \(url): \(dataStub.debugString)"

    NetworkStubber.logger?.logMessage(logMessage)
    setClient(response: response, dataToLoad: dataStub.data)
  }

  /**
   Handles a full HTTP response stub, including headers, status code, and body.
   - Parameters:
   - stubResponse: The full `NetworkStubResponseItem`, containing an `HTTPURLResponse` and data.
   - url: The URL that was stubbed.
   */
  private func handleStubResponse(_ stubResponse: NetworkStubResponseItem, url: URL) {
    NetworkStubber.logger?.logMessage("📡 Stubbing response for \(url): \(stubResponse.debugString)")
    setClient(response: stubResponse.response, dataToLoad: stubResponse.data)
  }

  /**
   Sends the stubbed response and data back to the client.
   This function is used by both `handleStubData(_:)` and `handleStubResponse(_:)` to pass the simulated response to the client.

   - Parameters:
   - response: The `HTTPURLResponse` containing status code and headers.
   - dataToLoad: The raw data payload to be sent in the response body.
   */
  private func setClient(response: HTTPURLResponse, dataToLoad: Data) {
    client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
    client?.urlProtocol(self, didLoad: dataToLoad)
    client?.urlProtocolDidFinishLoading(self)
  }
}
