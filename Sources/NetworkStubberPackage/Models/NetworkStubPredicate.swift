//
//  NetworkStubPredicate.swift
//  NetworkStubber
//
//  Created by Josh Robbins on 4/3/25.
//

import Foundation

/// Represents the various predicate types used to evaluate a `URLRequest`.
public indirect enum NetworkStubPredicateType: Codable, Equatable, Sendable {

  // MARK: - Base Types

  /// Matches the HTTP method of the request (e.g., GET, POST).
  case httpMethod(HTTPMethod)

  /// Matches the exact path component of the request URL (e.g., `/api/user`).
  case path(String)

  /// Matches the exact host of the request URL (e.g., `api.example.com`).
  case host(String)

  /// Matches a specific HTTP header field and an optional value (e.g., `"Content-Type": "application/json"`).
  case header(name: String, value: String?)

  /// Matches a header value using a regular expression (e.g., `"Authorization": "Bearer .*"`).
  case headerMatches(name: String, pattern: String)

  /// Matches if a header field exists, regardless of its value.
  case headerExists(String)

  /// Matches the full URL string exactly (e.g., `"https://api.example.com/users"`).
  case urlString(String)

  /// Matches the full URL object exactly.
  case url(URL)

  /// Matches if the path component starts with a specific prefix.
  case pathPrefix(String)

  /// Matches if the path component ends with a specific suffix.
  case pathSuffix(String)

  /// Matches if the path extension matches the given string (e.g., `".json"` or `".png"`).
  case pathExtension(String)

  /// Matches if the last component of the URL path equals the given string.
  case lastPathComponent(String)

  /// Matches if the request URL contains all the specified query items (e.g., `?user=123&type=admin`).
  case containsQueryItems([NetworkStubQueryItem])

  // MARK: - Logical Operands

  /// Combines multiple predicates using a logical AND operation.
  case and([NetworkStubPredicateType])

  /// Combines multiple predicates using a logical OR operation.
  case or([NetworkStubPredicateType])

  /// Negates a single predicate (i.e., logical NOT).
  case not(NetworkStubPredicateType)

  // MARK: - Constants

  /// A predicate that always returns true, useful for matching all requests.
  case alwaysTrue

  /// A predicate that always returns false, useful for disabling stubs conditionally.
  case alwaysFalse
}
// MARK: - Evaluation

extension NetworkStubPredicateType {

  func evaluate(_ request: URLRequest) -> Bool {
    switch self {

    case .httpMethod(let method):
      return request.httpMethod == method.rawValue

    case .path(let expectedPath):
      return request.url?.path == expectedPath

    case .host(let host):
      return request.url?.host == host

    case .header(let name, let value):
      return request.value(forHTTPHeaderField: name) == value

    case .headerMatches(let name, let pattern):
      if let value = request.value(forHTTPHeaderField: name) {
        return (try? NSRegularExpression(pattern: pattern))
          .map { regex in
            let range = NSRange(value.startIndex ..< value.endIndex, in: value)
            return regex.firstMatch(in: value, options: [], range: range) != nil
          } ?? false
      }
      return false

    case .headerExists(let name):
      return request.value(forHTTPHeaderField: name) != nil

    case .urlString(let expectedURLString):
      return request.url?.absoluteString == expectedURLString

    case .url(let expectedURL):
      return request.url == expectedURL

    case .pathPrefix(let prefix):
      return request.url?.path.hasPrefix(prefix) == true

    case .pathSuffix(let suffix):
      return request.url?.path.hasSuffix(suffix) == true

    case .pathExtension(let ext):
      return request.url?.pathExtension == ext

    case .lastPathComponent(let component):
      return request.url?.lastPathComponent == component

    case .containsQueryItems(let expectedItems):
      guard
        let components = URLComponents(
          url: request.url ?? URL(string: "/")!,
          resolvingAgainstBaseURL: false
        ),
        let actualItems = components.queryItems
      else {
        return false
      }
      return expectedItems.map(\.asURLQueryItem).allSatisfy { actualItems.contains($0) }

    case .and(let predicates):
      return predicates.allSatisfy { $0.evaluate(request) }

    case .or(let predicates):
      return predicates.contains { $0.evaluate(request) }

    case .not(let predicate):
      return !predicate.evaluate(request)

    case .alwaysTrue:
      return true

    case .alwaysFalse:
      return false
    }
  }
}

// MARK: - Codable

extension NetworkStubPredicateType {

