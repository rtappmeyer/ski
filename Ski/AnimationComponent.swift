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
    case Idle = "idle"
    case Left = "left"
    case Right = "right"
    case Crash = "crash"
}

struct Animation {
    let animationState: AnimationState
    let textures: [SKTexture]
    let repeatTexturesForever: Bool
}

class AnimationComponent: GKComponent {
    let node: SKSpriteNode
    var animations: [AnimationState: Animation]
    private(set) var currentAnimation: Animation?
    var requestedAnimationState: AnimationState?
    
    init(node: SKSpriteNode, textureSize: CGSize, animations: [AnimationState: Animation]) {
        self.node = node
        self.animations = animations
    }
    
    
    // MARK: Animation

    private func runAnimationForAnimationState(animationState: AnimationState) {
        let actionKey = "Animation"
        let timePerFrame = NSTimeInterval(1.0 / 4.0) // 0.25ms
        
        if currentAnimation != nil && currentAnimation!.animationState == animationState { return }
        
        guard let animation = animations[animationState] else {
            print("Unknown animation for state \(animationState.rawValue)")
            return
        }
        
        node.removeActionForKey(actionKey)
        
        let texturesAction: SKAction
        
        if animation.repeatTexturesForever {
            texturesAction = SKAction.repeatActionForever(SKAction.animateWithTextures(animation.textures, timePerFrame: timePerFrame, resize: true, restore: true))
        } else {
            texturesAction = SKAction.animateWithTextures(animation.textures, timePerFrame: timePerFrame, resize: true, restore: false)
        }
        
        node.runAction(texturesAction, withKey: actionKey)
        
        currentAnimation = animation
    }
    
    
    // MARK: GKComponent Life Cycle
    
    override func updateWithDeltaTime(deltaTime: NSTimeInterval) {
        super.updateWithDeltaTime(deltaTime)
        if let animationState = requestedAnimationState {
            runAnimationForAnimationState(animationState)
            requestedAnimationState = nil
        }
    }

    
    // MARK: Convenience
    
    class func animationFromAtlas(atlas: SKTextureAtlas, withImageIdentifier identifier: String, forAnimationState animationState: AnimationState,  repeatTexturesForever: Bool = true) -> Animation {
        
        // Sort by name beginning with identifier_* and then by order (_00, _01, _02, ...)
        let textures = atlas.textureNames.filter {
            $0.hasPrefix("\(identifier)_")
            }.sort { $0 < $1 }.map {
                atlas.textureNamed($0)
        }
        return Animation(animationState: animationState, textures: textures, repeatTexturesForever: repeatTexturesForever)
    }
}
