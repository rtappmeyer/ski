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
    let node: SKSpriteNode
    
    init(texture: SKTexture, size: CGSize) {
        node = SKSpriteNode(texture: texture, color: SKColor.whiteColor(), size: size)
    }
}
