//
//  LevelSceneStates.swift
//  Ski
//
//  Created by Ralf Tappmeyer on 5/7/16.
//  Copyright © 2016 Ralf Tappmeyer. All rights reserved.
//

import AVFoundation
import GameplayKit
import SpriteKit

class LevelSceneState: GKState {
    // MARK: Properties
    
    unowned let scene: LevelScene
    
    
    // MARK: Initializers
    
    init(scene: LevelScene) {
        self.scene = scene
    }
}


class LevelSceneInitialState: LevelSceneState {
    // MARK: Properties
    
    var stateElapsedTime: TimeInterval = 0.0
    
    let timeLimitFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.zeroFormattingBehavior = .pad
        formatter.allowedUnits = [.minute, .second]
        return formatter
    }()
    
    // The formatted string representing the time limit of this level.
    var timeLimitString: String {
        var components = DateComponents()
        components.second = Int(max(0.0, scene.timeLimit))
        return timeLimitFormatter.string(from: components)!
    }
    
    // MARK: GKState Life Cycle
    
    override func didEnter(from previousState: GKState?) {
        stateElapsedTime = 0.0
        
        // Display overlay text
        scene.overlayLayer.addChild(scene.createLabel(name: "getReadyLabel", text: "Player get ready!", position: CGPoint(x: -80, y: 40), color: UIColor.c64blueColor(), alignment: .center))
        scene.overlayLayer.addChild(scene.createLabel(name: "levelLabel", text: "Level \(scene.level)", position: CGPoint(x: -80, y: -10), color: UIColor.c64brownColor(), alignment: .center))
        scene.overlayLayer.addChild(scene.createLabel(name: "limitLabel", text: "Limit \(timeLimitString)", position: CGPoint(x: -80, y: -60), color: UIColor.c64blueColor(), alignment: .center))
        
        // Play Initial Sound
        scene.worldLayer.run(SKAction.playSoundFileNamed("Skiier_Start.m4a", waitForCompletion: false))
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        super.update(deltaTime: seconds)
        
        stateElapsedTime += seconds
        
        if stateElapsedTime > sceneSettings.initialDuration {
            scene.stateMachine.enter(LevelSceneActiveState.self)
        }
    }
    
    override func willExit(to nextState: GKState) {
        // Remove overlay text
        
        for node in scene.overlayLayer.children {
            node.removeFromParent()
        }
        
    }
}


class LevelSceneActiveState: LevelSceneState {
    override func didEnter(from previousState: GKState?) {
        scene.isPaused = false
    }
}


class LevelScenePausedState: LevelSceneState {
    override func didEnter(from previousState: GKState?) {
        scene.isPaused = true
        
        scene.overlayLayer.addChild(scene.createLabel(name: "pausedLabel", text: "-- Paused --", position: CGPoint(x: -60, y: 100), color: UIColor.c64blueColor(), alignment: .center))
    }
    
    override func willExit(to nextState: GKState) {
        // Remove overlay text
        
        for node in scene.overlayLayer.children {
            node.removeFromParent()
        }
        
    }
}


class LevelSceneFinishState: LevelSceneState {
    // MARK: Properties
    
    var stateElapsedTime: TimeInterval = 0.0
    var bonusText: String!
    
    // MARK: GKState Life Cycle

    override func didEnter(from previousState: GKState?) {
        
        stateElapsedTime = 0.0

        //let bonusSeconds = Int(sceneSettings.timeLimit - scene.playerEntity.elapsedTime) TODO: determine playerentity
        let bonusSeconds = 0
        print("bonusseconds=\(bonusSeconds)")
        if bonusSeconds > 0 {
            //scene.playerEntity.score += bonusSeconds * sceneSettings.timeBonusScore
            bonusText = "Bonus Points \(sceneSettings.timeBonusScore) X\(bonusSeconds)"
        } else {
            bonusText = "No Bonus Points"
        }
        
        // Display overlay text
        scene.overlayLayer.addChild(scene.createLabel(name: "bonusLabel", text: bonusText, position: CGPoint(x: -80, y: 100), color: UIColor.c64blueColor(), alignment: .center))
        
        // Increase the level
        if scene.level < levelSettings.levels.count  {
            scene.level += 1
        } else {
            scene.level = 1 // Back to level one after done
        }
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        super.update(deltaTime: seconds)
        
        stateElapsedTime += seconds
        
        if stateElapsedTime > sceneSettings.beforeBonusDuration {
            // Done
        }
    }
    
    override func willExit(to nextState: GKState) {
        // Remove overlay text
        
        for node in scene.overlayLayer.children {
            node.removeFromParent()
        }
        
    }
}
