//
//  FinishEntity.swift
//  Ski
//
//  Created by Ralf Tappmeyer on 5/14/16.
//  Copyright © 2016 Ralf Tappmeyer. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit
import GameplayKit

class FinishEntity: GKEntity {
    
    var spriteComponent: SpriteComponent!
    
    override init() {
        super.init()
        
        let texture = SKTexture(imageNamed: "finish_192x64_00")
        texture.filteringMode = SKTextureFilteringMode.Nearest

        spriteComponent = SpriteComponent(entity: self, texture: texture, size: CGSize(width: 192, height: 64))
        addComponent(spriteComponent)
        
        let physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: 192, height: 144), center: CGPoint(x: 0,y: 64))
        physicsBody.categoryBitMask = ColliderType.Finish.rawValue
        physicsBody.collisionBitMask = 0
        physicsBody.contactTestBitMask = ColliderType.Player.rawValue
        physicsBody.dynamic = false
        physicsBody.allowsRotation = false
        spriteComponent.node.physicsBody = physicsBody
    }
}