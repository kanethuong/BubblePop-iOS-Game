//
//  SettingsView.swift
//  BubblePop
//
//  Created by Duy Thuong on 2/4/2024.
//

import SwiftUI

// View for game settings
struct SettingsView: View {
    @State private var orientation = UIDeviceOrientation.unknown // Tracks device orientation
    @ObservedObject var gameController: GameController
    
    var body: some View {
        VStack {
            // If the device is in portrait orientation
            if orientation.isPortrait{
                Text("Enter Your Name:")
                TextField("Name", text: $gameController.gameProperties.playerName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                Text("Game Time (seconds)")
                Slider(
                    value: $gameController.gameProperties.gameTime,
                    in: 10...60, step: 10) // Adjustable game time
                .padding()
                Text("\(Int(gameController.gameProperties.gameTime))")
                
                Text("Max Bubbles").padding()
                Slider(
                    value: Binding(
                        get: { Double(gameController.gameProperties.maxBubbles) }, // Convert to Double
                        set: { gameController.updateMaxBubbles(Int($0)) } // Convert back to Int
                    ),
                    in: 1...15, // Range for max bubbles
                    step: 1 // Step for the slider
                ) // Adjustable max bubbles
                .padding()
                Text("\(Int(gameController.gameProperties.maxBubbles))")
                
                NavigationLink(destination: CountdownView(gameController: self.gameController)) {
                    Text("Start Game")
                        .font(.title2)
                }
                .padding()
                
                NavigationLink(destination: ContentView()) {
                    Text("Back to menu")
                        .font(.title2)
                }
                .padding()
            }else{
                // If the device is in landscape orientation
                Spacer()
                Text("Enter Your Name:")
                TextField("Name", text: $gameController.gameProperties.playerName).padding(.horizontal)
                Text("Game Time (seconds)")
                Slider(
                    value: $gameController.gameProperties.gameTime,
                    in: 10...60, step: 10).padding(.horizontal)
                Text("\(Int(gameController.gameProperties.gameTime))")
                
                Text("Max Bubbles")
                Slider(
                    value: Binding(
                        get: { Double(gameController.gameProperties.maxBubbles) }, // Convert to Double
                        set: { gameController.updateMaxBubbles(Int($0)) } // Convert back to Int
                    ),
                    in: 1...15, // Range for max bubbles
                    step: 1 // Step for the slider
                ).padding(.horizontal)
                Text("\(Int(gameController.gameProperties.maxBubbles))")
                
                Spacer()
                NavigationLink(destination: CountdownView(gameController: self.gameController)) {
                    Text("Start Game")
                        .font(.title)
                }
                NavigationLink(destination: ContentView()) {
                    Text("Back to menu")
                        .font(.title)
                }
            }
        }
        .navigationBarBackButtonHidden(true) // Hide the back button in the navigation bar
        .onRotate { newOrientation in
            orientation = newOrientation // Update orientation state when device rotates
        }
    }
}

// A view modifier to detect device rotation and trigger an action
struct DeviceRotationViewModifier: ViewModifier {
    let action: (UIDeviceOrientation) -> Void
    
    func body(content: Content) -> some View {
        content
            .onAppear()
            .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
                action(UIDevice.current.orientation)
            }
    }
}

// A View wrapper to make the modifier easier to use
extension View {
    func onRotate(perform action: @escaping (UIDeviceOrientation) -> Void) -> some View {
        self.modifier(DeviceRotationViewModifier(action: action))
    }
}

