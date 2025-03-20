//
//  ContentView.swift
//  NetworkStubberDemo
//
//  Created by Josh Robbins on 3/20/25.
//

import SwiftUI

struct ContentView: View {
  
  var body: some View {
    ZStack {
      Color.black.ignoresSafeArea()
      VStack {
        Text("Useless Demo For Mocking UI Only").foregroundStyle(.white)
      }
    }
  }
}

// MARK: - Preview

#Preview {
  ContentView()
}
