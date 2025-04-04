//
//  NetwrokStubberPrediicateBuilder.swift
//  NetworkStubber
//
//  Created by Josh Robbins on 4/3/25.
//

import Foundation

/// A builder class for composing `NetworkStubPredicate`
public final class NetworkStubPredicateBuilder {

  private var predicates: [NetworkStubPredicate] = []

  // MARK: - Initialization

  /// Initializes a new builder.
  public init() {}
}

// MARK: - Builders

extension NetworkStubPredicateBuilder {

  /// Adds a predicate that matches the specified HTTP method.
  /// - Parameter method: The HTTP method to match (e.g., `.get`, `.post`).
  /// - Returns: The builder instance for chaining.
  @discardableResult
  public func method(_ method: HTTPMethod) -> Self {
    predicates.append(.isHTTPMethod(method))
    return self
  }

  /// Adds a predicate that checks for the presence of the specified HTTP header field.
  /// - Parameter name: The name of the header field.
  /// - Returns: The builder instance for chaining.
  @discardableResult
  public func header(_ name: String) -> Self {
    predicates.append(.hasHeaderField(name: name))
    return self
  }

  /// Adds a predicate that checks for a specific HTTP header field and value.
  /// - Parameters:
  ///   - name: The name of the header field.
  ///   - value: The expected value of the header field.
  /// - Returns: The builder instance for chaining.
  @discardableResult
  public func header(_ name: String, equals value: String) -> Self {
    predicates.append(.hasHeaderField(name: name, value: value))
    return self
  }

  /// Adds a predicate that matches a specific URL.
  /// - Parameter url: The exact URL to match.
  /// - Returns: The builder instance for chaining.
  @discardableResult
  public func url(_ url: URL) -> Self {
    predicates.append(.isURL(url))
    return self
  }

  /// Adds a predicate that matches a specific URL string.
  /// - Parameter urlString: The full URL string to match.
  /// - Returns: The builder instance for chaining.
  @discardableResult
  public func urlString(_ urlString: String) -> Self {
    predicates.append(.isURLString(urlString))
    return self
  }

  /// Adds a predicate that matches a specific host.
  /// - Parameter host: The host component of the URL to match.
  /// - Returns: The builder instance for chaining.
  @discardableResult
  public func host(_ host: String) -> Self {
    predicates.append(.isHost(host))
    return self
  }

  /// Adds a predicate that matches a specific path.
  /// - Parameter path: The full path of the URL to match.
  /// - Returns: The builder instance for chaining.
  @discardableResult
  public func path(_ path: String) -> Self {
    predicates.append(.isPath(path))
    return self
  }

  /// Adds a predicate that matches URLs with a specific path prefix.
  /// - Parameter prefix: The prefix to match in the URL path.
  /// - Returns: The builder instance for chaining.
  @discardableResult
  public func pathPrefix(_ prefix: String) -> Self {
    predicates.append(.hasPathPrefix(prefix))
    return self
  }

  /// Adds a predicate that matches URLs with a specific path suffix.
  /// - Parameter suffix: The suffix to match in the URL path.
  /// - Returns: The builder instance for chaining.
  @discardableResult
  public func pathSuffix(_ suffix: String) -> Self {
    predicates.append(.hasPathSuffix(suffix))
    return self
  }

  /// Adds a predicate that matches URLs with a specific path extension.
  /// - Parameter ext: The file extension to match in the URL path.
  /// - Returns: The builder instance for chaining.
  @discardableResult
  public func pathExtension(_ ext: String) -> Self {
    predicates.append(.hasPathExtension(ext))
    return self
  }

  /// Adds a predicate that matches URLs with a specific last path component.
  /// - Parameter component: The last component of the URL path to match.
  /// - Returns: The builder instance for chaining.
  @discardableResult
  public func lastPathComponent(_ component: String) -> Self {
    predicates.append(.hasLastPathComponent(component))
    return self
  }

  /// Adds a predicate that matches if the URL contains all specified query items.
  /// - Parameter queryItems: An array of `URLQueryItem` to match.
  /// - Returns: The builder instance for chaining.
  @discardableResult
  public func containsQueryItems(_ queryItems: [URLQueryItem]) -> Self {
    predicates.append(.containsQueryItems(queryItems))
    return self
  }
}

// MARK: - Builder Finalization

extension NetworkStubPredicateBuilder {

  /// Combines all added predicates into a single `NetworkStubPredicate` using logical AND.
  /// - Returns: A composed predicate that passes only if all individual predicates pass.
  public func build() -> NetworkStubPredicate {
    switch predicates.count {
    case 0:
      return .alwaysTrue
    case 1:
      return predicates[0]
    default:
      return NetworkStubPredicate(
        .and(predicates.map(\.predicateType)),
        description: predicates.map(\.description).joined(separator: " AND ")
      )
    }
  }
}
