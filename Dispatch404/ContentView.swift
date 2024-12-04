//
//  ContentView.swift
//  Dispatch404
//
//  Created by Shawn Tucker on 12/4/24.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            StoresView()
                .tabItem {
                    Label("Stores", systemImage: "storefront.fill")
                }
                .tag(0)
            
            DriversView()
                .tabItem {
                    Label("Drivers", systemImage: "car.fill")
                }
                .tag(1)
            
            TerminalsView()
                .tabItem {
                    Label("Terminals", systemImage: "creditcard.fill")
                }
                .tag(2)
            
            NotesView()
                .tabItem {
                    Label("Notes", systemImage: "note.text")
                }
                .tag(3)
        }
        .tint(.blue) // Sets the accent color for selected tabs
    }
}


#Preview {
    ContentView()
}
