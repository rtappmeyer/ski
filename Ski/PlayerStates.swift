//
//  PlayerStates.swift
//  Ski
//
//  Created by Ralf Tappmeyer on 5/23/16.
//  Copyright © 2016 Ralf Tappmeyer. All rights reserved.
//

import GameplayKit
import SpriteKit

class PlayerState: GKState {
    // MARK: Properties
    
    unowned var entity: PlayerEntity
    
    // MARK: Initializers
    
    init(entity: PlayerEntity) {
        self.entity = entity
    }
}


class PlayerAppearState: PlayerState {
    // MARK: Properties
    
    var stateElapsedTime: TimeInterval = 0.0
    
    
    // MARK: GKState Life Cycle
    
    override func didEnter(from previousState: GKState?) {
        super.didEnter(from: previousState)
        
        stateElapsedTime = 0.0
        
        // Player standing still
        if let playerMoveComponent = entity.component(ofType: MoveComponent.self) {
            playerMoveComponent.downhillMovementSpeed = 0
        }
        
        // Disable the input component while the PlayerEntity appears.
        //inputComponent.isEnabled = false
        
    }

    override func update(deltaTime seconds: TimeInterval) {
        super.update(deltaTime: seconds)

        // Update the amount of time that the PlayerEntity has been sitting.
        stateElapsedTime += seconds
        
        // Check if we have spent enough time
        if stateElapsedTime > playerSettings.appearDuration {
            stateMachine?.enter(PlayerInputControlledState.self)
        }
    }
    
    override func willExit(to nextState: GKState) {
        super.willExit(to: nextState)
        
        // Re-enable the input component
        //inputComponent.isEnabled = true
    }

}


class PlayerInputControlledState: PlayerState {
    // MARK: Properties
    
    var moveComponent: MoveComponent {
        guard let moveComponent = entity.component(ofType: MoveComponent.self) else { fatalError("A PlayerInputControlledState's entity must have a MoveComponent.") }
        return moveComponent
    }
    
    
    // MARK: GKState Life Cycle
    
    override func didEnter(from previousState: GKState?) {
        super.didEnter(from: previousState)
        
        // Start moving Player downhill
        if let playerMoveComponent = entity.component(ofType: MoveComponent.self) {
            playerMoveComponent.downhillMovementSpeed = (playerSettings.downhillSpeedMin / 100)
        }
        
        // Turn on controller input for the PlayerEntity when entering the input-controlled state.
        //inputComponent.isEnabled = true
        
        // Start Background Music
        let backgroundMusic = SKAudioNode(fileNamed: "Skiier_Main_Loop.m4a")
        backgroundMusic.autoplayLooped = true
        backgroundMusic.name = "backgroundMusicNode"
        if let scene = entity.renderComponent.node.scene {
            scene.addChild(backgroundMusic)
        }

    }
    
    override func update(deltaTime seconds: TimeInterval) {
        super.update(deltaTime: seconds)
        
        if entity.isCrashed {
            stateMachine?.enter(PlayerCrashState.self)
        }
        if entity.reachedFinishLine {
            stateMachine?.enter(PlayerReachedFinishLineState.self)
        }
    }
    
    override func willExit(to nextState: GKState) {
        super.willExit(to: nextState)
        
        // Turn off controller input for the PlayerEntity when leaving the input-controlled state.
        //entity.componentForClass(InputComponent.self)?.isEnabled = false
        
        // Stop Background Music
        if let scene = entity.renderComponent.node.scene {
            if let backgroundMusicNode = scene.childNode(withName: "backgroundMusicNode") as? SKAudioNode {
                backgroundMusicNode.removeFromParent()
            }
        }
    }

}


class PlayerCrashState: PlayerState {
    // MARK: Properties

    var elapsedTime: TimeInterval = 0.0

    var animationComponent: AnimationComponent {
        guard let animationComponent = entity.component(ofType: AnimationComponent.self) else { fatalError("A PlayerInputControlledState's entity must have an AnimationComponent.") }
        return animationComponent
    }
    
    
    // MARK: GKState Life Cycle
    
