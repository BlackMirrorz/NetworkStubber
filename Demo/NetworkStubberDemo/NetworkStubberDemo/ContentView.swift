//
//  ContentView.swift
//  NetworkStubberDemo
//
//  Created by Josh Robbins on 3/20/25.
//

import NetworkStubberPackage
import SwiftUI

struct ContentView: View {
  @State private var urlString: String = "https://api.example.com/data"
  @State private var selectedMethod: HTTPMethod = .get // default
  @State private var stubbedResponse: String = ""

  var body: some View {
    Form {
      TextField("URL", text: $urlString)

      Picker("HTTP Method", selection: $selectedMethod) {
        ForEach(HTTPMethod.allCases, id: \.self) { method in
          Text(method.rawValue).tag(method)
        }
      }

      .pickerStyle(MenuPickerStyle())

      HStack {
        Text("Subbed Response")
        Spacer()
        TextEditor(text: $stubbedResponse)
          .frame(height: 200)
          .overlay(
            RoundedRectangle(cornerRadius: 8)
              .stroke(Color.gray.opacity(0.3), lineWidth: 1)
          )
      }

    }.padding()
  }
}
