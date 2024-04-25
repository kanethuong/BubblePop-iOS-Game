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
    @Published var gameEnded: Bool = false
    @Published var currentPlayerName: String = "" // Holds player name
    private var highScores: [HighScore] = []
    private let highScoresKey = "highScoresKey"  // Key for UserDefaults
    
    private var timer: AnyCancellable?
    private var consecutiveColor: Color? // Tracks the last color popped
    private var consecutiveCount: Int = 0 // Tracks consecutive pop count
    
    // Bubble colors and probabilities
    private let bubbleColors: [Color] = [.red, .pink, .green, .blue, .black]
    private let bubblePoints: [Int] = [1, 2, 5, 8, 10]
    private let bubbleProbabilities: [Double] = [0.40, 0.30, 0.15, 0.10, 0.05]
    
    // Define an initial speed and the rate of change with respect to the game timer
    private let initialSpeed: CGFloat = 1.0  // Starting speed
    private let speedIncreaseRate: CGFloat = 0.1  // Rate at which speed increases
    private let replacementRate: Double = 0.3  // Rate of bubble replacement
    
    init(gameTime: TimeInterval = 60, maxBubbles: Int = 15) {
        gameProperties = GameProperties(
            gameTime: gameTime,
            score: 0,
            highScores: [],
            maxBubbles: maxBubbles,
            playerName: ""
        )
        loadHighScores()
    }
    
    func startGame() {
        timer = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect().sink { _ in
            self.gameProperties.gameTime -= 1
            // Moving bubbles
//            self.updateBubblePositions()
            self.generateBubbles()
            
            if self.gameProperties.gameTime <= 0 {
                self.endGame()
            }
        }
    }
    
    // Update the speed based on the game timer
    func currentSpeed() -> CGFloat {
        return initialSpeed + (60 - CGFloat(gameProperties.gameTime)) * speedIncreaseRate
    }
    
    func updateBubblePositions() {
        let speed = currentSpeed()
        
        bubbles = bubbles.map { oldBubble in
            var newDirection = oldBubble.direction
            var newPosition = CGPoint(
                x: oldBubble.position.x + newDirection.x * speed,
                y: oldBubble.position.y + newDirection.y * speed
            )
            
            if newPosition.x < 0 {
                newPosition.x = 0
                newDirection.x *= -1
            } else if newPosition.x > UIScreen.main.bounds.width {
                newPosition.x = UIScreen.main.bounds.width
                newDirection.x *= -1
            }
            if newPosition.y < 0 {
                newPosition.y = 0
                newDirection.y *= -1
            } else if newPosition.y > UIScreen.main.bounds.height {
                newPosition.y = UIScreen.main.bounds.height
                newDirection.y *= -1
            }
            
            print("old position: \(oldBubble.position)")
            print("old direction: \(oldBubble.direction)")
            print("new position: \(newPosition)")
            print("new direction: \(newDirection)")
            
            return Bubble(
                color: oldBubble.color,
                points: oldBubble.points, 
                position: newPosition,
                direction: newDirection
            )
        }
        
        // Remove bubbles that are off-screen
        bubbles = bubbles.filter { bubble in
            bubble.position.x >= 0 &&
            bubble.position.x <= UIScreen.main.bounds.width &&
            bubble.position.y >= 0 &&
            bubble.position.y <= UIScreen.main.bounds.height
        }
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
    
    func getHighScore(for name: String) -> Int? {
        return highScores.first { $0.name == name }?.score  // Find high score by name
    }
    
    func generateBubbles() {
        let maxBubbles = gameProperties.maxBubbles
        var newBubbles: [Bubble] = []
        let bubbleRadius: CGFloat = 25  // Example radius, adjust as needed
        let numToReplace = Int(Double(bubbles.count) * replacementRate) // Calculate how many bubbles to replace
        
        // Randomly select bubbles to remove
        var remainingBubbles = bubbles
        for _ in 0..<numToReplace {
            if let randomIndex = remainingBubbles.indices.randomElement() {
                remainingBubbles.remove(at: randomIndex)  // Remove from the current set
            }
        }
        
        for _ in 0..<Int.random(in: 0..<(maxBubbles - remainingBubbles.count)) {
            var position: CGPoint
            var overlapping: Bool
            var randomDirection: CGPoint
            
            repeat {
                // Generate random x and y coordinates within safe bounds
                position = CGPoint(
                    x: CGFloat.random(in: bubbleRadius...300 - bubbleRadius),  // Adjust range to fit screen size
                    y: CGFloat.random(in: bubbleRadius...600 - bubbleRadius)  // Adjust range to fit screen size
                )
                
                // Check if the generated position is valid (non-NaN and within bounds)
                if !position.x.isFinite || !position.y.isFinite {
                    overlapping = true  // Re-generate if the position is invalid
                } else {
                    overlapping = doesBubbleOverlap(position: position, in: newBubbles, radius: bubbleRadius)  // Check for overlap
                }
                
            } while overlapping
            
            // Ensure position is within screen bounds before adding
            if position.x >= 0 && position.y >= 0 {  // Example boundary check, adjust as needed
                let colorIndex = chooseBubbleColor()
                randomDirection = CGPoint(x: CGFloat.random(in: -1...1), y: CGFloat.random(in: -1...1))
                newBubbles.append(Bubble(color: bubbleColors[colorIndex], points: bubblePoints[colorIndex], position: position, direction : randomDirection))
            }
        }
        
        // Update the bubbles array with the remaining and new bubbles
        bubbles = remainingBubbles + newBubbles
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
        for bubble in bubbles {
            let bubblePosition = bubble.position  // Get the actual position of the existing bubble
            
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
        let curHighScoreIndex = self.gameProperties.highScores.firstIndex(where: {$0.name == self.gameProperties.playerName})
        
        if curHighScoreIndex != nil{
            if gameProperties.score > gameProperties.highScores[curHighScoreIndex!].score {
                gameProperties.highScores[curHighScoreIndex!].score = gameProperties.score
                saveHighScores()
            }
        }else{
            let newHighScore=HighScore(score: gameProperties.score, name: gameProperties.playerName)
            gameProperties.highScores.append(newHighScore)
            saveHighScores()
        }
        self.gameEnded = true
        resetGame()
    }
    
    private func resetGame() {
        gameProperties.score = 0
        gameProperties.gameTime = 60
        consecutiveColor = nil
        consecutiveCount = 0
    }
    
    func loadHighScores() {
        if let data = UserDefaults.standard.data(forKey: highScoresKey) {
            let decoder = JSONDecoder()
            if let savedHighScores = try? decoder.decode([HighScore].self, from: data) {
                highScores = savedHighScores
                highScores.sort { $0.score > $1.score }
                gameProperties.highScores = highScores
            }
        }
    }
    
    func saveHighScores() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(gameProperties.highScores) {
            UserDefaults.standard.set(encoded, forKey: highScoresKey)  // Store in UserDefaults
        }
    }
    
    func addHighScore(name: String, score: Int) {
        let newHighScore = HighScore(score: score, name: name)
        gameProperties.highScores.append(newHighScore)
        gameProperties.highScores.sort { $0.score > $1.score }  // Keep sorted by score
        saveHighScores()  // Save to persistent storage
    }
    
    func resetHighScore(){
        let userDefaults = UserDefaults.standard
        let dictionary = userDefaults.dictionaryRepresentation()
        
        for key in dictionary.keys {
            userDefaults.removeObject(forKey: key)  // Remove each key
        }
        
        userDefaults.synchronize()  // Ensure changes are saved
        
        gameProperties.highScores=[]
    }
}

