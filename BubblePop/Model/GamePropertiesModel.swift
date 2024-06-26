//
//  GamePropertiesModel.swift
//  BubblePop
//
//  Created by Duy Thuong on 23/4/2024.
//

import Foundation

struct GameProperties {
    var gameTime: TimeInterval
    var score: Int
    var highScores: [HighScore]
    var maxBubbles: Int
    var playerName: String
}
