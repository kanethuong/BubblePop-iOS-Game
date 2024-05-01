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
    // Published variables to trigger SwiftUI updates when they change
    @Published var bubbles: [Bubble] = [] // List of active bubbles in the game
    @Published var traps: [TrapBubbleModel] = [] // List of active trap bubbles
    @Published var gameProperties: GameProperties // Game configuration and state
    @Published var gameEnded: Bool = false // Indicates whether the game has ended
    @Published var currentPlayerName: String = "" // Holds player name
    
    // High score storage
    private var highScores: [HighScore] = [] // Stores high scores
    private let highScoresKey = "highScoresKey"  // Key for UserDefaults
    
    // Game timing and tracking
    private var timer: AnyCancellable? // Controls the game timer
    private var consecutiveColor: Color? // Tracks the color of the last bubble popped
    private var consecutiveCount: Int = 0 // Tracks consecutive bubbles of the same color
    
    // Bubble configurations
    private let bubbleColors: [Color] = [.red, .pink, .green, .blue, .black] // Bubble colors available
    private let bubblePoints: [Int] = [1, 2, 5, 8, 10] // Points for each bubble color
    private let bubbleProbabilities: [Double] = [0.40, 0.30, 0.15, 0.10, 0.05] // Probabilities for bubble colors
    
    // Countdown and game start state
    @Published var countdown: Int = 3 // Countdown before the game starts
    @Published var gameStarted: Bool = false // Indicates if the game has started
    
    // Timers for different game events
    var countDownTimer: Timer? // Controls the countdown timer
    private var trapTimer: Timer? = nil // Controls the timing for traps
    
    // Rate of bubble replacement
    private let replacementRate: Double = 0.3 // Rate at which bubbles are replaced
    
    // Game initialization with default values for game time and maximum bubbles
    init(gameTime: TimeInterval = 60, maxBubbles: Int = 15) {
        gameProperties = GameProperties(
            gameTime: gameTime,
            score: 0,
            highScores: [],
            maxBubbles: maxBubbles,
            playerName: ""
        )
        loadHighScores() // Load high scores from UserDefaults
    }
    
    /*################################
     ||                            ||
     ||        GAME SECTION        ||
     ||                            ||
     ################################*/
    
    // Starts the game timer and initializes bubbles
    func startGame() {
        timer = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect().sink { _ in
            self.gameProperties.gameTime -= 1 // Decrease game time each second
            self.generateBubbles() // Generate new bubbles
            self.updateTraps() // Update trap every second
            
            if self.gameProperties.gameTime <= 0 {
                // End the game if time runs out
                self.endGame()
            }
        }
        
        // Timer for controlling trap bubbles
        trapTimer = Timer.scheduledTimer(withTimeInterval: 1/10, repeats: true){_ in
            self.updateTraps()
        }
    }
    
    // Updates game time in the properties
    func updateGameTime(_ newTime: TimeInterval) {
        gameProperties.gameTime = newTime
    }
    
    //Set the player name
    func setPlayerName(_ name: String) {
        currentPlayerName = name
    }
    
    // End the game and perform necessary clean-up
    func endGame() {
        // Cancel the game timer
        timer?.cancel()
        
        // Check if the current player has a high score
        let curHighScoreIndex = self.gameProperties.highScores.firstIndex(where: {$0.name == self.gameProperties.playerName})
        
        if curHighScoreIndex != nil{
            // If the current player's score is higher, update the high score
            if gameProperties.score > gameProperties.highScores[curHighScoreIndex!].score {
                gameProperties.highScores[curHighScoreIndex!].score = gameProperties.score
                saveHighScores() // Save the updated high scores
            }
        }else{
            // If no high score exists for the current player, add a new one
            let newHighScore=HighScore(score: gameProperties.score, name: gameProperties.playerName)
            gameProperties.highScores.append(newHighScore)
            saveHighScores() // Save the new high score
        }
        resetGame()  // Clear game state for a new session
        // Mark the game as ended and reset game state
        self.gameEnded = true
    }
    
    // Reset game properties to default
    func resetGame() {
        gameProperties.score = 0
        gameProperties.gameTime = 60
        consecutiveColor = nil
        consecutiveCount = 0
        bubbles.removeAll()
        traps.removeAll()
        //        self.gameStarted = false
        //        self.gameEnded = false
    }
    
    // Start the countdown before the game begins
    func startCountdown() {
        self.countdown = 3 // Reset countdown
        self.gameStarted = false
        
        // Create a timer that fires every second
        countDownTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            if self.countdown > 1 {
                self.countdown -= 1 // Decrease countdown
            } else {
                timer.invalidate() // Stop the timer when countdown is done
                self.gameStarted = true // Indicate game start
            }
        }
    }
    
    /*################################
     ||                            ||
     ||       BUBBLE SECTION       ||
     ||                            ||
     ################################*/
    
    // Updates maximum number of bubbles in the properties
    func updateMaxBubbles(_ newMax: Int) {
        gameProperties.maxBubbles = newMax
    }
    
    // Generates new bubbles based on the current settings
    func generateBubbles() {
        let maxBubbles = gameProperties.maxBubbles
        var newBubbles: [Bubble] = [] // Temporary list for new bubbles
        let bubbleRadius: CGFloat = 25  // Example radius, adjust as needed
        let numToReplace = Int(Double(bubbles.count) * replacementRate) // Calculate how many bubbles to replace
        var reloadCount = 0;
        
        // Obtain window scene information
        guard let windowScene = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
              let _ = windowScene.windows.first else {
            return
        }
        let offSetX = windowScene.interfaceOrientation.isPortrait ? 0:100
        let offSetY = windowScene.interfaceOrientation.isPortrait ? 100:100
        
        
        // Randomly select bubbles to remove
        var remainingBubbles = bubbles
        for _ in 0..<numToReplace {
            if let randomIndex = remainingBubbles.indices.randomElement() {
                remainingBubbles.remove(at: randomIndex)  // Remove from the current set
            }
        }
        
        // Generate new bubbles until the maximum limit is reached
        for _ in 0..<(maxBubbles - remainingBubbles.count) {
            var position: CGPoint
            var overlapping: Bool
            repeat {
                // Generate random x and y coordinates within safe bounds
                position = CGPoint(
                    // Adjust range to fit screen size
                    x: CGFloat.random(in: bubbleRadius...(UIScreen.main.bounds.width - bubbleRadius - CGFloat(offSetX))),
                    y: CGFloat.random(in: bubbleRadius...(UIScreen.main.bounds.height - bubbleRadius - CGFloat(offSetY)))
                )
                
                // Check if the generated position is valid (non-NaN and within bounds)
                if !position.x.isFinite || !position.y.isFinite {
                    overlapping = true  // Re-generate if the position is invalid
                } else {
                    overlapping = doesBubbleOverlap(position: position, in: newBubbles, radius: bubbleRadius) ||  doesBubbleOverlap(position: position, in: remainingBubbles, radius: bubbleRadius)// Check for overlap
                }
                reloadCount += 1
            } while overlapping && reloadCount < 50
            
            // Ensure position is within screen bounds before adding
            if position.x >= 0 && position.y >= 0 {  // Example boundary check, adjust as needed
                let colorIndex = chooseBubbleColor()
                newBubbles.append(Bubble(color: bubbleColors[colorIndex], points: bubblePoints[colorIndex], position: position))
            }
        }
        
        // Update the bubbles array with the remaining and new bubbles
        bubbles = remainingBubbles + newBubbles
    }
    
    // Chooses a bubble color based on predefined probabilities
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
    
    // Check if a bubble at a given position overlaps with other bubbles
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
    
    // Handles popping of a bubble and updates the score
    func popBubble(bubble: Bubble) {
        var points = bubble.points
        if consecutiveColor == bubble.color {
            // If it's the same color as the last popped bubble, apply a multiplier
            points = Int(Double(points) * 1.5)
            consecutiveCount += 1
        } else {
            // Otherwise, reset the consecutive counter
            consecutiveColor = bubble.color
            consecutiveCount = 1
        }
        // Update the score in game properties
        gameProperties.score += points
        
        // Remove the popped bubble from the list
        bubbles.removeAll { $0.id == bubble.id }
    }
    
    /*################################
     ||                            ||
     ||       TRAPS SECTION        ||
     ||                            ||
     ################################*/
    // Handles popping of a trap and ends the game
    func popTrap(_ trap: TrapBubbleModel) {
        endGame()
        traps.removeAll { $0.id == trap.id } // Remove the bomb
    }
    
    // Updates the position and state of trap bubbles
    func updateTraps() {
        // Move all existing trap bubbles
        for index in traps.indices {
            traps[index].move()
        }
        
        // Keep only those traps that remain within screen boundaries
        traps = traps.filter { trap in
            trap.position.x >= 0 && trap.position.x <= UIScreen.main.bounds.width &&
            trap.position.y >= 0 && trap.position.y <= UIScreen.main.bounds.height
        }
        
        // Add new trap bubbles with a small chance each tick
        if Double.random(in: 0...1) <= 0.2 {
            let randomX = CGFloat.random(in: 0...UIScreen.main.bounds.width)
            let randomY = CGFloat.random(in: 0...UIScreen.main.bounds.height)
            traps.append(TrapBubbleModel(position: CGPoint(x: randomX, y: randomY)))
        }
    }
    
    /*################################
     ||                            ||
     ||    HIGH SCORES SECTION     ||
     ||                            ||
     ################################*/
    // Retrieves the high score for a specific player
    func getHighScore(for name: String) -> Int? {
        return highScores.first { $0.name == name }?.score  // Find high score by name
    }
    
    // Loads high scores from persistent storage
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
    
    // Saves high scores to persistent storage
    func saveHighScores() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(gameProperties.highScores) {
            UserDefaults.standard.set(encoded, forKey: highScoresKey)  // Store in UserDefaults
        }
    }
    
    // Adds a new high score and updates the list
    func addHighScore(name: String, score: Int) {
        let newHighScore = HighScore(score: score, name: name)
        gameProperties.highScores.append(newHighScore)
        gameProperties.highScores.sort { $0.score > $1.score }  // Keep sorted by score
        saveHighScores()  // Save to persistent storage
    }
    
    // Resets all high scores and clears UserDefaults
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

// Extension for UIDevice to check if it has a dynamic island feature
extension UIDevice{
    // Get this value after sceneDidBecomeActive
    var hasDynamicIsland: Bool {
        // 1. dynamicIsland only support iPhone
        guard userInterfaceIdiom == .phone else {
            return false
        }
        
        // 2. Get key window, working after sceneDidBecomeActive
        guard let window = (UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.flatMap { $0.windows }.first { $0.isKeyWindow}) else {
            print("Do not found key window")
            return false
        }
        
        // 3.It works properly when the device orientation is portrait
        return window.safeAreaInsets.top >= 51
    }
}
