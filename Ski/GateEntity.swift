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
        guard let renderComponent = componentForClass(RenderComponent.self) else { fatalError("A PlayerEntity must have an RenderComponent.") }
        return renderComponent
    }
    
    var gateNode: GateNode!
    var stateComponent: StateComponent!
    
    
    // MARK: Initialize
    
    override init() {
        
        super.init()
        
        gateNode = GateNode()
        gateNode.entity = self
        
        let renderComponent = RenderComponent(entity: self)
        addComponent(renderComponent)
        
        let physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(28, 16), center: CGPointMake(-6,-8))
        physicsBody.categoryBitMask = ColliderType.Gate.rawValue
        physicsBody.contactTestBitMask = ColliderType.Player.rawValue
        
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
    
    func runOverPost(postNode: PostNode) {
        postNode.displayCrookedPost()
    }
    
    func didPassGate(score: Int) {
        gateNode.displayGateScore(score)
    }
}