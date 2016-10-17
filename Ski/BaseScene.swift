//
//  BaseScene.swift
//  Ski
//
//  Created by Ralf Tappmeyer on 10/15/16.
//  Copyright © 2016 Ralf Tappmeyer. All rights reserved.
//

import SpriteKit
import GameplayKit

class BaseScene: SKScene {
    // MARK: Properties

    var guiLayer = SKNode()
    var overlayLayer = SKNode()
    var onScreenControlsLayer = SKNode()
    
    var scoreLabel = SKLabelNode()
    var timeLabel = SKLabelNode()

    var lastUpdateTimeInterval: TimeInterval = 0
    let maximumUpdateDeltaTime: TimeInterval = 1.0 / 60.0
    var lastDeltaTime: TimeInterval = 0
    
    let elapsedTimeFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.zeroFormattingBehavior = .pad
        formatter.allowedUnits = [.minute, .second]
        return formatter
    }()
    
    func setupBackgroundColor() {
        backgroundColor = UIColor.white
    }
    
    func setupCamera() {
        let myCamera = SKCameraNode()
        myCamera.setScale(kScaleAmount)
        camera = myCamera
        addChild(myCamera)
        
        camera!.addChild(guiLayer)
        guiLayer.addChild(overlayLayer)
        guiLayer.addChild(onScreenControlsLayer)
        
    }
    
    func addScoreAndTimeLabels() {
        scoreLabel = createLabel(name: "scoreLabel", text: "00", position: CGPoint(x: 480, y: 200), color: UIColor.black, alignment: .right)
        timeLabel = createLabel(name: "timeLabel", text: "00:00", position: CGPoint(x: 480, y: -60), color: UIColor.c64brownColor(), alignment: .right)
        
        guiLayer.addChild(createLabel(name: "scoreTitleLabel", text: "Score", position: CGPoint(x: 480, y: 230), color: UIColor.black, alignment: .right))
        guiLayer.addChild(scoreLabel)
        guiLayer.addChild(createLabel(name: "timeTitleLabel", text: "Time", position: CGPoint(x: 480, y: -30), color: UIColor.c64brownColor(), alignment: .right))
        guiLayer.addChild(timeLabel)
    }

    // MARK: Convenience
    
    func createLabel(name: String, text: String, position: CGPoint, color: UIColor, alignment: SKLabelHorizontalAlignmentMode) -> SKLabelNode {
        let label = SKLabelNode(fontNamed: "Commodore-64-Pixelized")
        label.position = position
        label.fontColor = color
        label.horizontalAlignmentMode = alignment
        label.text = text.uppercased()
        label.name = name
        label.zPosition = 1000
        return label
    }

}
