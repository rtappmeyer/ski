//
//  GameSceneStates.swift
//  Ski
//
//  Created by Ralf Tappmeyer on 5/7/16.
//  Copyright © 2016 Ralf Tappmeyer. All rights reserved.
//

import AVFoundation
import GameplayKit
import SpriteKit

class GameSceneState: GKState {
    // MARK: Properties
    
    unowned let scene: GameScene
    
    
    // MARK: Initializers
    
    init(scene: GameScene) {
        self.scene = scene
    }
}


class GameSceneInitialState: GameSceneState {
    // MARK: Properties
    
    var elapsedTime: NSTimeInterval = 0.0
    
    
    // MARK: GKState Life Cycle
    
    override func didEnterWithPreviousState(previousState: GKState?) {
        scene.setupLevel()
        elapsedTime = 0.0
    
        // Display overlay text
        scene.overlayLayer.addChild(scene.createLabel("getReadyLabel", text: "Player get ready!", position: CGPointMake(-80, 100), color: UIColor.c64blueColor(), alignment: .Center))
        scene.overlayLayer.addChild(scene.createLabel("levelLabel", text: "Level 1", position: CGPointMake(-80, 50), color: UIColor.c64brownColor(), alignment: .Center))
        scene.overlayLayer.addChild(scene.createLabel("limitLabel", text: "Limit 1:00", position: CGPointMake(-80, 0), color: UIColor.c64blueColor(), alignment: .Center))
    }
    
    override func updateWithDeltaTime(seconds: NSTimeInterval) {
        super.updateWithDeltaTime(seconds)
        
        elapsedTime += seconds
        
        if elapsedTime > sceneSettings.initialDuration {
            scene.stateMachine.enterState(GameSceneActiveState.self)
        }
    }
    
    override func willExitWithNextState(nextState: GKState) {
        // Remove overlay text
        
        for node in scene.overlayLayer.children {
            node.removeFromParent()
        }
    }
}


class GameSceneActiveState: GameSceneState {
    // MARK: Properties
    
    var elapsedTime: NSTimeInterval = 0.0

    let elapsedTimeFormatter: NSDateComponentsFormatter = {
        let formatter = NSDateComponentsFormatter()
        formatter.zeroFormattingBehavior = .Pad
        formatter.allowedUnits = [.Minute, .Second]
        
        return formatter
    }()

    // The formatted string representing the elapsed time of the game.
    var elapsedTimeString: String {
        let components = NSDateComponents()
        components.second = Int(max(0.0, elapsedTime))
        
        return elapsedTimeFormatter.stringFromDateComponents(components)!
    }
    
    override init(scene: GameScene) {
        super.init(scene: scene)
        
        elapsedTime = 0.0
    }
    
    override func didEnterWithPreviousState(previousState: GKState?) {
        scene.paused = false
        scene.timeLabel.text = elapsedTimeString

    }
    
    override func updateWithDeltaTime(seconds: NSTimeInterval) {
        super.updateWithDeltaTime(seconds)
        
        elapsedTime += seconds
        
        // Update the display
        scene.timeLabel.text = elapsedTimeString
    }
    
    override func willExitWithNextState(nextState: GKState) {
        scene.playerEntity.elapsedTime = elapsedTime
    }
}


class GameScenePausedState: GameSceneState {
    override func didEnterWithPreviousState(previousState: GKState?) {
        scene.paused = true
        
        scene.overlayLayer.addChild(scene.createLabel("pausedLabel", text: "-- Paused --", position: CGPointMake(-60, 100), color: UIColor.c64blueColor(), alignment: .Center))
    }
    
    override func willExitWithNextState(nextState: GKState) {
        // Remove overlay text
        
        for node in scene.overlayLayer.children {
            node.removeFromParent()
        }
        
    }
}


class GameSceneFinishState: GameSceneState {
    // MARK: Properties
    
    var elapsedTime: NSTimeInterval = 0.0
    var bonusText: String!
    
    // MARK: GKState Life Cycle

    override func didEnterWithPreviousState(previousState: GKState?) {
        
        elapsedTime = 0.0

        let bonusSeconds = Int(sceneSettings.timeLimit - scene.playerEntity.elapsedTime)
        print("bonusseconds=\(bonusSeconds)")
        if bonusSeconds > 0 {
            scene.playerEntity.score += bonusSeconds * sceneSettings.timeBonusScore
            bonusText = "Bonus Points \(sceneSettings.timeBonusScore) X\(bonusSeconds)"
        } else {
            bonusText = "No Bonus Points"
        }
        
        // Display overlay text
        scene.overlayLayer.addChild(scene.createLabel("bonusLabel", text: bonusText, position: CGPointMake(-80, 100), color: UIColor.c64blueColor(), alignment: .Center))
        
    }
    
    override func updateWithDeltaTime(seconds: NSTimeInterval) {
        super.updateWithDeltaTime(seconds)
        
        elapsedTime += seconds
        
        if elapsedTime > sceneSettings.beforeBonusDuration {
            // Done
        }
    }
    
    override func willExitWithNextState(nextState: GKState) {
        // Remove overlay text
        
        for node in scene.overlayLayer.children {
            node.removeFromParent()
        }
        
    }
}
