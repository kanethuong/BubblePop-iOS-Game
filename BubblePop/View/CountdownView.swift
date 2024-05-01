//
//  CountdownView.swift
//  BubblePop
//
//  Created by Duy Thuong on 26/4/2024.
//

import SwiftUI

struct CountdownView: View {
    @ObservedObject var gameController: GameController
    @State private var navigateToGame: Bool = false
    
    var body: some View {
        VStack {
            if gameController.gameStarted == false {
                Text("Game starting in:")
                Text("\(gameController.countdown)")
                    .font(.largeTitle)
                    .bold()
                    .animation(.easeInOut) // Optional animation
            } else {
                Text("Let's go!").font(.title)
                    .onAppear {
                        // When gameStarted is true, set navigateToGame to true after a short delay
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            navigateToGame = true
                        }
                    }
            }
            
            NavigationLink(value: navigateToGame) {  // Link to high score view
                EmptyView()  // Invisible link to trigger navigation
            }
            .hidden() // Hide the NavigationLink to keep it invisible
        }
        .onAppear {
            gameController.startCountdown() // Start countdown when the view appears
        }
        .navigationDestination(isPresented: $navigateToGame) {
            StartGameView(gameController: self.gameController)
        }
        .navigationBarBackButtonHidden(true)
    }
}
