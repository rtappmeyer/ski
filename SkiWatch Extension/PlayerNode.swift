//
//  PlayerNode.swift
//  Ski
//
//  Created by Ralf Tappmeyer on 10/26/16.
//  Copyright © 2016 Ralf Tappmeyer. All rights reserved.
//

import SpriteKit

class PlayerNode: SKNode {
    // MARK: Properties
    
    var elapsedTime: TimeInterval
    var score: Int
    var gateScoringMultiplier: Int
    
    var isCrashed: Bool
    var reachedFinishLine: Bool
    
    //var animationComponent: AnimationComponent!
    
    override init() {
        elapsedTime = 0
        score = 0
        gateScoringMultiplier = gateSettings.minScoringMultiplier
        
        isCrashed = false
        reachedFinishLine = false
        
        super.init()
        
        // Configure
        
        let atlas = SKTextureAtlas(named: "player")
        let defaultTexture = atlas.textureNamed("idle__00.png")
        defaultTexture.filteringMode = SKTextureFilteringMode.nearest
        let size = CGSize(width: 16, height: 19)
        let node = SKSpriteNode(texture: defaultTexture, color: SKColor.white, size: size)
        node.anchorPoint = CGPoint(x: 0.5, y: 0.2)
        addChild(node)
        
        //let animationComponent = AnimationComponent(node: spriteComponent.node, textureSize: size, animations: loadAnimations())
        //addComponent(animationComponent)
        
        
        //let moveComponent = MoveComponent()
        //addComponent(moveComponent)
        
        let physicsBody = SKPhysicsBody(circleOfRadius: 4)
        physicsBody.categoryBitMask = ColliderType.player.rawValue
        physicsBody.contactTestBitMask = ColliderType.gate.rawValue | ColliderType.obstacle.rawValue | ColliderType.finish.rawValue
        physicsBody.collisionBitMask = ColliderType.none.rawValue
        physicsBody.isDynamic = true

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
