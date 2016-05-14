//
//  GameSettings.swift
//  Ski
//
//  Created by Ralf Tappmeyer on 5/7/16.
//  Copyright © 2016 Ralf Tappmeyer. All rights reserved.
//

import Foundation
import SpriteKit

enum AnimationState: String {
    case Idle = "Idle"
    case Move_Left = "Left"
    case Move_Right = "Right"
    case Fall = "Fall"
}

enum LastDirection {
    case Left
    case Right
    case Up
    case Down
}

struct playerSettings {
    //Player
    static let movementSpeed: CGFloat = 100.0
}

enum tapAction {
    case startGame
    case steerPlayer
    case dismissPause
}

var gameDifficultyModifier = 1
var gameLoopPaused = true