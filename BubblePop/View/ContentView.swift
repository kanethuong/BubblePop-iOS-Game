//
//  ContentView.swift
//  BubblePop
//
//  Created by Duy Thuong on 2/4/2024.
//

import SwiftUI

// Main navigation view
struct ContentView: View {
//    @StateObject var gameController = GameController()
    @EnvironmentObject var gameController: GameController
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Bubble Pop")
                    .foregroundStyle(.mint)
                    .font(.largeTitle)
                
                Spacer()
                
                NavigationLink(destination: SettingsView()) {
                    Text("New Game")
                        .font(.title)
                }
                .padding()
                
                NavigationLink(destination: HighScoreView()) {
                    Text("High Score")
                        .font(.title)
                }
                .padding()
                
                Spacer()
            }
            .navigationBarBackButtonHidden(true)
        }
    }
}

#Preview {
    ContentView()
}

