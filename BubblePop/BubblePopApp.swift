//
//  BubblePopApp.swift
//  BubblePop
//
//  Created by Duy Thuong on 2/4/2024.
//

import SwiftUI

@main
struct BubblePopApp: App {
    // Create a single instance of GameController to share across views
    @StateObject private var gameController = GameController()
    
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(gameController) // Inject the shared GameController instance
        }
    }
}
