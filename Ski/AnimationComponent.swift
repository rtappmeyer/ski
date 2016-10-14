//
//  AnimationComponent.swift
//  Ski
//
//  Created by Ralf Tappmeyer on 6/6/16.
//  Copyright © 2016 Ralf Tappmeyer. All rights reserved.
//

import SpriteKit
import GameplayKit

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

class AnimationComponent: GKComponent {
    let node: SKSpriteNode
    var animations: [AnimationState: Animation]
    fileprivate(set) var currentAnimation: Animation?
    var requestedAnimationState: AnimationState?
    
    init(node: SKSpriteNode, textureSize: CGSize, animations: [AnimationState: Animation]) {
        self.node = node
        self.animations = animations
        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: Animation

    fileprivate func runAnimationForAnimationState(animationState: AnimationState) {
        let actionKey = "Animation"
        let timePerFrame = TimeInterval(1.0 / 4.0) // 0.25ms
        
        if currentAnimation != nil && currentAnimation!.animationState == animationState { return }
        
        guard let animation = animations[animationState] else {
            print("Unknown animation for state \(animationState.rawValue)")
            return
        }
        
        node.removeAction(forKey: actionKey)
        
        let texturesAction: SKAction
        
        if animation.repeatTexturesForever {
            texturesAction = SKAction.repeatForever(SKAction.animate(with: animation.textures, timePerFrame: timePerFrame, resize: true, restore: true))
        } else {
            texturesAction = SKAction.animate(with: animation.textures, timePerFrame: timePerFrame, resize: true, restore: false)
        }
        
        node.run(texturesAction, withKey: actionKey)
        
        currentAnimation = animation
    }
    
    
    // MARK: GKComponent Life Cycle
    
    override func update(deltaTime: TimeInterval) {
        super.update(deltaTime: deltaTime)
        if let animationState = requestedAnimationState {
            runAnimationForAnimationState(animationState: animationState)
            requestedAnimationState = nil
        }
    }

    
    // MARK: Convenience
    
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
