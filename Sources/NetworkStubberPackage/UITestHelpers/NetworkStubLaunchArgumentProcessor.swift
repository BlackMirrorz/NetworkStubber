//
//  NetworkStubLaunchArgumentProcessor.swift
//  NetworkStubberPackage
//
//  Created by Josh Robbins on 3/20/25.
//

//
//  NetworkStubLaunchArgumentProcessor.swift
//  NetworkStubberPackage
//
//  Created by Josh Robbins on 3/20/25.
//

import Foundation
import OSLog

private let logger = Logger(subsystem: "networkStubber", category: "launchArguments")

/**
 A utility enum that processes network stub launch arguments for UI tests.

 This allows network stubs to be passed as a Base64-encoded JSON string in launch arguments
 or environment variables, enabling UI tests to use preconfigured stubbed responses.

 ## Usage:
 - In UI tests, encode `NetworkStub` objects as Base64 JSON and pass them via `XCUIApplication.launchArguments`
   or as an environment variable.
 - On app launch, this processor reads the arguments, decodes them, and registers the stubs automatically.

 ## Behavior:
 - If the `-NetworkStubs` environment variable is set, it is prioritized over launch arguments.
 - If the environment variable is absent, it falls back to checking `-NetworkStubs` in launch arguments.
 - Stubs are decoded from Base64 and passed to `NetworkStubber` for use in UI tests.
 */
public enum NetworkStubLaunchArgumentProcessor {

  /**
   Processes launch arguments and environment variables to extract and register network stubs.

   This function first checks if the `-NetworkStubs` environment variable is set and contains a valid
   Base64-encoded JSON payload. If found, the stubs are decoded and registered with `NetworkStubber`.

   If the environment variable is not set, it falls back to checking the `-NetworkStubs` launch argument.

   - Parameter verboseLogging: Enables detailed logging of the decoding and processing steps.
   - Note: This function should be called early in the app lifecycle (e.g., in `AppDelegate` or `SceneDelegate`)
     to ensure stubs are applied before network requests are made.
   */
  public static func processLaunchArgumentsForStubs(verboseLogging: Bool = true) {
    let arguments = ProcessInfo.processInfo.arguments

    logMessage("📩 Launch Arguments: \(arguments)", verbose: verboseLogging)

    guard
      let stubArgumentIndex = arguments.firstIndex(of: "-NetworkStubs"),
      arguments.indices.contains(stubArgumentIndex + 1)
    else {
      logMessage("🚨 No -NetworkStubs argument found", verbose: verboseLogging)
      return
    }

    let base64String = arguments[stubArgumentIndex + 1]
    decodeAndRegisterStubs(from: base64String, verboseLogging: verboseLogging)
  }

  /**
   Decodes and registers network stubs from a Base64-encoded JSON string.

   This function attempts to decode the given Base64 string into an array of `NetworkStub` objects.
   If successful, the stubs are registered for use in UI tests.

   - Parameters:
     - base64String: The Base64-encoded JSON string containing the network stubs.
     - verboseLogging: Enables detailed logging for debugging purposes.
   */
  private static func decodeAndRegisterStubs(from base64String: String, verboseLogging: Bool) {
    guard let jsonData = Data(base64Encoded: base64String) else {
      logMessage("🚨 Failed to decode Base64 string for NetworkStubs", verbose: verboseLogging)
      return
    }

    let decoder = JSONDecoder()

    do {
      let stubs = try decoder.decode([NetworkStub].self, from: jsonData)
      logMessage("✅ Successfully parsed \(stubs.count) NetworkStubs", verbose: verboseLogging)
      NetworkStubber.addStubs(stubs)
    } catch {
      logMessage("🚨 JSON Decoding Error: \(error.localizedDescription)", verbose: verboseLogging)
    }
  }

  /**
   Logs a message using `OSLog`, but only if verbose logging is enabled.

   - Parameters:
     - message: The message to log.
     - verbose: A flag indicating whether logging should be performed.
   */
  private static func logMessage(_ message: String, verbose: Bool) {
    guard verbose else { return }
    logger.info("\(message, privacy: .public)")
  }
}
