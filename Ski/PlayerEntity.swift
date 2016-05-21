//
//  PlayerEntity.swift
//  Ski
//
//  Created by Ralf Tappmeyer on 5/7/16.
//  Copyright © 2016 Ralf Tappmeyer. All rights reserved.
//

import SpriteKit
import GameplayKit

class PlayerEntity: GKEntity {
    var spriteComponent: SpriteComponent!
    var moveComponent: PlayerMoveComponent!
    //var animationComponent: AnimationComponent!
    
    override init() {
        super.init()
        
        let texture = SKTexture(imageNamed: "Skiier_Idle_16x19_00.png")
        texture.filteringMode = SKTextureFilteringMode.Nearest
        
        spriteComponent = SpriteComponent(entity: self, texture: texture, size: CGSize(width: 16, height: 19))
        addComponent(spriteComponent)
        
        moveComponent = PlayerMoveComponent()
        addComponent(moveComponent)
        
        let physicsBody = SKPhysicsBody(circleOfRadius: 4)
        physicsBody.dynamic = true
        physicsBody.categoryBitMask = ColliderType.Player.rawValue
        physicsBody.collisionBitMask = ColliderType.None.rawValue
        physicsBody.contactTestBitMask = ColliderType.Gate.rawValue | ColliderType.Tree.rawValue | ColliderType.Rock.rawValue
        spriteComponent.node.physicsBody = physicsBody
    }
    
    class func getTexture(identifier: String) -> SKTexture {
        let atlas = SKTextureAtlas(named: "player")
        var texture = atlas.textureNamed("Skiier_Idle_16x19_00.png")
        if identifier == "Left" {
            texture = atlas.textureNamed("Skiier_Left_16x19_00.png")
        } else if identifier == "Right" {
            texture = atlas.textureNamed("Skiier_Right_16x19_00.png")
        }
        texture.filteringMode = SKTextureFilteringMode.Nearest
        return texture
    }
}