    override func didEnter(from previousState: GKState?) {
        super.didEnter(from: previousState)
        
        elapsedTime = 0.0
        
        // Stop the Player movement
        if let playerMoveComponent = entity.component(ofType: MoveComponent.self) {
            playerMoveComponent.downhillMovementSpeed = 0
        }
        
        // Make the Player slide down (wipe out) for a moment
        entity.renderComponent.node.run(SKAction.moveTo(y: entity.renderComponent.node.position.y - playerSettings.crashSlideDistance, duration: playerSettings.crashSlideDuration))

        // Request the "crash" animation for this PlayerEntity.
        animationComponent.requestedAnimationState = .crash
        
        // Play Crash Sound
        entity.renderComponent.node.run(SKAction.playSoundFileNamed("Skiier_Crash.m4a", waitForCompletion: false))

        // Camera jolt sequence
        if let scene = entity.renderComponent.node.scene {
            if let camera = scene.camera {
                let joltUp = CGPoint(x: camera.position.x, y: camera.position.y - 1)
                let joltDown = CGPoint(x: camera.position.x, y: camera.position.y + 1)
                scene.run(SKAction.sequence([
                    SKAction.run({ camera.position = joltUp }), SKAction.wait(forDuration: 0.05),
                    SKAction.run({ camera.position = joltDown }), SKAction.wait(forDuration: 0.10),
                    SKAction.run({ camera.position = joltUp }), SKAction.wait(forDuration: 0.05),
                    SKAction.run({ camera.position = joltDown }), SKAction.wait(forDuration: 0.15),
                    SKAction.run({ camera.position = joltUp }), SKAction.wait(forDuration: 0.05),
                    SKAction.run({ camera.position = joltDown }), SKAction.wait(forDuration: 0.20),
                    SKAction.run({ camera.position = joltUp }), SKAction.wait(forDuration: 0.05),
                    SKAction.run({ camera.position = joltDown }), SKAction.wait(forDuration: 0.25),
                    SKAction.run({ camera.position = joltUp }), SKAction.wait(forDuration: 0.05),
                    SKAction.run({ camera.position = joltDown }), SKAction.wait(forDuration: 0.30)
                    ]))
            }
        }
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        super.update(deltaTime: seconds)
        
        // Update the amount of time the PlayerEntity has been in the "crash" state.
        elapsedTime += seconds
        
        // When the PlayerEntity has been in this state for long enough, transition to the appropriate next state.
        if elapsedTime >= playerSettings.crashStateDuration {
            entity.isCrashed = false
            stateMachine?.enter(PlayerInputControlledState.self)
        }
    }
    
    override func willExit(to nextState: GKState) {
        super.willExit(to: nextState)
        
        // Move the player back up to the postion before the crash
        entity.renderComponent.node.position.y += playerSettings.crashSlideDistance
    }
}


class PlayerReachedFinishLineState: PlayerState {
    // MARK: Properties
    
    var elapsedTime: TimeInterval = 0.0
    
    var moveComponent: MoveComponent {
        guard let moveComponent = entity.component(ofType: MoveComponent.self) else { fatalError("A PlayerReachedFinishLineState's entity must have a MoveComponent.") }
        return moveComponent
    }
    
    
    // MARK: GKState Life Cycle
    
    override func didEnter(from previousState: GKState?) {
        super.didEnter(from: previousState)

        elapsedTime = 0.0
        
        // Remove on-screen controls
        #if os(iOS)
            if let scene = entity.renderComponent.node.scene as? LevelScene {
                for node in scene.onScreenControlsLayer.children {
                    node.removeFromParent()
                }
            }
        #endif
        
        // Keep moving Player downhill
        if let playerMoveComponent = entity.component(ofType: MoveComponent.self) {
            playerMoveComponent.downhillMovementSpeed = (playerSettings.downhillSpeedMin / 100)
        }
        
        // Turn off controller input for the PlayerEntity when entering the input-controlled state.
        //inputComponent.isEnabled = false
        
        // Play Finish Music
        entity.renderComponent.node.run(SKAction.playSoundFileNamed("Skiier_Finish.m4a", waitForCompletion: false))
        
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        super.update(deltaTime: seconds)

        // Auto-steer player toward middle of the course
        if entity.renderComponent.node.position.x < 127 {
            moveComponent.movement = CGPoint(x: 0.5, y: 0)
        } else if entity.renderComponent.node.position.x > 129 {
            moveComponent.movement = CGPoint(x: -0.5, y: 0)
        } else {
            moveComponent.movement = CGPoint.zero
        }
        
        elapsedTime += seconds
        
        if elapsedTime >= playerSettings.reachedFinishLineStateDuration {
            // Player comes to a halt
            if let playerMoveComponent = entity.component(ofType: MoveComponent.self) {
                playerMoveComponent.downhillMovementSpeed = 0
            }
        }
    }
}

