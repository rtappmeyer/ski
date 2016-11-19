//
//  PlayerNode.swift
//  Ski
//
//  Created by Ralf Tappmeyer on 10/26/16.
//  Copyright © 2016 Ralf Tappmeyer. All rights reserved.
//

import SpriteKit

enum AnimationState: String {
    case idle = "idle"
    case left = "left"
    case right = "right"
    case crash = "crash"
}

struct Animation {
    let animationState: AnimationState
    let textures: [SKTexture]
    let repeatTexturesForever: Bool
}

class PlayerNode: SKNode {
    // MARK: Properties
    
    var spriteNode: SKSpriteNode!
    var elapsedTime: TimeInterval
    var score: Int
    var gateScoringMultiplier: Int
    
    var isCrashed: Bool
    var reachedFinishLine: Bool
    
    var animations: [AnimationState: Animation]!
    var currentAnimationState: AnimationState?
    
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
        spriteNode = node
        
        self.animations = loadAnimations()
        
        let physicsBody = SKPhysicsBody(circleOfRadius: 4)
        physicsBody.categoryBitMask = ColliderType.player.rawValue
        physicsBody.contactTestBitMask = ColliderType.gate.rawValue | ColliderType.obstacle.rawValue | ColliderType.finish.rawValue
        physicsBody.collisionBitMask = ColliderType.none.rawValue
        physicsBody.isDynamic = true

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func loadAnimations() -> [AnimationState: Animation] {
        let textureAtlas = SKTextureAtlas(named: "player")
        var animations = [AnimationState: Animation]()
        animations[.idle] = PlayerNode.animationFromAtlas(atlas: textureAtlas, withImageIdentifier: "idle", forAnimationState: .idle)
        animations[.left] = PlayerNode.animationFromAtlas(atlas: textureAtlas, withImageIdentifier: "left", forAnimationState: .left)
        animations[.right] = PlayerNode.animationFromAtlas(atlas: textureAtlas, withImageIdentifier: "right", forAnimationState: .right)
        animations[.crash] = PlayerNode.animationFromAtlas(atlas: textureAtlas, withImageIdentifier: "crash", forAnimationState: .crash, repeatTexturesForever: false)
        print("Animations from loadAnimation = \(animations)")
        return animations
    }
    
    class func animationFromAtlas(atlas: SKTextureAtlas, withImageIdentifier identifier: String, forAnimationState animationState: AnimationState,  repeatTexturesForever: Bool = true) -> Animation {
        
        // Sort by name beginning with identifier_* and then by order (_00, _01, _02, ...)
        //print("textures in atlas \(atlas.textureNames)")
        let textures = atlas.textureNames.filter {
            $0.hasPrefix("\(identifier)_")
            }.sorted { $0 < $1 }.map {
                atlas.textureNamed($0)
        }
        return Animation(animationState: animationState, textures: textures, repeatTexturesForever: repeatTexturesForever)
    }

}
