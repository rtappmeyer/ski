//
//  ObstacleEntity.swift
//  Ski
//
//  Created by Ralf Tappmeyer on 5/24/16.
//  Copyright © 2016 Ralf Tappmeyer. All rights reserved.
//

import SpriteKit
import GameplayKit

enum ObstacleType: String {
    case
    Tree = "tree_30x32_00",
    Rock = "rock_16x12_00"
}

class ObstacleEntity: GKEntity {
    // MARK: Properties
    
    let obstacleType: ObstacleType
    
    var renderComponent: RenderComponent {
        guard let renderComponent = componentForClass(RenderComponent.self) else { fatalError("A PlayerEntity must have an RenderComponent.") }
        return renderComponent
    }
    
    init(obstacleType: ObstacleType) {
        self.obstacleType = obstacleType
        
        super.init()
        
        let renderComponent = RenderComponent(entity: self)
        addComponent(renderComponent)
        
        let atlas = SKTextureAtlas(named: "world")
        var size = CGSizeZero
        var texture = SKTexture()
        var contactSize = CGSizeZero
        var contactOffset = CGPointZero
        
        switch obstacleType {
        case .Tree:
            texture = atlas.textureNamed(ObstacleType.Tree.rawValue)
            size = CGSizeMake(30, 32)
            contactSize = CGSizeMake(8, 12)
            contactOffset = CGPointMake(0.0, -10.0)
        case .Rock:
            texture = atlas.textureNamed(ObstacleType.Rock.rawValue)
            size = CGSizeMake(16, 12)
            contactSize = CGSizeMake(14, 8)
            contactOffset = CGPointMake(0.0, -2.0)
        }
        
        texture.filteringMode = SKTextureFilteringMode.Nearest
        
        let spriteComponent = SpriteComponent(texture: texture, size: size)
        addComponent(spriteComponent)
        
        let physicsBody = SKPhysicsBody(rectangleOfSize: contactSize, center: contactOffset)
        physicsBody.categoryBitMask = ColliderType.Obstacle.rawValue
        physicsBody.contactTestBitMask = ColliderType.Player.rawValue
        
        let physicsComponent = PhysicsComponent(physicsBody: physicsBody)
        addComponent(physicsComponent)

        renderComponent.node.physicsBody = physicsComponent.physicsBody
        renderComponent.node.addChild(spriteComponent.node)

    }
}
