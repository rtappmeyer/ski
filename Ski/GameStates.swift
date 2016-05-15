//
//  GameStates.swift
//  Ski
//
//  Created by Ralf Tappmeyer on 5/7/16.
//  Copyright © 2016 Ralf Tappmeyer. All rights reserved.
//

import AVFoundation
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
        //levelScene.paused = true
        gameLoopPaused = true
        levelScene.tapState = .startGame
    
        // Display overlay
        let announce = SKLabelNode(fontNamed: "Commodore-64-Pixelized")
        announce.position = CGPoint(x: -80, y: 100)
        announce.fontColor = UIColor.c64blueColor()
        announce.zPosition = 120
        announce.text = "PLAYER GET READY!"
        levelScene.overlayLayer.addChild(announce)
        
        let level = SKLabelNode(fontNamed: "Commodore-64-Pixelized")
        level.position = CGPoint(x: -80, y: 50)
        level.fontColor = UIColor.c64brownColor()
        level.zPosition = 120
        level.text = "LEVEL 1"
        levelScene.overlayLayer.addChild(level)
        
        let limit = SKLabelNode(fontNamed: "Commodore-64-Pixelized")
        limit.position = CGPoint(x: -80, y: 0)
        limit.fontColor = UIColor.c64blueColor()
        limit.zPosition = 120
        limit.text = "LIMIT 1:00"
        levelScene.overlayLayer.addChild(limit)
        
        // Play Initial Sound
        levelScene.runAction(SKAction.playSoundFileNamed("Skiier_Start.m4a", waitForCompletion: false))
    }
    
    override func willExitWithNextState(nextState: GKState) {
        for node in levelScene.overlayLayer.children {
            node.removeFromParent()
        }
    }
}

class GameSceneActiveState: GameSceneState {
    override func didEnterWithPreviousState(previousState: GKState?) {
        levelScene.paused = false
        gameLoopPaused = false
        levelScene.tapState = .steerPlayer
        
        let backgroundMusic = SKAudioNode(fileNamed: "Skiier_Main_Loop.m4a")
        backgroundMusic.autoplayLooped = true
        backgroundMusic.name = "backgroundMusicNode"
        levelScene.addChild(backgroundMusic)
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
        gameLoopPaused = true
        // Stop Background Music
        if let backgroundMusicNode = levelScene.childNodeWithName("backgroundMusicNode") as? SKAudioNode {
            backgroundMusicNode.removeFromParent()
        }
        // Play Crash Sound
        levelScene.runAction(SKAction.playSoundFileNamed("Skiier_Crash.m4a", waitForCompletion: false))
    }
}

class GameSceneFinishState: GameSceneState {
    override func didEnterWithPreviousState(previousState: GKState?) {
        gameLoopPaused = false
        // Stop Background Music
        if let backgroundMusicNode = levelScene.childNodeWithName("backgroundMusicNode") as? SKAudioNode {
            backgroundMusicNode.removeFromParent()
        }
        
        //let actualDuration = CGFloat(2.0)
        
        //let actionMove = SKAction.moveTo(CGPoint(x: levelScene.scene.size.width y: actualY), duration: NSTimeInterval(actualDuration))
        //let actionMoveDone = SKAction.removeFromParent()
        //monster.runAction(SKAction.sequence([actionMove, actionMoveDone]))
        
    }
}

class GameSceneWonState: GameSceneState {
}

class GameSceneLoseState: GameSceneState {
}