  private enum CodingKeys: String, CodingKey {
    case type
    case method
    case path
    case host
    case name
    case value
    case pattern
    case urlString
    case url
    case prefix
    case suffix
    case extensionVal
    case component
    case queryItems
    case predicates
    case predicate
  }

  private enum PredicateType: String, Codable {
    case httpMethod
    case path
    case host
    case header
    case headerMatches
    case headerExists
    case urlString
    case url
    case pathPrefix
    case pathSuffix
    case pathExtension
    case lastPathComponent
    case containsQueryItems
    case and
    case or
    case not
    case alwaysTrue
    case alwaysFalse
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let type = try container.decode(PredicateType.self, forKey: .type)

    switch type {
    case .httpMethod:
      self = try .httpMethod(container.decode(HTTPMethod.self, forKey: .method))

    case .path:
      self = try .path(container.decode(String.self, forKey: .path))

    case .host:
      self = try .host(container.decode(String.self, forKey: .host))

    case .header:
      let name = try container.decode(String.self, forKey: .name)
      let value = try container.decodeIfPresent(String.self, forKey: .value)
      self = .header(name: name, value: value)

    case .headerMatches:
      let name = try container.decode(String.self, forKey: .name)
      let pattern = try container.decode(String.self, forKey: .pattern)
      self = .headerMatches(name: name, pattern: pattern)

    case .headerExists:
      self = try .headerExists(container.decode(String.self, forKey: .name))

    case .urlString:
      self = try .urlString(container.decode(String.self, forKey: .urlString))

    case .url:
      self = try .url(container.decode(URL.self, forKey: .url))

    case .pathPrefix:
      self = try .pathPrefix(container.decode(String.self, forKey: .prefix))

    case .pathSuffix:
      self = try .pathSuffix(container.decode(String.self, forKey: .suffix))

    case .pathExtension:
      self = try .pathExtension(container.decode(String.self, forKey: .extensionVal))

    case .lastPathComponent:
      self = try .lastPathComponent(container.decode(String.self, forKey: .component))

    case .containsQueryItems:
      self = try .containsQueryItems(container.decode([NetworkStubQueryItem].self, forKey: .queryItems))

    case .and:
      self = try .and(container.decode([NetworkStubPredicateType].self, forKey: .predicates))

    case .or:
      self = try .or(container.decode([NetworkStubPredicateType].self, forKey: .predicates))

    case .not:
      self = try .not(container.decode(NetworkStubPredicateType.self, forKey: .predicate))

    case .alwaysTrue:
      self = .alwaysTrue

    case .alwaysFalse:
      self = .alwaysFalse
    }
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)

    switch self {
    case .httpMethod(let method):
      try container.encode(PredicateType.httpMethod, forKey: .type)
      try container.encode(method, forKey: .method)

    case .path(let path):
      try container.encode(PredicateType.path, forKey: .type)
      try container.encode(path, forKey: .path)

    case .host(let host):
      try container.encode(PredicateType.host, forKey: .type)
      try container.encode(host, forKey: .host)

    case .header(let name, let value):
      try container.encode(PredicateType.header, forKey: .type)
      try container.encode(name, forKey: .name)
      try container.encodeIfPresent(value, forKey: .value)

    case .headerMatches(let name, let pattern):
      try container.encode(PredicateType.headerMatches, forKey: .type)
      try container.encode(name, forKey: .name)
      try container.encode(pattern, forKey: .pattern)

    case .headerExists(let name):
      try container.encode(PredicateType.headerExists, forKey: .type)
      try container.encode(name, forKey: .name)

    case .urlString(let urlString):
      try container.encode(PredicateType.urlString, forKey: .type)
      try container.encode(urlString, forKey: .urlString)

    case .url(let url):
      try container.encode(PredicateType.url, forKey: .type)
      try container.encode(url, forKey: .url)

    case .pathPrefix(let prefix):
      try container.encode(PredicateType.pathPrefix, forKey: .type)
      try container.encode(prefix, forKey: .prefix)

    case .pathSuffix(let suffix):
      try container.encode(PredicateType.pathSuffix, forKey: .type)
      try container.encode(suffix, forKey: .suffix)

    case .pathExtension(let ext):
      try container.encode(PredicateType.pathExtension, forKey: .type)
      try container.encode(ext, forKey: .extensionVal)

    case .lastPathComponent(let component):
      try container.encode(PredicateType.lastPathComponent, forKey: .type)
      try container.encode(component, forKey: .component)

    case .containsQueryItems(let items):
      try container.encode(PredicateType.containsQueryItems, forKey: .type)
      try container.encode(items, forKey: .queryItems)

    case .and(let predicates):
      try container.encode(PredicateType.and, forKey: .type)
      try container.encode(predicates, forKey: .predicates)

    case .or(let predicates):
      try container.encode(PredicateType.or, forKey: .type)
      try container.encode(predicates, forKey: .predicates)

    case .not(let predicate):
      try container.encode(PredicateType.not, forKey: .type)
      try container.encode(predicate, forKey: .predicate)

    case .alwaysTrue:
      try container.encode(PredicateType.alwaysTrue, forKey: .type)

    case .alwaysFalse:
      try container.encode(PredicateType.alwaysFalse, forKey: .type)
    }
  }
}

