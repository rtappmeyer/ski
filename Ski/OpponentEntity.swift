//
//  OpponentEntity.swift
//  Ski
//
//  Created by Ralf Tappmeyer on 8/1/16.
//  Copyright © 2016 Ralf Tappmeyer. All rights reserved.
//

import SpriteKit
import GameplayKit

class OpponentEntity: GKEntity {
    // MARK: Properties

    var renderComponent: RenderComponent {
        guard let renderComponent = component(ofType: RenderComponent.self) else { fatalError("A OpponentEntity must have an RenderComponent.") }
        return renderComponent
    }
    
    override init() {
        
        super.init()
        
        let renderComponent = RenderComponent(entity: self)
        addComponent(renderComponent)
        
        let atlas = SKTextureAtlas(named: "opponent")
        let defaultTexture = atlas.textureNamed("idle__00.png")
        defaultTexture.filteringMode = SKTextureFilteringMode.nearest
        let size = CGSize(width: 16, height: 19)
        
        let spriteComponent = SpriteComponent(texture: defaultTexture, size: size)
        addComponent(spriteComponent)
        spriteComponent.node.anchorPoint = CGPoint(x: 0.5, y: 0.2)
        
        let moveComponent = MoveComponent()
        addComponent(moveComponent)
        
        //let physicsBody = SKPhysicsBody(rectangleOfSize: contactSize, center: contactOffset)
        //physicsBody.categoryBitMask = ColliderType.Obstacle.rawValue
        //physicsBody.contactTestBitMask = ColliderType.Player.rawValue
        
        //let physicsComponent = PhysicsComponent(physicsBody: physicsBody)
        //addComponent(physicsComponent)
        
        //renderComponent.node.physicsBody = physicsComponent.physicsBody
        renderComponent.node.addChild(spriteComponent.node)
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
