//
//  HighScoreView.swift
//  BubblePop
//
//  Created by Duy Thuong on 2/4/2024.
//

import SwiftUI

// View for displaying high scores
struct HighScoreView: View {
    @ObservedObject var gameController: GameController
    
    var body: some View {
        VStack {
            Text("Score Board")
                .font(.title)
                .padding()
            
            List($gameController.gameProperties.highScores, id: \.name) { highScore in
                HStack {
                    Text(highScore.name.wrappedValue)
                    Spacer()
                    Text("\(highScore.score.wrappedValue)")
                }
            }
            
            NavigationLink(destination: ContentView()) {
                Text("Back to menu")
                    .font(.title2)
            }
            .padding()
            
            
            Button("Reset Score Board"){gameController.resetHighScore()}.font(.title2)
            
            Spacer()
        }
        .onAppear{
            gameController.loadHighScores()
        }
        .navigationBarBackButtonHidden(true)
        
    }
}
