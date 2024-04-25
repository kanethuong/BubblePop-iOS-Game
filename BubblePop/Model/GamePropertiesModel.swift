//
//  GamePropertiesModel.swift
//  BubblePop
//
//  Created by Duy Thuong on 23/4/2024.
//

import Foundation
import SwiftUI
import Combine

class GameProperties: ObservableObject{
//    @Published var gameTime: TimeInterval
//    @Published var score: Int
//    var highScores: [HighScore]
//    var maxBubbles: Int
//    @Published var playerName: String
    
    @Published var gameTime = TimeInterval(60)
    @Published var score = Int(15)
    var highScores: [HighScore] = []
    var maxBubbles = 0
    @Published var playerName = ""
    
    static let shared: GameProperties = GameProperties()
    
//    init(gameTime: TimeInterval = 60, highScores: [HighScore] = [], maxBubbles: Int = 15) {
//        self.gameTime = gameTime
//        self.score = 0
//        self.highScores = highScores
//        self.maxBubbles = maxBubbles
//        self.playerName = ""
//    }
}
