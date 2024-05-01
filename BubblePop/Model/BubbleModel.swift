//
//  BubbleModel.swift
//  BubblePop
//
//  Created by Duy Thuong on 23/4/2024.
//

import Foundation
import SwiftUI

struct Bubble: Identifiable {
    let id = UUID()
    var color: Color
    var points: Int
    var position: CGPoint
}
