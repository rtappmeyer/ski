//
//  SpriteComponent.swift
//  Ski
//
//  Created by Ralf Tappmeyer on 5/7/16.
//  Copyright © 2016 Ralf Tappmeyer. All rights reserved.
//

import SpriteKit
import GameplayKit

class SpriteComponent: GKComponent {
    var node: SKSpriteNode
    
    init(texture: SKTexture, size: CGSize) {
        self.node = SKSpriteNode(texture: texture, color: SKColor.white, size: size)
        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
