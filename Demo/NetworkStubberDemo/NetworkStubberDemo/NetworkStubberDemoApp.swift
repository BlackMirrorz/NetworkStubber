//
//  NetworkStubberDemoApp.swift
//  NetworkStubberDemo
//
//  Created by Josh Robbins on 3/20/25.
//

import NetworkStubberPackage
import SwiftUI

@main
struct NetworkStubberDemoApp: App {

  // MARK: - Body

  var body: some Scene {
    WindowGroup {
      ContentView().onAppear {
        NetworkStubLaunchArgumentProcessor.processLaunchArgumentsForStubs()
      }
    }
  }
}
