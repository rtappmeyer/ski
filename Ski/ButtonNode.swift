//
//  ButtonNode.swift
//  Ski
//
//  Created by Ralf Tappmeyer on 10/8/16.
//  Copyright © 2016 Ralf Tappmeyer. All rights reserved.
//

import SpriteKit

class ButtonNode: SKNode {
    var node: SKNode
    var buttonNode: SKSpriteNode
    var defaultTexture: SKTexture
    var highlightedTexture: SKTexture
    
    init(buttonType: ButtonType) {
        // Configure textures
        let atlas = SKTextureAtlas(named: "controls")
        defaultTexture = atlas.textureNamed(buttonType.rawValue)
        defaultTexture.filteringMode = SKTextureFilteringMode.nearest
        highlightedTexture = atlas.textureNamed("\(buttonType)_button_highlighted")
        highlightedTexture.filteringMode = SKTextureFilteringMode.nearest
        let textureSize = CGSize(width: 90, height: 90)
        
        // Create a circle, basically the touchable area. It's slightly larger to allow for bigger fingers
        let circleNode = SKShapeNode(circleOfRadius: 60.0)
        circleNode.fillColor = UIColor.white
        circleNode.strokeColor = UIColor.white
        circleNode.lineWidth = 10.0
        circleNode.name = buttonType.rawValue
        
        // Create a SpriteNode with the texture, it sits inside the circle
        let buttonNode = SKSpriteNode(texture: defaultTexture, size: textureSize)
        buttonNode.name = buttonType.rawValue
        buttonNode.zPosition = 10000
        circleNode.addChild(buttonNode)
        
        self.node = circleNode
        self.buttonNode = buttonNode
        
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    func showHighlighted() {
        // Button lights up
        buttonNode.texture = highlightedTexture
    }
    
    func showDefault() {
        // Button looks normal
        buttonNode.texture = defaultTexture
    }
    
}
