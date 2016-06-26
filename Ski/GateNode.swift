//
//  GateNode.swift
//  Ski
//
//  Created by Ralf Tappmeyer on 6/6/16.
//  Copyright © 2016 Ralf Tappmeyer. All rights reserved.
//
//  Abstract: A GateNode illustrates a gate that the player needs to get through or passed in this game. 
//  A GateNode consists of 4 subnodes, two posts, and two missed areas to help detect whether the player successfully passed through it.
//
//  |-----missed area-----|<left Post>|---passed area---|<right Post>|--------missed area---------|
//

import SpriteKit

class GateNode: SKNode {
    // MARK: Properties
    
    weak var entity: GateEntity!
    
    var leftPost: PostNode!
    var rightPost: PostNode!
    
    var leftMissedShape: MissedNode!
    var rightMissedShape: MissedNode!

    
    // MARK: Initializer
    
    override init() {
        
        super.init()
        
        leftPost = PostNode(offset: CGPointMake(-16,0))
        rightPost = PostNode(offset: CGPointMake(16,0))
        
        leftMissedShape = MissedNode(offset: CGPointMake(-276, -8))
        rightMissedShape = MissedNode(offset: CGPointMake(8, -8))
        
        self.addChild(leftPost)
        self.addChild(rightPost)
        self.addChild(leftMissedShape)
        self.addChild(rightMissedShape)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func displayGateScore(score: Int) {
        let scoreLabel = SKLabelNode(fontNamed: "Commodore-64-Pixelized")
        scoreLabel.position = CGPointMake(-4, -6)
        scoreLabel.fontColor = UIColor.blackColor()
        scoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
        scoreLabel.text = "\(score)"
        scoreLabel.zPosition = 99
        scoreLabel.setScale(kScaleAmount)
        self.addChild(scoreLabel)
    }
 
}

