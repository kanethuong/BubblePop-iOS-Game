//
//  SettingsView.swift
//  BubblePop
//
//  Created by Duy Thuong on 2/4/2024.
//

import SwiftUI

// View for game settings
struct SettingsView: View {
    @EnvironmentObject var gameController: GameController // Use the shared instance
    
    var body: some View {
        VStack {
            
            Text("Enter Your Name:")
                .font(.title)
            
            TextField("Name", text: $gameController.gameProperties.playerName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Text("Game Time (seconds)")
            Slider(
                value: $gameController.gameProperties.gameTime,
                   in: 10...60, step: 10) // Adjustable game time
                .padding()
            Text("\(Int(gameController.gameProperties.gameTime))")
            
            Text("Max Bubbles").padding()
            Slider(
                value: Binding(
                    get: { Double(gameController.gameProperties.maxBubbles) }, // Convert to Double
                    set: { gameController.updateMaxBubbles(Int($0)) } // Convert back to Int
                ),
                in: 1...15, // Range for max bubbles
                step: 1 // Step for the slider
            ) // Adjustable max bubbles
                .padding()
            Text("\(Int(gameController.gameProperties.maxBubbles))")
            
            NavigationLink(destination: StartGameView()) {
                Text("Start Game")
                    .font(.title)
            }
            .padding()
            
            NavigationLink(destination: ContentView()) {
                Text("Back to menu")
                    .font(.title)
            }
            .padding()
        }
        .onAppear {
            // Default settings, could also read from a persistent source
        }
        .navigationBarBackButtonHidden(true)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        let gameController = GameController()  // Create the required environment object
        
        SettingsView()
            .environmentObject(gameController)  // Provide the environment object to the preview
    }
}
