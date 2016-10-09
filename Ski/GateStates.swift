//
//  GateStates.swift
//  Ski
//
//  Created by Ralf Tappmeyer on 6/8/16.
//  Copyright © 2016 Ralf Tappmeyer. All rights reserved.
//

import GameplayKit
import SpriteKit

class GateState: GKState {
    // MARK: Properties
    
    unowned var entity: GateEntity
    
    // MARK: Initializers
    
    init(entity: GateEntity) {
        self.entity = entity
    }
}

class GateIdleState: GateState {
    // MARK: GKState Life Cycle
    
    override func didEnter(from previousState: GKState?) {
        super.didEnter(from: previousState)
        // The gate is idle (untouched)
    }
}

class GatePassedState: GateState {
    // MARK: GKState Life Cycle
    
    override func didEnter(from previousState: GKState?) {
        super.didEnter(from: previousState)
        // The gate is considered ok
    }
}

class GateRunOverPostState: GateState {
    // MARK: GKState Life Cycle
    
    override func didEnter(from previousState: GKState?) {
        super.didEnter(from: previousState)
        // The gate is not going to count, because the post was run over
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass is GateRunOutsideState.Type
    }
}

class GateRunOutsideState: GateState {
    // MARK: GKState Life Cycle
    
    override func didEnter(from previousState: GKState?) {
        super.didEnter(from: previousState)
        // The gate is missed
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass is GateRunOverPostState.Type
    }
}
