<img src="Media/netwworkStubberLogo.png" alt="iOS Swift URLSessionProtocol Mocking Package" width="299.95" height="211.05" />

A simple wrapper around URLProtocol that allows you to intercept and stub URLSession network requests in Swift by:
1. Simulating network failures.
2. Returning custom response data with HTTP status codes.
3. Returning full HTTP responses with headers and body.

## Getting Started:

### Basic Functions:

Network Stubber works by intercepting URLSession requests.
To get started, create a `NetworkStub` which conforms to `NetworkStubProtocol` and add it to NetworkStubber.

```swift
/// Adds a single network stub to the stub store.
/// - Parameter stub: The `NetworkStub` instance to be added.
public static func add(_ stub: NetworkStub?) { }

/// Adds multiple network stubs to the stub store.
/// - Parameter stubs: An array of `NetworkStub` instances to be added.
public static func addStubs(_ stubs: [NetworkStub?]) { }

/// Sets a custom logger for the `NetworkStubber`.
/// - Parameter customLogger: A logger conforming to `NetworkStubberLogProtocol` to handle log messages.
public static func setLogger(_ customLogger: NetworkStubberLogProtocol) { }

/// Removes all stored network stubs from the stub store.
public static func purge() { }
```

### Available Predicates:

```swift
// Matches if the host of the URL equals the specified host.
.isHost("example.com")

// Matches if the path of the URL equals the specified path.
.isPath("/api")

// Matches if the HTTP method equals the specified method.
.isHTTPMethod(.get)

// Matches if the request contains a header with the specified name and value.
.hasHeaderField(name: "Content-Type", value: "application/json")

// Matches if the request contains a header with the specified name (value ignored).
.hasHeaderField(name: "Authorization")

// Matches if the value of a request header matches a regular expression pattern.
.headerFieldMatches(name: "Accept", pattern: "application/json.*")

// Matches if the full URL equals the specified `URL`.
.isURL(URL(string: "https://example.com")!)

// Matches if the full URL string equals the specified string.
.isURLString("https://example.com/path")

// Matches if the URL path starts with the specified prefix.
.hasPathPrefix("/api")

// Matches if the URL path ends with the specified suffix.
.hasPathSuffix(".json")

// Matches if the URL has the specified path extension.
.hasPathExtension("json")

// Matches if the last path component of the URL equals the specified value.
.hasLastPathComponent("index.json")

// Matches if the URL contains all of the specified query items.
.containsQueryItems([URLQueryItem(name: "id", value: "123")])

// MARK: - Logical Composition

// Negates a predicate.
!NetworkStubPredicate.isHost("example.com")

// Logical AND of multiple predicates.
NetworkStubPredicate.isPath("/foo") && NetworkStubPredicate.isHTTPMethod(.get)

// Logical OR of multiple predicates.
NetworkStubPredicate.isPath("/foo") || NetworkStubPredicate.isPath("/bar")

// MARK: - Constants

// A predicate that always returns true.
.alwaysTrue

// A predicate that always returns false.
.alwaysFalse
```

### Creating A Data Stub:

```swift
let predicate = NetworkStubPredicate.isPath("/data")
let responseData = Data("{ \"message\": \"Hello, world!\" }".utf8)
let dataItem = NetworkStubDataItem(statusCode: 200, data: responseData)
let stub = NetworkStub(predicate: predicate, data: dataItem)
NetworkStubber.add(stub)
```

### Creating A Full HTTP Response Stub:

```swift
let predicate = NetworkStubPredicate.isURL(URL(string: "https://api.example.com/data")!)
let httpResponse = HTTPURLResponse(url: predicate.predicateType.url!, statusCode: 404, httpVersion: nil, headerFields: ["Content-Type": "application/json"])!
let responseData = Data("{ \"error\": \"Not Found\" }".utf8)
let responseItem = NetworkStubResponseItem(response: httpResponse, data: responseData)
let responseStub = NetworkStub(predicate: predicate, response: responseItem)
NetworkStubber.add(responseStub)
```

### Creating An Error Stub:

```swift
let predicate = NetworkStubPredicate.isHost("api.example.com")
let error = NSError(domain: "com.example.error", code: -1009, userInfo: nil)
let errorStub = NetworkStub(predicate: predicate, error: error)
NetworkStubber.add(errorStub)
```

### Creating A Chain Of Stubs:

```swift
let stubA = NetworkStub(
  predicate: .isPath("/auth"),
  data: NetworkStubDataItem(statusCode: 200, data: Data("{ \"token\": \"abc123\" }".utf8))
)

let stubB = NetworkStub(
  predicate: .isPath("/profile"),
  data: NetworkStubDataItem(statusCode: 200, data: Data("{ \"name\": \"John\", \"age\": 30 }".utf8))
)

NetworkStubber.addStubs([stubA, stubB])
```

## Registering Network Stubber:

```swift
let configuration = URLSessionConfiguration.ephemeral
configuration.protocolClasses = [NetworkStubber.self]
let session = URLSession(configuration: configuration)
```

## Logging:

```swift
struct MyLogger: NetworkStubberLogProtocol {
  func log(_ message: String) {
    print("[NetworkStubber] \(message)")
  }
}
NetworkStubber.setLogger(MyLogger())
```

## UI Tests:

### Set Launch Arguments

```swift
func setLaunchArgumentsForStubs(_ stubs: [NetworkStub]) {
  let encoder = JSONEncoder()
  let data = try! encoder.encode(stubs)
  let base64 = data.base64EncodedString()
  app.launchArguments += ["-NetworkStubs", base64]
}
```

### Launch Argument Decoding:

```swift
NetworkStubLaunchArgumentProcessor.processLaunchArgumentsForStubs()
```
