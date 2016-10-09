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
        initialStateClass = type(of: states.first!) as AnyClass
        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: GKComponent Life Cycle
    
    override func update(deltaTime seconds: TimeInterval) {
        super.update(deltaTime: seconds)
        
        stateMachine.update(deltaTime: seconds)
    }
    
    // MARK: Actions
    
    func enterInitialState() {
        stateMachine.enter(initialStateClass)
    }
}
