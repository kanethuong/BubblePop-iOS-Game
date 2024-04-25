//
//  StartGameView.swift
//  BubblePop
//
//  Created by Duy Thuong on 24/4/2024.
//

import SwiftUI

// View for starting a new game and entering player name
struct StartGameView: View {
//    @ObservedObject var gameController : GameController
    @EnvironmentObject var gameController: GameController // Use the shared instance
    
    var body: some View {
        VStack {
            HStack{
                Text("Score: \(gameController.gameProperties.score)")
                Text("High Score: \(String(describing: gameController.getHighScore(for: $gameController.gameProperties.playerName.wrappedValue) ?? 0))")
                Text("Time Left: \(Int(gameController.gameProperties.gameTime))s")
            }.padding()
            
            
            ZStack {
                ForEach(gameController.bubbles) { bubble in
                    Circle()
                        .fill(bubble.color)
                        .frame(width: 50, height: 50)
                        .position(bubble.position)
                        .onTapGesture {
                            gameController.popBubble(bubble: bubble)
                        }
                }
            }
            Spacer()
            
            NavigationLink(
                destination: HighScoreView(),  // Navigate to HighScoreView
                isActive: $gameController.gameEnded  // Trigger navigation
            ) {
                EmptyView()
            }
        }
        .onAppear {
            gameController.startGame() // Start the game on view appearance
        }
        .onDisappear(perform: {
            gameController.endGame()
        })
        .navigationBarBackButtonHidden(true)
    }
}

struct StartGameView_Previews: PreviewProvider {
    static var previews: some View {
        let gameController = GameController()  // Create the required environment object
        
        StartGameView()
            .environmentObject(gameController)  // Provide the environment object to the preview
    }
}
