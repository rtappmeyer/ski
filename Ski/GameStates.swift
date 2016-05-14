//
//  GameStates.swift
//  Ski
//
//  Created by Ralf Tappmeyer on 5/7/16.
//  Copyright © 2016 Ralf Tappmeyer. All rights reserved.
//

import GameplayKit
import SpriteKit

class GameSceneState: GKState {
    unowned let levelScene: GameScene
    init(scene: GameScene) {
        self.levelScene = scene
    }
}

class GameSceneInitialState: GameSceneState {
    override func didEnterWithPreviousState(previousState: GKState?) {
        // Scene Setup
        levelScene.setupLevel()
        
        //Scene Activity
        levelScene.paused = true
        gameLoopPaused = true
        levelScene.tapState = .startGame
        
        let scoreLabel = SKLabelNode(fontNamed: "Commodore-64-Pixelized")
        scoreLabel.position = CGPoint(x: (levelScene.scene?.size.width)!*0.4, y: (levelScene.scene?.size.height)!*0.3)
        scoreLabel.fontColor = UIColor.blueColor()
        scoreLabel.name = "scoreLabel"
        scoreLabel.zPosition = 1000
        levelScene.guiLayer.addChild(scoreLabel)
    
    }
    
    override func willExitWithNextState(nextState: GKState) {
        //for node in levelScene.overlayLayer.children {
        //    node.removeFromParent()
        //}
    }
}

class GameSceneActiveState: GameSceneState {
    override func didEnterWithPreviousState(previousState: GKState?) {
        levelScene.paused = false
        gameLoopPaused = false
        levelScene.tapState = .steerPlayer
    }
}

class GameScenePausedState: GameSceneState {
    override func didEnterWithPreviousState(previousState: GKState?) {
        levelScene.paused = true
        gameLoopPaused = true
        levelScene.tapState = .dismissPause
    }
}

class GameSceneLimboState: GameSceneState {
    override func didEnterWithPreviousState(previousState: GKState?) {
        levelScene.tapState = .steerPlayer
        levelScene.score = levelScene.score + 100
    }
}

class GameSceneWinState: GameSceneState {
}

class GameSceneLoseState: GameSceneState {
}