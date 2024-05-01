//
//  ContentView.swift
//  BubblePop
//
//  Created by Duy Thuong on 2/4/2024.
//

import SwiftUI

// Main content view for the BubblePop game application
struct ContentView: View {
    @State private var gameController = GameController()
    
    var body: some View {
        // A navigation stack to handle transitions between views
        NavigationStack {
            VStack { // Vertical stack layout for the content
                Text("Bubble Pop")
                    .foregroundStyle(.mint)
                    .font(.largeTitle)
                
                Spacer()
                
                NavigationLink(destination: SettingsView(gameController: self.gameController)) {
                    Text("New Game")
                        .font(.title)
                }
                .padding()
                
                NavigationLink(destination: HighScoreView(gameController: self.gameController)) {
                    Text("High Score")
                        .font(.title)
                }
                .padding()
                
                Spacer()
            }
            // Hide the back button in the navigation bar
            .navigationBarBackButtonHidden(true)
        }
    }
}

#Preview {
    ContentView()
}

