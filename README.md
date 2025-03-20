<img src="Media/netwworkStubberLogo.png" alt="iOS Swift URLSessionProtocol Mocking Package" width="427.5" height="301.5" />

A simple wrapper around URLProtocol that allows you to intercept and stub URLSession network requests in Swift by:
1. Simulating network failures.
2. Returning custom response data with HTTP status codes.
3. Returnin full HTTP responses with headers and body.

## Available Functions:

```swift
/// Adds a single network stub to the stub store.
/// - Parameter stub: The `NetworkStub` instance to be added.
public static func add(_ stub: NetworkStub) { }

/// Adds multiple network stubs to the stub store.
/// - Parameter stubs: An array of `NetworkStub` instances to be added.
public static func addStubs(_ stubs: [NetworkStub]) { }

/// Sets a custom logger for the `NetworkStubber`.
/// - Parameter customLogger: A logger conforming to `NetworkStubberLogProtocol` to handle log messages.
public static func setLogger(_ customLogger: NetworkStubberLogProtocol) { }

/// Removes all stored network stubs from the stub store.
public static func purge() { }
```

## Getting Started:

Network Stubber works by intercepting URLSession requests.
To get started, create a `NetworkStub` which conforms to `NetworkStubProtocol` and add it to NetworkStubber.

### Creating An Error Stub:

To simulate an error response you can do the following:
```swift
let url = URL(string: "https://api.example.com/data")!
let error = NSError(domain: "com.example.error", code: -1009, userInfo: nil)
let errorStub = NetworkStub(url: url, error: error)
NetworkStubber.addStub(errorStub)
```

### Creating A Data Stub:

To simulate a successful data response you can use a `NetworkStubDataItem`:
```swift
let url = URL(string: "https://api.example.com/data")!
let responseData = Data("{ \"message\": \"Hello, world!\" }".utf8)
let dataItem = NetworkStubDataItem(statusCode: 200, data: responseData)
let stub = NetworkStub(url: url, data: dataItem)
NetworkStubber.addStub(stub)
```

### Creating A Full HTTP Response Stub:

To to simulate a full HTTP response you can use a `NetworkStubResponseItem`:
```swift
let url = URL(string: "https://api.example.com/data")!
let httpResponse = HTTPURLResponse(url: url, statusCode: 404, httpVersion: nil, headerFields: ["Content-Type": "application/json"])!
let responseData = Data("{ \"error\": \"Not Found\" }".utf8)
let responseItem = NetworkStubResponseItem(response: httpResponse, data: responseData)
let responseStub = NetworkStub(url: url, response: responseItem)
NetworkStubber.addStub(responseStub)
```

### Creating A Chain Of Stubs:

Sometimes you might need to stub multiple calls to simulate a flow in your app.

```swift
let authURL = URL(string: "https://api.example.com/auth")!
let authResponseData = Data("{ \"token\": \"abc123\" }".utf8)
let authDataItem = NetworkStubDataItem(statusCode: 200, data: authResponseData)
let authStub = NetworkStub(url: authURL, data: authDataItem)

let profileURL = URL(string: "https://api.example.com/profile")!
let profileResponseData = Data("{ \"name\": \"John Doe\", \"age\": 30 }".utf8)
let profileDataItem = NetworkStubDataItem(statusCode: 200, data: profileResponseData)
let profileStub = NetworkStub(url: profileURL, data: profileDataItem)

NetworkStubber.addStubs([authStub, profileStub])
```

## Registering Network Stubber:

In order to use your stubs you need to register the NetworkStubber:

```swift
let configuration = URLSessionConfiguration.ephemeral
configuration.protocolClasses = [NetworkStubber.self]
session = URLSession(configuration: configuration)
```

## Logging:

Logging can be invaluable for tracking network requests, diagnosing issues, and understanding app behavior during testing.
Network Stubber allows you to configure your own logger by conforming to the `NetworkStubberLogProtocol`.


```swift
struct TreeLogger: NetworkStubberLogProtocol {
    func log(_ message: String) {
        print("[NetworkStubber] \(message)")
    }
}
NetworkStubber.setLogger(TreeLogger())
```
