//
//  GameSettings.swift
//  Ski
//
//  Created by Ralf Tappmeyer on 5/7/16.
//  Copyright © 2016 Ralf Tappmeyer. All rights reserved.
//

import Foundation
import SpriteKit

struct playerSettings {
    static let movementSpeed: CGFloat = 60.0 // 100
    static let downhillSpeedMin: CGFloat = 40.0
    static let downhillSpeedMax: CGFloat = 160.0 // 100
    
    static let downhillScore = 10
    
    static let crashSlideDistance: CGFloat = 48
    static let crashSlideDuration: TimeInterval = 1.0
    
    static let appearDuration: TimeInterval = 3.0
    static let crashStateDuration: TimeInterval = 4.0
    static let reachedFinishLineStateDuration: TimeInterval = 4.0 // 0.7
    
    static let cameraOffset: CGPoint = CGPoint(x: 0, y: -40) // -60
}

struct sceneSettings {
    static let timeLimit: TimeInterval = 60.0 // 1:00
    static let timeBonusScore = 1000
    
    static let initialDuration: TimeInterval = 3.0
    static let beforeBonusDuration: TimeInterval = 3.0
}

struct controllerSettings {
    static let microControllerDeadZone: Float = 0.3 // 0 = no deadzone
    static let microControllerNumbingRatio: Float = 0.7 // 1.0 = not numb, 0 = entirely numb
    static let onScreenButtonsY = -160 // -160 is fairly close to the bottom
    static let onScreenButtonLeftX = -350
    static let onScreenButtonRightX = -180
    static let onScreenButtonFastX = 350
}

struct gateSettings {
    static let minScoringMultiplier = 4
    static let maxScoringMultiplier = 8
    static let score = 100
}

enum ColliderType: UInt32 {
    case none       = 0
    case obstacle   = 0b1
    case post       = 0b10
    case finish     = 0b100
    case gate       = 0b1000
    case player     = 0b10000
    case missed     = 0b100000
}

enum PostType {
    case left
    case right
}

enum ButtonType: String {
    case left = "left_button.png"
    case right = "right_button.png"
    case fast = "fast_button.png"
}
