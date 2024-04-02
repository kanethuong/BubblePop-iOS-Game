//
//  SettingsView.swift
//  BubblePop
//
//  Created by Duy Thuong on 2/4/2024.
//

import SwiftUI

struct SettingsView: View {
    @StateObject var highScoreViewModel=HighScoreViewModel()
    @State private var countdownInput=""
    @State private var countdownValue: Double=0
    
    
    var body: some View {
        Label("Settings", systemImage: "")
            .foregroundColor(.blue)
            .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
        Spacer()
        Text("Enter Name")
        TextField("Enter Name", text: <#T##Binding<String>#>)
    }
}

#Preview {
    SettingsView()
}
