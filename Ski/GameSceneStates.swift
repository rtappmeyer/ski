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
    
    var elapsedTime: TimeInterval = 0.0
    
    
    // MARK: GKState Life Cycle
    
    override func didEnter(from previousState: GKState?) {
        scene.setupLevel()
        elapsedTime = 0.0
    
        // Display overlay text
        scene.overlayLayer.addChild(scene.createLabel(name: "getReadyLabel", text: "Player get ready!", position: CGPoint(x: -80, y: 60), color: UIColor.c64blueColor(), alignment: .center))
        scene.overlayLayer.addChild(scene.createLabel(name: "levelLabel", text: "Level 1", position: CGPoint(x: -80, y: 10), color: UIColor.c64brownColor(), alignment: .center))
        scene.overlayLayer.addChild(scene.createLabel(name: "limitLabel", text: "Limit 1:00", position: CGPoint(x: -80, y: -40), color: UIColor.c64blueColor(), alignment: .center))
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        super.update(deltaTime: seconds)
        
        elapsedTime += seconds
        
        if elapsedTime > sceneSettings.initialDuration {
            scene.stateMachine.enter(GameSceneActiveState.self)
        }
    }
    
    override func willExit(to nextState: GKState) {
        // Remove overlay text
        
        for node in scene.overlayLayer.children {
            node.removeFromParent()
        }
    }
}


class GameSceneActiveState: GameSceneState {
    // MARK: Properties
    
    var elapsedTime: TimeInterval = 0.0

    let elapsedTimeFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.zeroFormattingBehavior = .pad
        formatter.allowedUnits = [.minute, .second]
        
        return formatter
    }()

    // The formatted string representing the elapsed time of the game.
    var elapsedTimeString: String {
        var components = DateComponents()
        components.second = Int(max(0.0, elapsedTime))
        
        return elapsedTimeFormatter.string(from: components)!
    }
    
    override init(scene: GameScene) {
        super.init(scene: scene)
        
        elapsedTime = 0.0
    }
    
    override func didEnter(from previousState: GKState?) {
        scene.isPaused = false
        scene.timeLabel.text = elapsedTimeString

    }
    
    override func update(deltaTime seconds: TimeInterval) {
        super.update(deltaTime: seconds)
        
        elapsedTime += seconds
        
        // Update the display
        scene.timeLabel.text = elapsedTimeString
    }
    
    override func willExit(to nextState: GKState) {
        //scene.playerEntity.elapsedTime = elapsedTime TODO: determine playerentity
    }
}


class GameScenePausedState: GameSceneState {
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


class GameSceneFinishState: GameSceneState {
    // MARK: Properties
    
    var elapsedTime: TimeInterval = 0.0
    var bonusText: String!
    
    // MARK: GKState Life Cycle

    override func didEnter(from previousState: GKState?) {
        
        elapsedTime = 0.0

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
        //scene.overlayLayer.addChild(scene.createLabel(name: "bonusLabel", text: bonusText, position: CGPoint(x: -80, y: 100), color: UIColor.c64blueColor(), alignment: .center))
        
        // Remove Controls
        for node in scene.guiLayer.children {
            node.removeFromParent()
        }
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        super.update(deltaTime: seconds)
        
        elapsedTime += seconds
        
        if elapsedTime > sceneSettings.beforeBonusDuration {
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
