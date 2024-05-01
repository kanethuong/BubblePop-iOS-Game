//
//  StartGameView.swift
//  BubblePop
//
//  Created by Duy Thuong on 24/4/2024.
//

import SwiftUI

// View for starting a new game and entering player name
struct StartGameView: View {
    @ObservedObject var gameController: GameController
    
    var body: some View {
        VStack {
            HStack{
                Text("Score: \(gameController.gameProperties.score)")
                Text("High Score: \(String(describing: gameController.getHighScore(for: $gameController.gameProperties.playerName.wrappedValue) ?? 0))")
                Text("Time Left: \(Int(gameController.gameProperties.gameTime))s")
            }
            .padding()
            
            
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
                
                ForEach(gameController.traps) { trap in
                    Circle()
                        .frame(width: trap.size, height: trap.size)
                        .position(x: trap.position.x, y: trap.position.y)
                        .foregroundColor(.indigo)
                        .onTapGesture {
                            gameController.popTrap(trap)
                        }
                }
            }
            Spacer()
            
            NavigationLink(value: gameController.gameEnded) {  // Link to high score view
                EmptyView()  // Invisible link to trigger navigation
            }
        }
        .onAppear {
            gameController.startGame() // Start the game on view appearance
        }
        .navigationDestination(isPresented: $gameController.gameEnded) {  // Define the destination when navigation is triggered
            HighScoreView(gameController: self.gameController)  // The high score view
        }
        .navigationBarBackButtonHidden(true)
    }
}

struct StartGameView_Previews: PreviewProvider {
    static var previews: some View {
        StartGameView(gameController: GameController())
    }
}
