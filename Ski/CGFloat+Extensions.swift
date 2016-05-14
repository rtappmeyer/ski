//
//  CGFloat+Extensions.swift
//  Ski
//
//  Created by Ralf Tappmeyer on 5/7/16.
//  Copyright © 2016 Ralf Tappmeyer. All rights reserved.
//

import CoreGraphics

/** The value of π as a CGFloat */
let π = CGFloat(M_PI)

public extension CGFloat {
    // Converts an angle in degrees to radians.
    public func degreesToRadians() -> CGFloat {
        return π * self / 180.0
    }
    
    // Converts an angle in radians to degrees.
    public func radiansToDegrees() -> CGFloat {
        return self * 180.0 / π
    }
}
