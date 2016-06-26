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
    // MARK: Properties
    
    var elapsedTime: NSTimeInterval
    var score: Int
    var gateScoringMultiplier: Int
    
    var isCrashed: Bool
    var reachedFinishLine: Bool
    
    var renderComponent: RenderComponent {
        guard let renderComponent = componentForClass(RenderComponent.self) else { fatalError("A PlayerEntity must have a RenderComponent.") }
        return renderComponent
    }
    
    var animationComponent: AnimationComponent!
    
    override init() {
        elapsedTime = 0
        score = 0
        gateScoringMultiplier = gateSettings.minScoringMultiplier
        
        isCrashed = false
        reachedFinishLine = false
        
        super.init()
        
        // Configure Components for this Entity
        
        let renderComponent = RenderComponent(entity: self)
        addComponent(renderComponent)
        
        let atlas = SKTextureAtlas(named: "player")
        let defaultTexture = atlas.textureNamed("idle__00.png")
        defaultTexture.filteringMode = SKTextureFilteringMode.Nearest
        let size = CGSizeMake(16, 19)
        
        let spriteComponent = SpriteComponent(texture: defaultTexture, size: size)
        addComponent(spriteComponent)
        spriteComponent.node.anchorPoint = CGPointMake(0.5, 0.2)
        
        let animationComponent = AnimationComponent(node: spriteComponent.node, textureSize: size, animations: loadAnimations())
        addComponent(animationComponent)
        
        let moveComponent = MoveComponent()
        addComponent(moveComponent)
        
        let physicsBody = SKPhysicsBody(circleOfRadius: 4)
        physicsBody.categoryBitMask = ColliderType.Player.rawValue
        physicsBody.contactTestBitMask = ColliderType.Gate.rawValue | ColliderType.Obstacle.rawValue | ColliderType.Finish.rawValue
            
        let physicsComponent = PhysicsComponent(physicsBody: physicsBody)
        addComponent(physicsComponent)
        
        let stateComponent = StateComponent(states: [
            PlayerAppearState(entity: self),
            PlayerInputControlledState(entity: self),
            PlayerCrashState(entity: self),
            PlayerReachedFinishLineState(entity: self)]
        )
        addComponent(stateComponent)
        
        // Connect the PhysicsComponent with the RenderComponent.
        renderComponent.node.physicsBody = physicsComponent.physicsBody
        
        // Connect the SpriteComponent with the RenderComponent
        renderComponent.node.addChild(spriteComponent.node)
    }
    
    func loadAnimations() -> [AnimationState: Animation] {
        let textureAtlas = SKTextureAtlas(named: "player")
        var animations = [AnimationState: Animation]()
        animations[.Idle] = AnimationComponent.animationFromAtlas(textureAtlas, withImageIdentifier: "idle", forAnimationState: .Idle)
        animations[.Left] = AnimationComponent.animationFromAtlas(textureAtlas, withImageIdentifier: "left", forAnimationState: .Left)
        animations[.Right] = AnimationComponent.animationFromAtlas(textureAtlas, withImageIdentifier: "right", forAnimationState: .Right)
        animations[.Crash] = AnimationComponent.animationFromAtlas(textureAtlas, withImageIdentifier: "crash", forAnimationState: .Crash, repeatTexturesForever: false)
        return animations
    }

}
