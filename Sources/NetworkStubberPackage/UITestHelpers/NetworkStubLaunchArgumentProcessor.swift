//
//  NetworkStubLaunchArgumentProcessor.swift
//  NetworkStubberPackage
//
//  Created by Josh Robbins on 3/20/25.
//

import Foundation

/**
 A utility enum that processes network stub launch arguments for UI tests.

 This allows network stubs to be passed as a JSON string in launch arguments,
 enabling UI tests to use preconfigured stubbed responses.

 Usage:
 - In UI tests, encode `NetworkStub` objects as JSON and pass them via `XCUIApplication.launchArguments`.
 - On app launch, this processor reads and registers the stubs automatically.
 */
public enum NetworkStubLaunchArgumentProcessor {

  /**
   Processes launch arguments to extract and register network stubs.

   This function checks if the `-NetworkStubs` launch argument exists and contains a valid JSON payload.
   If valid, the stubs are decoded and registered with `NetworkStubber`.
   - Note: This function should be called early in the app lifecycle (e.g., in `AppDelegate` or `SceneDelegate`)
     to ensure stubs are applied before network requests are made.
   */
  public static func processLaunchArgumentsForStubs() {
    let arguments = ProcessInfo.processInfo.arguments

    guard
      let stubArgumentIndex = arguments.firstIndex(of: "-NetworkStubs"),
      arguments.indices.contains(stubArgumentIndex + 1)
    else {
      return
    }

    let jsonString = arguments[stubArgumentIndex + 1]
    let decoder = JSONDecoder()

    guard
      let jsonData = jsonString.data(using: .utf8),
      let stubs = try? decoder.decode([NetworkStub].self, from: jsonData)
    else {
      print("🚨 Failed to decode UI Test stubs")
      return
    }

    NetworkStubber.addStubs(stubs)
    print("✅ Successfully loaded \(stubs.count) UI test stubs")
  }
}
