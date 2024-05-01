//
//  TrapBubbleModel.swift
//  BubblePop
//
//  Created by Duy Thuong on 26/4/2024.
//

import Foundation
import SwiftUI

struct TrapBubbleModel: Identifiable {
    let id = UUID() // Unique identifier
    var size: CGFloat = 50
    var position: CGPoint
    var movementDirection: CGFloat = CGFloat.random(in: 0...360)
    
    mutating func move() {
        let speed: CGFloat = 15
        let radians = movementDirection * (.pi / 180)
        let x = cos(radians) * speed
        let y = sin(radians) * speed
        position.x += x
        position.y += y
    }
}
