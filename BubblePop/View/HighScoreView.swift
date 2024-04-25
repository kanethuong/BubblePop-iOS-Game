//
//  HighScoreView.swift
//  BubblePop
//
//  Created by Duy Thuong on 2/4/2024.
//

import SwiftUI

// View for displaying high scores
struct HighScoreView: View {
    // Placeholder data for high scores, would typically come from a database or persistent storage
    @EnvironmentObject var gameController: GameController
    
    var body: some View {
        VStack {
            Text("High Scores")
                .font(.title)
            
//            let _=print($gameController.gameProperties.highScores)
            List($gameController.gameProperties.highScores, id: \.name) { highScore in
                HStack {
                    Text(highScore.name.wrappedValue)
                    Spacer()
                    Text("\(highScore.score.wrappedValue)")
                }
            }
            
            Spacer()
            
            NavigationLink(destination: ContentView()) {
                Text("Back to menu")
                    .font(.title)
            }
            .padding()
            
            Button("Reset High Score"){gameController.resetHighScore()}
            
            Spacer()
        }
        .onAppear{
            gameController.loadHighScores()
        }
        .navigationBarBackButtonHidden(true)
    }
}


struct HighScoreView_Previews: PreviewProvider {
    static var previews: some View {
        let gameController = GameController()  // Create the required environment object
        
        HighScoreView()
            .environmentObject(gameController)  // Provide the environment object to the preview
    }
}

