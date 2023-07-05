//
//  ObstacleNode.swift
//  Ski
//
//  Created by Ralf Tappmeyer on 10/26/16.
//  Copyright © 2016 Ralf Tappmeyer. All rights reserved.
//

import SpriteKit

enum ObstacleType: String {
    case
    Tree = "tree_30x32_00",
    Rock = "rock_16x12_00"
}

class ObstacleNode: SKNode {
    // MARK: Properties
    
    let obstacleType: ObstacleType
    
    init(obstacleType: ObstacleType) {
        self.obstacleType = obstacleType
        
        super.init()
        
        let atlas = SKTextureAtlas(named: "world")
        var size = CGSize.zero
        var texture = SKTexture()
        var contactSize = CGSize.zero
        var contactOffset = CGPoint.zero
        
        switch obstacleType {
        case .Tree:
            texture = atlas.textureNamed(ObstacleType.Tree.rawValue)
            size = CGSize(width: 30, height: 32)
            contactSize = CGSize(width: 8, height: 12)
            contactOffset = CGPoint(x: 0.0, y: -10.0)
        case .Rock:
            texture = atlas.textureNamed(ObstacleType.Rock.rawValue)
            size = CGSize(width: 16, height: 12)
            contactSize = CGSize(width: 14, height: 8)
            contactOffset = CGPoint(x: 0.0, y: -2.0)
        }
        
        texture.filteringMode = SKTextureFilteringMode.nearest
        let node = SKSpriteNode(texture: texture, color: SKColor.white, size: size)
        
        let physicsBody = SKPhysicsBody(rectangleOf: contactSize, center: contactOffset)
        physicsBody.categoryBitMask = ColliderType.obstacle.rawValue
        physicsBody.contactTestBitMask = ColliderType.player.rawValue
        physicsBody.collisionBitMask = ColliderType.none.rawValue
        
        node.physicsBody = physicsBody
        
        self.addChild(node)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
