//
//  HomeScene.swift
//  Ski
//
//  Created by Ralf Tappmeyer on 10/15/16.
//  Copyright © 2016 Ralf Tappmeyer. All rights reserved.
//

import SpriteKit
import GameplayKit

class HomeScene: BaseScene {
    // MARK: Properties
    
    var instructionsLabel = SKLabelNode()

    // MARK: Life Cycle
    
    override func didMove(to view: SKView) {
        
        // Config World
        setupBackgroundColor()
        setupCamera()
        addScoreAndTimeLabels()

        // Game Controllers
        GameController.sharedInstance.delegate = self
        
        // Add Instructions
        let instructions = "-- INSTRUCTIONS --\n\nPUSH THE BUTTON ON JOYSTICK TO\nSPEED UP SKIER.\n\nPOINTS ARE AWARDED BY PASSING\nTHROUGH THE GATES. IF YOU PASS\nTHEM CONSECUTIVELY, THE POINTS\nBECOME HIGHER.\n\nIF YOU  FAIL TO PASS THROUGH,\nTHEN YOU ARE PENALIZED FIVE\nSECONDS.\n\nIF YOU  REACH THE GOAL WITHIN\nTHE TIME DISPLAYED AT THE START\n OF EACH RUN, THEN YOU WILL GO\nTO THE NEXT LEVEL.\n\nCREATED BY RALF TAPPMEYER"
        let instructionMessage = SKLabelNode(fontNamed: "Commodore-64-Pixelized")
        instructionMessage.fontSize = 32
        instructionMessage.horizontalAlignmentMode = .left
        instructionMessage.verticalAlignmentMode = .top
        instructionMessage.fontColor = UIColor.black
        instructionMessage.text = instructions
        let message = instructionMessage.multilined()
        message.position = CGPoint(x: -440, y: 20)
        message.zPosition = 1001
        guiLayer.addChild(message)
        
    }
    
    // MARK: Touch handling
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        setupLevelScene()
        for touch in touches {
            let positionInScene = touch.location(in: self)
            let touchedNode = self.atPoint(positionInScene)
            if touchedNode.name == "Continue" {
                setupLevelScene()
            }
        }
    }
    
    func setupLevelScene() {
        let levelScene = LevelScene(size: kSize, level: 1) // Starting with Level 1
        levelScene.scaleMode = .aspectFill
        let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
        self.view?.presentScene(levelScene, transition: reveal)
    }

}

// MARK: GameController handling delegate

extension HomeScene: GameControllerDelegate {
    func buttonEvent(event: String, velocity: Float, pushedOn: Bool) {
        if event == "buttonA" {
            // Start the first Level
            setupLevelScene()
        }
    }
    
    func stickEvent(event: String, point: CGPoint) {
        // No stick
    }
}