/// A type-erased predicate that can be composed, evaluated, and encoded.
///
/// This wraps a codable `NetworkStubPredicateType` and provides a `description` for logging/debugging.
public struct NetworkStubPredicate: CustomStringConvertible, Sendable, Codable {

  /// A human-readable description of the predicate.
  public let description: String

  /// The underlying predicate type (Codable and evaluatable).
  public let predicateType: NetworkStubPredicateType

  /// Creates a new stub predicate from a typed predicate and an optional description.
  public init(
    _ predicateType: NetworkStubPredicateType,
    description: String? = nil
  ) {
    self.predicateType = predicateType
    self.description = description ?? String(describing: predicateType)
  }

  /// Evaluates the predicate against a given URLRequest.
  public func evaluate(_ request: URLRequest) -> Bool {
    predicateType.evaluate(request)
  }
}

extension NetworkStubPredicate: Equatable {

  public static func == (lhs: NetworkStubPredicate, rhs: NetworkStubPredicate) -> Bool {
    lhs.predicateType == rhs.predicateType
  }
}

// MARK: - Logical Operators

extension NetworkStubPredicate {

  /// Logical OR of two predicates.
  public static func || (lhs: NetworkStubPredicate, rhs: NetworkStubPredicate) -> NetworkStubPredicate {
    NetworkStubPredicate(
      .or([lhs.predicateType, rhs.predicateType]),
      description: "(\(lhs.description) OR \(rhs.description))"
    )
  }

  /// Logical AND of two predicates.
  public static func && (lhs: NetworkStubPredicate, rhs: NetworkStubPredicate) -> NetworkStubPredicate {
    NetworkStubPredicate(
      .and([lhs.predicateType, rhs.predicateType]),
      description: "(\(lhs.description) AND \(rhs.description))"
    )
  }

  /// Logical NOT of a predicate.
  public static prefix func ! (predicate: NetworkStubPredicate) -> NetworkStubPredicate {
    NetworkStubPredicate(
      .not(predicate.predicateType),
      description: "NOT (\(predicate.description))"
    )
  }

  /// A predicate that always returns true.
  public static var alwaysTrue: NetworkStubPredicate {
    NetworkStubPredicate(.alwaysTrue, description: "TRUE")
  }

  /// A predicate that always returns false.
  public static var alwaysFalse: NetworkStubPredicate {
    NetworkStubPredicate(.alwaysFalse, description: "FALSE")
  }
}

// MARK: - URLRequest Predicates

extension NetworkStubPredicate {

  /// Matches if the HTTP method equals the specified method.
  /// - Parameter method: The expected HTTP method (e.g., GET, POST).
  /// - Returns: A predicate that matches requests with the given HTTP method.
  public static func isHTTPMethod(_ method: HTTPMethod) -> NetworkStubPredicate {
    NetworkStubPredicate(.httpMethod(method), description: "HTTP method is \(method.rawValue)")
  }

  /// Matches if the request contains a header with the specified name.
  /// - Parameter name: The name of the HTTP header field.
  /// - Returns: A predicate that matches requests containing the header field.
  public static func hasHeaderField(name: String) -> NetworkStubPredicate {
    NetworkStubPredicate(
      .headerExists(name),
      description: "Header contains '\(name)'"
    )
  }

  /// Matches if the request contains a header with the specified name and value.
  /// - Parameters:
  ///   - name: The name of the HTTP header field.
  ///   - value: The expected value of the header field.
  /// - Returns: A predicate that matches requests where the header equals the given value.
  public static func hasHeaderField(name: String, value: String) -> NetworkStubPredicate {
    NetworkStubPredicate(
      .header(name: name, value: value),
      description: "Header '\(name)' is '\(value)'"
    )
  }

