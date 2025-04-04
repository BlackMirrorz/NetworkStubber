import Foundation
import os

private let logger = Logger(subsystem: "networkStubber", category: "launchArguments")

/**
 A utility that processes Base64-encoded launch arguments or environment variables to decode and register `[NetworkStub]` instances.
 ## Usage:
 - Encode `[NetworkStub]` to JSON, then Base64.
 - Pass as `-NetworkStubs` launch argument, or set `NetworkStubs` environment variable.

 ## Note:
 This processor must run at app launch (e.g., in `AppDelegate`) before network requests begin.
 */
public enum NetworkStubLaunchArgumentProcessor {

  /// Key used in launch arguments.
  private static let argumentKey = "-NetworkStubs"

  /// Key used in environment variables.
  private static let environmentKey = "NetworkStubs"

  /**
   Processes launch arguments and environment to decode and register `[NetworkStub]`.

   Priority:
   1. Environment variable `NetworkStubs`
   2. Launch argument `-NetworkStubs <Base64 JSON>`

   - Parameter verboseLogging: Whether to log internal decoding and registration steps.
   */
  public static func processLaunchArgumentsForStubs(verboseLogging: Bool = true) {
    let processInfo = ProcessInfo.processInfo

    if let envString = processInfo.environment[environmentKey] {
      logMessage("📦 Found environment variable `NetworkStubs`", verbose: verboseLogging)
      decodeAndRegisterStubs(from: envString, verboseLogging: verboseLogging)
      return
    }

    let arguments = processInfo.arguments
    logMessage("🧾 Launch Arguments: \(arguments)", verbose: verboseLogging)

    guard
      let index = arguments.firstIndex(of: argumentKey),
      arguments.indices.contains(index + 1)
    else {
      logMessage("⚠️ No `-NetworkStubs` argument found", verbose: verboseLogging)
      return
    }

    let base64String = arguments[index + 1]
    decodeAndRegisterStubs(from: base64String, verboseLogging: verboseLogging)
  }

  /**
   Decodes a Base64-encoded JSON array of `[NetworkStub]` and registers them with `NetworkStubber`.

   - Parameters:
     - base64String: A Base64-encoded JSON string of stubs.
     - verboseLogging: Whether to log decoding and registration steps.
   */
  private static func decodeAndRegisterStubs(from base64String: String, verboseLogging: Bool) {
    guard
      let jsonData = Data(base64Encoded: base64String)
    else {
      logMessage("🚫 Failed to decode Base64 string", verbose: verboseLogging)
      return
    }

    do {
      let stubs = try JSONDecoder().decode([NetworkStub].self, from: jsonData)
      logMessage("✅ Successfully decoded \(stubs.count) NetworkStub(s)", verbose: verboseLogging)
      NetworkStubber.addStubs(stubs)
    } catch {
      logMessage("❌ Failed to decode [NetworkStub]: \(error.localizedDescription)", verbose: verboseLogging)
    }
  }

  /// Logs a message to the OS Logger if verbose mode is enabled.
  private static func logMessage(_ message: String, verbose: Bool) {
    guard verbose else { return }
    logger.info("\(message, privacy: .public)")
  }
}
