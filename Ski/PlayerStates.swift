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
    
    var elapsedTime: NSTimeInterval = 0.0
    
    
    // MARK: GKState Life Cycle
    
    override func didEnterWithPreviousState(previousState: GKState?) {
        super.didEnterWithPreviousState(previousState)
        
        elapsedTime = 0.0
        
        // Player standing still
        if let playerMoveComponent = entity.componentForClass(MoveComponent.self) {
            playerMoveComponent.downhillMovementSpeed = 0
        }
        
        // Disable the input component while the PlayerEntity appears.
        //inputComponent.isEnabled = false
        
        // Play Initial Sound
        entity.renderComponent.node.runAction(SKAction.playSoundFileNamed("Skiier_Start.m4a", waitForCompletion: false))
    }

    override func updateWithDeltaTime(seconds: NSTimeInterval) {
        super.updateWithDeltaTime(seconds)

        // Update the amount of time that the PlayerEntity has been sitting.
        elapsedTime += seconds
        
        // Check if we have spent enough time
        if elapsedTime > playerSettings.appearDuration {
            stateMachine?.enterState(PlayerInputControlledState.self)
        }
    }
    
    override func willExitWithNextState(nextState: GKState) {
        super.willExitWithNextState(nextState)
        
        // Re-enable the input component
        //inputComponent.isEnabled = true
    }

}


class PlayerInputControlledState: PlayerState {
    // MARK: Properties
    
    var moveComponent: MoveComponent {
        guard let moveComponent = entity.componentForClass(MoveComponent.self) else { fatalError("A PlayerInputControlledState's entity must have a MoveComponent.") }
        return moveComponent
    }
    
    
    // MARK: GKState Life Cycle
    
