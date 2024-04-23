//
//  SettingsView.swift
//  BubblePop
//
//  Created by Duy Thuong on 2/4/2024.
//

import SwiftUI

struct SettingsView: View {
    @StateObject var highScoreViewModel = HighScoreViewModel()
    @State private var countdownInput = ""
    @State private var countdownValue: Double = 0
    @State private var numberOfBubbles: Double = 0
    var body: some View {
            VStack{
                Label("Settings", systemImage: "")
                    .foregroundStyle(.green)
                    .font(.title)
                    Spacer()
                Text("Enter Your Name:")
                
                TextField("Enter Name", text: $highScoreViewModel.taskDescription)
                    .padding()
                    Spacer()
                Text("Game Time")
                Slider(value: $countdownValue, in: 0...60, step: 1)
                    .padding()
                    .onChange(of: countdownValue, perform: { value in
                        countdownInput = "\(Int(value))"
                    })
                Text(" \(Int(countdownValue))")
                    .padding()

                Text("Max Number of Bubbles")
                Slider(value: $numberOfBubbles, in: 0...15, step: 1)
                    .padding()
                                
                Text("\(Int(numberOfBubbles))")
                                    .padding()
                NavigationLink(
                    destination: StartGameView(),
                    label: {
                        Text("Start Game")
                            .font(.title)
                    })
                Spacer()
                
            }
        }
}
#Preview {
    SettingsView()
}
