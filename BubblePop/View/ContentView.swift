//
//  ContentView.swift
//  BubblePop
//
//  Created by Duy Thuong on 2/4/2024.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView{
            VStack {
                Label("Bubble Pop", systemImage: "").foregroundColor(.mint).font(.largeTitle)
                Spacer()
                
                NavigationLink(destination: SettingsView(), label: {Text("New Game").font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)})
                .padding(50)
                
                NavigationLink(destination: HighScoreView(), label: {Text("High Score").font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)})
                Spacer()
            }
            .padding()
        }
    }
}

#Preview {
    ContentView()
}
