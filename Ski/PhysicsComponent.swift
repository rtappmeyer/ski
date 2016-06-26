//
//  PhysicsComponent.swift
//  Ski
//
//  Created by Ralf Tappmeyer on 5/24/16.
//  Copyright © 2016 Ralf Tappmeyer. All rights reserved.
//

import SpriteKit
import GameplayKit

class PhysicsComponent: GKComponent {
    var physicsBody: SKPhysicsBody
    
    init(physicsBody: SKPhysicsBody) {
        self.physicsBody = physicsBody
        super.init()
        
        self.physicsBody.dynamic = true
        self.physicsBody.collisionBitMask = ColliderType.None.rawValue

    }
}
