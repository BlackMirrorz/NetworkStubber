//
//  NetworkStubberDemoTests.swift
//  NetworkStubberDemoTests
//
//  Created by Josh Robbins on 3/20/25.
//

import XCTest
import NetworkStubberPackage

final class NetworkStubberDemoUITests: XCTestCase {

    private let app = XCUIApplication()

    func testSetLaunchArgumentsForStubs() {
        let stub = NetworkStub(
            url: URL(string: "https://api.example.com/data")!,
            data: NetworkStubDataItem(statusCode: 200, data: Data("{ \"message\": \"Hello!\" }".utf8))
        )

        // ✅ Set launch arguments BEFORE launching
        app.setLaunchArgumentsForStubs([stub])
        app.launch()

        XCTAssertTrue(
            app.launchArguments.contains("-NetworkStubs"),
            "Launch arguments should contain the network stubs flag"
        )

        guard let jsonIndex = app.launchArguments.firstIndex(of: "-NetworkStubs"),
              app.launchArguments.indices.contains(jsonIndex + 1) else {
            XCTFail("No JSON stub data found in launch arguments")
            return
        }

        let jsonString = app.launchArguments[jsonIndex + 1]

        let decoder = JSONDecoder()
        guard let jsonData = jsonString.data(using: .utf8),
              let decodedStubs = try? decoder.decode([NetworkStub].self, from: jsonData) else {
            XCTFail("Failed to decode JSON stub data from launch arguments")
            return
        }

        XCTAssertEqual(decodedStubs.count, 1, "There should be one stub in the JSON data")
    }
}
