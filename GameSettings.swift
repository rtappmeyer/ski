//
//  GameSettings.swift
//  Ski
//
//  Created by Ralf Tappmeyer on 5/7/16.
//  Copyright © 2016 Ralf Tappmeyer. All rights reserved.
//

import Foundation
import SpriteKit

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

enum ColliderType: UInt32 {
    case None = 0
    case Tree   = 0b1
    case Rock   = 0b10
    case Post   = 0b100
    case Finish = 0b1000
    case Gate   = 0b10000
    case Player = 0b100000
}

var gameDifficultyModifier = 1
var gameLoopPaused = true