//
//  GameController.swift
//  BubblePop
//
//  Created by Duy Thuong on 24/4/2024.
//

import SwiftUI
import Combine

// Controller handling game logic and updates
class GameController: ObservableObject {
    @Published var bubbles: [Bubble] = []
    @Published var gameProperties: GameProperties
    @Published var currentPlayerName: String = "" // Holds player name
    private var timer: AnyCancellable?
    private var consecutiveColor: Color? // Tracks the last color popped
    private var consecutiveCount: Int = 0 // Tracks consecutive pop count

    // Bubble colors and probabilities
    private let bubbleColors: [Color] = [.red, .pink, .green, .blue, .black]
    private let bubblePoints: [Int] = [1, 2, 5, 8, 10]
    private let bubbleProbabilities: [Double] = [0.40, 0.30, 0.15, 0.10, 0.05]

    init(gameTime: TimeInterval = 60, maxBubbles: Int = 15) {
            gameProperties = GameProperties(
                gameTime: gameTime,
                score: 0,
                highScore: HighScore(value: 0),
                maxBubbles: maxBubbles
            )
    }
    
    // Updates game time in the properties
    func updateGameTime(_ newTime: TimeInterval) {
        gameProperties.gameTime = newTime
    }

    // Updates maximum number of bubbles in the properties
    func updateMaxBubbles(_ newMax: Int) {
        gameProperties.maxBubbles = newMax
    }

    func setPlayerName(_ name: String) {
        currentPlayerName = name
    }

    func startGame() {
        resetGame()
        timer = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect().sink { _ in
            self.gameProperties.gameTime -= 1
            self.generateBubbles()
            
            if self.gameProperties.gameTime <= 0 {
                self.endGame()
            }
        }
    }

    func generateBubbles() {
        let maxBubbles = gameProperties.maxBubbles
        var newBubbles: [Bubble] = []
        
        for _ in 0..<Int.random(in: 0...maxBubbles) {
            let colorIndex = chooseBubbleColor()

            var position: CGPoint
            var overlapping: Bool
            
            repeat {
                // Generate a random position for the new bubble
                position = CGPoint(
                    x: CGFloat.random(in: 50...300),
                    y: CGFloat.random(in: 50...600)
                )
                
                // Check if this position overlaps with existing bubbles
                overlapping = doesBubbleOverlap(position: position, in: newBubbles)
            } while overlapping // If overlapping, generate a new position
            
            // Add the new bubble with the non-overlapping position
            newBubbles.append(Bubble(color: bubbleColors[colorIndex], points: bubblePoints[colorIndex]))
        }
                
        bubbles = newBubbles
    }

    private func chooseBubbleColor() -> Int {
        let randomValue = Double.random(in: 0...1)
        var cumulativeProbability: Double = 0
        
        for (index, probability) in bubbleProbabilities.enumerated() {
            cumulativeProbability += probability
            if randomValue <= cumulativeProbability {
                return index
            }
        }
        return 0
    }
    
    private func doesBubbleOverlap(position: CGPoint, in bubbles: [Bubble], radius: CGFloat = 25) -> Bool {
        for _ in bubbles {
            let bubblePosition = CGPoint(
                x: CGFloat.random(in: 50...300),
                y: CGFloat.random(in: 50...600)
            )
            
            // Calculate the distance between bubbles
            let distance = hypot(
                position.x - bubblePosition.x,
                position.y - bubblePosition.y
            )
            
            // If distance is less than twice the radius, they overlap
            if distance < 2 * radius {
                return true
            }
        }
        
        return false
    }

    func popBubble(bubble: Bubble) {
        var points = bubble.points
        if consecutiveColor == bubble.color {
            points = Int(Double(points) * 1.5)
            consecutiveCount += 1
        } else {
            consecutiveColor = bubble.color
            consecutiveCount = 1
        }
        
        gameProperties.score += points
        bubbles.removeAll { $0.id == bubble.id }
    }

    func endGame() {
        timer?.cancel()
        if gameProperties.score > gameProperties.highScore.value {
            gameProperties.highScore.value = gameProperties.score
            saveHighScore()
        }
    }

    private func resetGame() {
        gameProperties.score = 0
        gameProperties.gameTime = 60
        consecutiveColor = nil
        consecutiveCount = 0
    }

    private func saveHighScore() {
        // Save high score to a persistent file or database
        // This is a placeholder for the save logic
    }
}

