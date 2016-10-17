//
//  GateEntity.swift
//  Ski
//
//  Created by Ralf Tappmeyer on 5/24/16.
//  Copyright © 2016 Ralf Tappmeyer. All rights reserved.
//

import SpriteKit
import GameplayKit

class GateEntity: GKEntity {
    // MARK: Properties
    
    var renderComponent: RenderComponent {
        guard let renderComponent = component(ofType: RenderComponent.self) else { fatalError("A PlayerEntity must have an RenderComponent.") }
        return renderComponent
    }
    
    var gateNode: GateNode!
    var stateComponent: StateComponent!
    
    
    // MARK: Initialize
    
    override init() {
        
        super.init()
        
        gateNode = GateNode()
        gateNode.parentEntity = self
        
        let renderComponent = RenderComponent(entity: self)
        addComponent(renderComponent)
        
        let physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 256, height: 16), center: CGPoint(x: -6,y: -8))
        physicsBody.categoryBitMask = ColliderType.gate.rawValue
        physicsBody.contactTestBitMask = ColliderType.player.rawValue
        
        let physicsComponent = PhysicsComponent(physicsBody: physicsBody)
        addComponent(physicsComponent)
        
        stateComponent = StateComponent(states: [
            GateIdleState(entity: self),
            GatePassedState(entity: self),
            GateRunOverPostState(entity: self),
            GateRunOutsideState(entity: self)]
        )
        addComponent(stateComponent)
        
        renderComponent.node.physicsBody = physicsComponent.physicsBody

        renderComponent.node.addChild(gateNode)
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
