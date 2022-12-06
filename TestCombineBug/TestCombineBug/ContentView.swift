//
//  ContentView.swift
//  TestCombineBug
//
//  Created by Nikola Milovanovic on 6.12.22..
//

import SwiftUI

struct ContentView: View {
    
    @StateObject private var tester = Tester()
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("Hello, world!")
        }
        .padding()
        .onAppear {
            tester.start()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
