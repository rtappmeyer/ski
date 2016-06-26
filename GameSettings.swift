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
    static let movementSpeed: CGFloat = 100.0
    static let downhillSpeedMin: CGFloat = 40.0
    static let downhillSpeedMax: CGFloat = 100.0
    
    static let downhillScore = 10
    
    static let crashSlideDistance: CGFloat = 48
    static let crashSlideDuration: NSTimeInterval = 1.0
    
    static let appearDuration: NSTimeInterval = 3.0
    static let crashStateDuration: NSTimeInterval = 4.0
    static let reachedFinishLineStateDuration: NSTimeInterval = 1.5
    
    static let cameraOffset: CGPoint = CGPointMake(0, -60)
}

struct sceneSettings {
    static let timeLimit: NSTimeInterval = 60.0 // 1:00
    static let timeBonusScore = 1000
    
    static let initialDuration: NSTimeInterval = 3.0
    static let beforeBonusDuration: NSTimeInterval = 3.0
}

struct gateSettings {
    static let minScoringMultiplier = 4
    static let maxScoringMultiplier = 8
    static let score = 100
}

enum ColliderType: UInt32 {
    case None       = 0
    case Obstacle   = 0b1
    case Post       = 0b10
    case Finish     = 0b100
    case Gate       = 0b1000
    case Player     = 0b10000
    case Missed     = 0b100000
}

enum PostType {
    case Left
    case Right
}