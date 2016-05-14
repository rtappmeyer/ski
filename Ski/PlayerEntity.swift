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
    var animationComponent: AnimationComponent!
    
    override init() {
        super.init()
        
        let texture = SKTexture(imageNamed: "Skiier_Idle_16x19_00.png")
        texture.filteringMode = SKTextureFilteringMode.Nearest
        
        spriteComponent = SpriteComponent(entity: self, texture: texture, size: CGSize(width: 16, height: 19))
        addComponent(spriteComponent)
        
        animationComponent = AnimationComponent(node: spriteComponent.node, textureSize: CGSizeMake(16,19), animations: loadAnimations())
        addComponent(animationComponent)
        
        moveComponent = PlayerMoveComponent()
        addComponent(moveComponent)
    }
    
    func loadAnimations() -> [AnimationState: Animation] {
        let textureAtlas = SKTextureAtlas(named: "player")
        var animations = [AnimationState: Animation]()
        
        animations[.Move_Left] = AnimationComponent.animationFromAtlas(textureAtlas, withImageIdentifier: AnimationState.Move_Left.rawValue, forAnimationState: .Move_Left)
        
        animations[.Move_Right] = AnimationComponent.animationFromAtlas(textureAtlas, withImageIdentifier: AnimationState.Move_Right.rawValue, forAnimationState: .Move_Right)
        
        animations[.Idle] = AnimationComponent.animationFromAtlas(textureAtlas, withImageIdentifier: AnimationState.Idle.rawValue,forAnimationState: .Idle)
        
        return animations
    }
}