  /// Matches if the value of a request header matches a regular expression pattern.
  /// - Parameters:
  ///   - name: The name of the HTTP header field.
  ///   - pattern: A regular expression pattern to match against the header value.
  /// - Returns: A predicate that matches requests where the header value matches the pattern.
  public static func headerFieldMatches(name: String, pattern: String) -> NetworkStubPredicate {
    NetworkStubPredicate(
      .headerMatches(name: name, pattern: pattern),
      description: "Header '\(name)' matches pattern '\(pattern)'"
    )
  }
}

// MARK: - URL Predicates

extension NetworkStubPredicate {

  /// Creates a predicate that matches if the full URL equals the specified `URL`.
  ///
  /// - Parameter url: The expected full `URL`.
  /// - Returns: A predicate that matches if the request URL exactly equals the provided `url`.
  public static func isURL(_ url: URL) -> NetworkStubPredicate {
    NetworkStubPredicate(.url(url), description: "URL is \(url.absoluteString)")
  }

  /// Creates a predicate that matches if the full URL string equals the specified string.
  ///
  /// - Parameter urlString: The full URL string to match.
  /// - Returns: A predicate that matches if the request URL string exactly equals the provided string.
  public static func isURLString(_ urlString: String) -> NetworkStubPredicate {
    NetworkStubPredicate(.urlString(urlString), description: "URL string is \(urlString)")
  }

  /// Creates a predicate that matches if the host of the URL equals the specified host.
  ///
  /// - Parameter host: The expected host.
  /// - Returns: A predicate that matches if the URL host equals the provided value.
  public static func isHost(_ host: String) -> NetworkStubPredicate {
    NetworkStubPredicate(.host(host), description: "Host is \(host)")
  }

  /// Creates a predicate that matches if the path of the URL equals the specified path.
  ///
  /// - Parameter path: The expected path component (e.g. "/api/users").
  /// - Returns: A predicate that matches if the URL path exactly equals the provided path.
  public static func isPath(_ path: String) -> NetworkStubPredicate {
    NetworkStubPredicate(.path(path), description: "Path is \(path)")
  }

  /// Creates a predicate that matches if the URL path starts with the specified prefix.
  ///
  /// - Parameter prefix: The expected prefix (e.g. "/api").
  /// - Returns: A predicate that matches if the path starts with the given prefix.
  public static func hasPathPrefix(_ prefix: String) -> NetworkStubPredicate {
    NetworkStubPredicate(.pathPrefix(prefix), description: "Path has prefix '\(prefix)'")
  }

  /// Creates a predicate that matches if the URL path ends with the specified suffix.
  ///
  /// - Parameter suffix: The expected suffix (e.g. ".json").
  /// - Returns: A predicate that matches if the path ends with the given suffix.
  public static func hasPathSuffix(_ suffix: String) -> NetworkStubPredicate {
    NetworkStubPredicate(.pathSuffix(suffix), description: "Path has suffix '\(suffix)'")
  }

  /// Creates a predicate that matches if the URL has the specified path extension.
  ///
  /// - Parameter ext: The expected file extension (e.g. "xml", "json").
  /// - Returns: A predicate that matches if the URL path has the specified extension.
  public static func hasPathExtension(_ ext: String) -> NetworkStubPredicate {
    NetworkStubPredicate(.pathExtension(ext), description: "Path has extension '\(ext)'")
  }

  /// Creates a predicate that matches if the last path component of the URL equals the specified value.
  ///
  /// - Parameter component: The expected last path component.
  /// - Returns: A predicate that matches if the last path component matches.
  public static func hasLastPathComponent(_ component: String) -> NetworkStubPredicate {
    NetworkStubPredicate(.lastPathComponent(component), description: "Last path component is '\(component)'")
  }

  /// Creates a predicate that matches if the URL contains all of the specified query items.
  ///
  /// - Parameter queryItems: The query items that must be present in the request URL.
  /// - Returns: A predicate that matches if all provided query items exist in the URL.
  public static func containsQueryItems(_ queryItems: [URLQueryItem]) -> NetworkStubPredicate {
    let codableItems = queryItems.map { NetworkStubQueryItem($0) }
    return NetworkStubPredicate(
      .containsQueryItems(codableItems),
      description: "Query items contain \(queryItems)"
    )
  }
}
