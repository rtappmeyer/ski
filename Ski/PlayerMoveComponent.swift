//
//  PlayerMoveComponent.swift
//  Ski
//
//  Created by Ralf Tappmeyer on 5/7/16.
//  Copyright © 2016 Ralf Tappmeyer. All rights reserved.
//

import SpriteKit
import GameplayKit

class PlayerMoveComponent: GKComponent {
    
    var movement = CGPointZero
    
    var lastDirection = LastDirection.Down
    
    var spriteComponent: SpriteComponent {
        guard let spriteComponent = entity?.componentForClass(SpriteComponent.self) else {
            fatalError("A MovementComponent's entity must have a spriteComponent")
        }
        return spriteComponent
    }
    
    //var animationComponent: AnimationComponent {
    //    guard let animationComponent = entity?.componentForClass(AnimationComponent.self) else {
    //        fatalError("A MovementComponent's entity must have an animationComponent")
    //    }
    //    return animationComponent
    //}
    
    override func updateWithDeltaTime(seconds: NSTimeInterval) {
        super.updateWithDeltaTime(seconds)
        
        // Update player position
        let xMovement = ((movement.x * CGFloat(seconds)) * playerSettings.movementSpeed)
        let yMovement = ((-0.5 * CGFloat(seconds)) * playerSettings.movementSpeed)
        
        spriteComponent.node.position = CGPoint(x: spriteComponent.node.position.x + xMovement, y: spriteComponent.node.position.y + yMovement)
        
        if movement.x < -0.2 {
            spriteComponent.node.texture = PlayerEntity.getTexture("Left")
        } else if movement.x > 0.2 {
            spriteComponent.node.texture = PlayerEntity.getTexture("Right")
        } else {
            spriteComponent.node.texture = PlayerEntity.getTexture("Idle")
        }
        
        movement = CGPointZero
    }
    
}
