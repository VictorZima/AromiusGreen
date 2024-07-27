//
//  ContentView.swift
//  AromiusGreen
//
//  Created by VictorZima on 30/05/2024.
//

import SwiftUI

struct ContentView: View {
    
    var body: some View {
        TabView {
            Home()
                .tabItem {
                    VStack {
                        Image(systemName: "house")
                    }
                }
            InfoView()
                .tabItem {
                    VStack {
                        Image(systemName: "map")
                    }
                }
        }
        .tint(.darkBlueItem)
    }
}

#Preview {
    ContentView()
        .environmentObject(DataManager())
}
