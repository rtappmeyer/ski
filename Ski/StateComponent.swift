//
//  StateComponent.swift
//  Ski
//
//  Created by Ralf Tappmeyer on 6/6/16.
//  Copyright © 2016 Ralf Tappmeyer. All rights reserved.
//

import GameplayKit

class StateComponent: GKComponent {
    // MARK: Properties
    
    let stateMachine: GKStateMachine
    let initialStateClass: AnyClass
    
    // MARK: Initializers
    
    init(states: [GKState]) {
        stateMachine = GKStateMachine(states: states)
        initialStateClass = states.first!.dynamicType
    }
    
    // MARK: GKComponent Life Cycle
    
    override func updateWithDeltaTime(seconds: NSTimeInterval) {
        super.updateWithDeltaTime(seconds)
        
        stateMachine.updateWithDeltaTime(seconds)
    }
    
    // MARK: Actions
    
    func enterInitialState() {
        stateMachine.enterState(initialStateClass)
    }
}
