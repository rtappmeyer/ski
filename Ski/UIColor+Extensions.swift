//
//  UIColor+Extensions.swift
//  Ski
//
//  Created by Ralf Tappmeyer on 5/14/16.
//  Copyright © 2016 Ralf Tappmeyer. All rights reserved.
//

import UIKit

extension UIColor {
    fileprivate struct C64Colors {
        static let blueColor = UIColor(red: 72/255.0, green: 58/255.0, blue: 170/255.0, alpha: 1)
        static let brownColor = UIColor(red: 147/255.0, green: 73/255.0, blue: 64/255.0, alpha: 1)
    }
    public class func c64blueColor() -> UIColor {
        return C64Colors.blueColor
    }
    public class func c64brownColor() -> UIColor {
        return C64Colors.brownColor
    }
}
