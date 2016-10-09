//
//  MissedNode.swift
//  Ski
//
//  Created by Ralf Tappmeyer on 6/6/16.
//  Copyright © 2016 Ralf Tappmeyer. All rights reserved.
//
//  Abstract: The MissedNode provides a shape/physicsBody to detect whether the player has missed a gate.

import SpriteKit

class MissedNode: SKShapeNode {
    // MARK: Initialization
    
    init(offset: CGPoint) {
        super.init()

        name = "missedNode"
        position = CGPoint.zero
        
        let missedPhysicsBody = SKPhysicsBody(edgeFrom: offset, to: CGPoint(x: (offset.x + 256), y: offset.y))
        missedPhysicsBody.categoryBitMask = ColliderType.missed.rawValue
        missedPhysicsBody.contactTestBitMask = ColliderType.player.rawValue
        missedPhysicsBody.collisionBitMask = ColliderType.none.rawValue
        missedPhysicsBody.isDynamic = true

        physicsBody = missedPhysicsBody
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