    override func didEnterWithPreviousState(previousState: GKState?) {
        super.didEnterWithPreviousState(previousState)
        
        // Start moving Player downhill
        if let playerMoveComponent = entity.componentForClass(MoveComponent.self) {
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
    
    override func updateWithDeltaTime(seconds: NSTimeInterval) {
        super.updateWithDeltaTime(seconds)
        
        if entity.isCrashed {
            stateMachine?.enterState(PlayerCrashState.self)
        }
        if entity.reachedFinishLine {
            stateMachine?.enterState(PlayerReachedFinishLineState.self)
        }
    }
    
    override func willExitWithNextState(nextState: GKState) {
        super.willExitWithNextState(nextState)
        
        // Turn off controller input for the PlayerEntity when leaving the input-controlled state.
        //entity.componentForClass(InputComponent.self)?.isEnabled = false
        
        // Stop Background Music
        if let scene = entity.renderComponent.node.scene {
            if let backgroundMusicNode = scene.childNodeWithName("backgroundMusicNode") as? SKAudioNode {
                backgroundMusicNode.removeFromParent()
            }
        }
    }

}


class PlayerCrashState: PlayerState {
    // MARK: Properties

    var elapsedTime: NSTimeInterval = 0.0

    var animationComponent: AnimationComponent {
        guard let animationComponent = entity.componentForClass(AnimationComponent.self) else { fatalError("A PlayerInputControlledState's entity must have an AnimationComponent.") }
        return animationComponent
    }
    
    
    // MARK: GKState Life Cycle
    
    override func didEnterWithPreviousState(previousState: GKState?) {
        super.didEnterWithPreviousState(previousState)
        
        elapsedTime = 0.0
        
        // Stop the Player movement
        if let playerMoveComponent = entity.componentForClass(MoveComponent.self) {
            playerMoveComponent.downhillMovementSpeed = 0
        }
        
        // Make the Player slide down (wipe out) for a moment
        entity.renderComponent.node.runAction(SKAction.moveToY(entity.renderComponent.node.position.y - playerSettings.crashSlideDistance, duration: playerSettings.crashSlideDuration))

        // Request the "crash" animation for this PlayerEntity.
        animationComponent.requestedAnimationState = .Crash
        
        // Play Crash Sound
        entity.renderComponent.node.runAction(SKAction.playSoundFileNamed("Skiier_Crash.m4a", waitForCompletion: false))

        // Camera jolt sequence
        if let scene = entity.renderComponent.node.scene {
            if let camera = scene.camera {
                let joltUp = CGPoint(x: camera.position.x, y: camera.position.y - 2)
                let joltDown = CGPoint(x: camera.position.x, y: camera.position.y + 2)
                scene.runAction(SKAction.sequence([
                    SKAction.runBlock({ camera.position = joltUp }), SKAction.waitForDuration(0.05),
                    SKAction.runBlock({ camera.position = joltDown }), SKAction.waitForDuration(0.10),
                    SKAction.runBlock({ camera.position = joltUp }), SKAction.waitForDuration(0.05),
                    SKAction.runBlock({ camera.position = joltDown }), SKAction.waitForDuration(0.15),
                    SKAction.runBlock({ camera.position = joltUp }), SKAction.waitForDuration(0.05),
                    SKAction.runBlock({ camera.position = joltDown }), SKAction.waitForDuration(0.20),
                    SKAction.runBlock({ camera.position = joltUp }), SKAction.waitForDuration(0.05),
                    SKAction.runBlock({ camera.position = joltDown }), SKAction.waitForDuration(0.25),
                    SKAction.runBlock({ camera.position = joltUp }), SKAction.waitForDuration(0.05),
                    SKAction.runBlock({ camera.position = joltDown }), SKAction.waitForDuration(0.30)
                    ]))
            }
        }
    }
    
    override func updateWithDeltaTime(seconds: NSTimeInterval) {
        super.updateWithDeltaTime(seconds)
        
        // Update the amount of time the PlayerEntity has been in the "crash" state.
        elapsedTime += seconds
        
        // When the PlayerEntity has been in this state for long enough, transition to the appropriate next state.
        if elapsedTime >= playerSettings.crashStateDuration {
            entity.isCrashed = false
            stateMachine?.enterState(PlayerInputControlledState.self)
        }
    }
    
    override func willExitWithNextState(nextState: GKState) {
        super.willExitWithNextState(nextState)
        
        // Move the player back up to the postion before the crash
        entity.renderComponent.node.position.y += playerSettings.crashSlideDistance
    }
}


class PlayerReachedFinishLineState: PlayerState {
    // MARK: Properties
    
    var elapsedTime: NSTimeInterval = 0.0
    
    var moveComponent: MoveComponent {
        guard let moveComponent = entity.componentForClass(MoveComponent.self) else { fatalError("A PlayerReachedFinishLineState's entity must have a MoveComponent.") }
        return moveComponent
    }
    
    
    // MARK: GKState Life Cycle
    
    override func didEnterWithPreviousState(previousState: GKState?) {
        super.didEnterWithPreviousState(previousState)

        elapsedTime = 0.0
        
        // Start moving Player downhill
        //entity.downhillMovementSpeed = (playerSettings.downhillSpeedMin / 100) 
        // may not need this, as the player is already moving
        
        // Turn off controller input for the PlayerEntity when entering the input-controlled state.
        //inputComponent.isEnabled = false
        
        // Play Finish Music
        entity.renderComponent.node.runAction(SKAction.playSoundFileNamed("Skiier_Finish.m4a", waitForCompletion: false))
        
    }
    
    override func updateWithDeltaTime(seconds: NSTimeInterval) {
        super.updateWithDeltaTime(seconds)

        // Auto-steer player toward middle of the course
        if entity.renderComponent.node.position.x < 127 {
            moveComponent.movement = CGPointMake(0.5, 0)
        } else if entity.renderComponent.node.position.x > 129 {
            moveComponent.movement = CGPointMake(-0.5, 0)
        } else {
            moveComponent.movement = CGPointZero
        }
        
        elapsedTime += seconds
        
        if elapsedTime >= playerSettings.reachedFinishLineStateDuration {
            // Player comes to a halt
            if let playerMoveComponent = entity.componentForClass(MoveComponent.self) {
                playerMoveComponent.downhillMovementSpeed = 0
            }
        }
    }
}

