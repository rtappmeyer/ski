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
        guard let renderComponent = component(ofType: RenderComponent.self) else { fatalError("A PlayerEntity must have an RenderComponent.") }
        return renderComponent
    }
    
    init(obstacleType: ObstacleType) {
        self.obstacleType = obstacleType
        
        super.init()
        
        let renderComponent = RenderComponent(entity: self)
        addComponent(renderComponent)
        
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
        
        let spriteComponent = SpriteComponent(texture: texture, size: size)
        addComponent(spriteComponent)
        
        let physicsBody = SKPhysicsBody(rectangleOf: contactSize, center: contactOffset)
        physicsBody.categoryBitMask = ColliderType.obstacle.rawValue
        physicsBody.contactTestBitMask = ColliderType.player.rawValue
        
        let physicsComponent = PhysicsComponent(physicsBody: physicsBody)
        addComponent(physicsComponent)

        renderComponent.node.physicsBody = physicsComponent.physicsBody
        renderComponent.node.addChild(spriteComponent.node)

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
