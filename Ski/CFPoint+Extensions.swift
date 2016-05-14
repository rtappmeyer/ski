//
//  CFPoint+Extensions.swift
//  Ski
//
//  Created by Ralf Tappmeyer on 5/7/16.
//  Copyright © 2016 Ralf Tappmeyer. All rights reserved.
//

import CoreGraphics
import SpriteKit

public extension CGPoint {

    // Returns the angle in radians of the vector described by the CGPoint.
    // The range of the angle is -π to π; an angle of 0 points to the right.
    
    public var angle: CGFloat {
        return atan2(y, x)
    }
}
