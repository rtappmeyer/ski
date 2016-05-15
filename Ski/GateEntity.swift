//
//  GateEntity.swift
//  Ski
//
//  Created by Ralf Tappmeyer on 5/14/16.
//  Copyright © 2016 Ralf Tappmeyer. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit
import GameplayKit

class GateEntity: GKEntity {
    
    var spriteComponent: SpriteComponent {
        guard let spriteComponent = componentForClass(SpriteComponent.self)
            else { fatalError("GateEntity must have a SpriteComponent") }
        return spriteComponent
    }
    
    override init() {
        super.init()
        let texture = SKTexture(imageNamed: "snow_16x32_00")
        
        let spriteComponent = SpriteComponent(entity: self, texture: texture, size: CGSize(width: 16, height: 2))
        addComponent(spriteComponent)
        
        let physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: 16, height: 2))
        physicsBody.categoryBitMask = ColliderType.Gate.rawValue
        physicsBody.contactTestBitMask = ColliderType.Player.rawValue
        physicsBody.collisionBitMask = 0
        physicsBody.allowsRotation = false
        physicsBody.dynamic = false
        spriteComponent.node.physicsBody = physicsBody
    }
}