//
//  GameController.swift
//  Ski
//
//  Created by Ralf Tappmeyer on 6/10/16.
//  Copyright © 2016 Ralf Tappmeyer. All rights reserved.
//
//  Abstract: Handles connection and disconnection of an external Game Controller unit

import SpriteKit
import GameController

protocol GameControllerDelegate: class {
    func buttonEvent(event:String, velocity:Float, pushedOn:Bool)
    func stickEvent(event:String, point:CGPoint)
}

enum controllerType {
    case micro
    case standard
    case extended
}

let GameControllerSharedInstance = GameController()

class GameController {

    weak var delegate: GameControllerDelegate?
    
    var gameControllerConnected: Bool = false
    var gameController: GCController = GCController()
    var gameControllerType: controllerType?
    var gamePaused: Bool = false
    
    class var sharedInstance: GameController {
        return GameControllerSharedInstance
    }
    
    var lastShootPoint = CGPoint.zero
    
    init() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(GameController.controllerStateChanged(_:)), name: GCControllerDidConnectNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(GameController.controllerStateChanged(_:)), name: GCControllerDidDisconnectNotification, object: nil)
        
        GCController.startWirelessControllerDiscoveryWithCompletionHandler() {
            self.controllerStateChanged(NSNotification(name: "", object: nil))
        }
        self.controllerStateChanged(NSNotification(name: "", object: nil))
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: GCControllerDidConnectNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: GCControllerDidDisconnectNotification, object: nil)
    }
    
    @objc func controllerStateChanged(notification: NSNotification) {
        
        if GCController.controllers().count > 0 {
            gameControllerConnected = true
            gameController = GCController.controllers()[0] as GCController
            #if os(iOS)
                if (gameController.extendedGamepad != nil) {
                    gameControllerType = .extended
                } else {
                    gameControllerType = .standard
                }
            #elseif os(tvOS)
                if gameController.vendorName == "Remote" &&
                    GCController.controllers().count > 1 {
                    gameController = GCController.controllers()[1] as GCController
                }
                if (gameController.extendedGamepad != nil) {
                    gameControllerType = .extended
                } else if (gameController.microGamepad != nil) {
                    gameControllerType = .micro
                } else {
                    gameControllerType = .standard
                }
            #endif
            #if os(tvOS)
                if gameControllerType! == .micro,
                    let microPad:GCMicroGamepad = gameController.microGamepad {
                    
                    microPad.buttonA.valueChangedHandler = { button, value, pressed in
                        if self.delegate != nil {
                            self.delegate!.buttonEvent("buttonA", velocity: value, pushedOn: pressed)
                        }
                    }
                    
                    microPad.allowsRotation = true
                    microPad.reportsAbsoluteDpadValues = true
                    microPad.dpad.valueChangedHandler = { dpad, xValue, yValue in
                        if self.delegate != nil && !microPad.buttonX.pressed {
                            self.delegate!.stickEvent("leftstick", point:CGPoint(x: CGFloat(xValue),y: CGFloat(yValue)))
                        }
                        if self.delegate != nil && microPad.buttonX.pressed {
                            self.delegate!.stickEvent("rightstick", point:CGPoint(x: CGFloat(xValue),y: CGFloat(yValue)))
                            self.delegate!.stickEvent("leftstick", point:CGPoint(x: 0.0,y: 0.0))
                        }
                    }
                }
            #endif
            controllerAdded()
        } else {
            gameControllerConnected = false
            controllerRemoved()
        }
        
    }
    
    func controllerAdded() {
        if (gameControllerConnected) {
            
            print("GameController connected!")
            
            gameController.controllerPausedHandler = { controller in
                self.gamePaused = !self.gamePaused
                if self.delegate != nil {
                    self.delegate!.buttonEvent("Pause", velocity: 1.0, pushedOn: self.gamePaused)
                }
            }
            
            if gameControllerType! == .standard,
                let pad:GCGamepad = gameController.gamepad {
                
                pad.buttonA.valueChangedHandler = { button, value, pressed in
                    if self.delegate != nil {
                        self.delegate!.buttonEvent("buttonA", velocity: value, pushedOn: pressed)
                    }
                }
                pad.dpad.up.valueChangedHandler = { button, value, pressed in
                    if self.delegate != nil {
                        self.delegate!.buttonEvent("dpad_up", velocity: value, pushedOn: pressed)
                    }
                }
                pad.dpad.down.valueChangedHandler = { button, value, pressed in
                    if self.delegate != nil {
                        self.delegate!.buttonEvent("dpad_down", velocity: value, pushedOn: pressed)
                    }
                }
                pad.dpad.left.valueChangedHandler = { button, value, pressed in
                    if self.delegate != nil {
                        self.delegate!.buttonEvent("dpad_left", velocity: value, pushedOn: pressed)
                    }
                }
                pad.dpad.right.valueChangedHandler = { button, value, pressed in
                    if self.delegate != nil {
                        self.delegate!.buttonEvent("dpad_right", velocity: value, pushedOn: pressed)
                    }
                }
            }
        }
        if gameControllerType! == .extended,
            let extendedPad:GCExtendedGamepad = gameController.extendedGamepad {

            extendedPad.buttonA.valueChangedHandler = { button, value, pressed in
                if self.delegate != nil {
                    self.delegate!.buttonEvent("buttonA", velocity: value, pushedOn: pressed)
                }
            }
            //2
            extendedPad.leftThumbstick.valueChangedHandler = { dpad, xValue, yValue in
                if self.delegate != nil {
                    self.delegate!.stickEvent("leftstick", point:CGPoint(x: CGFloat(xValue),y: CGFloat(yValue)))
                }
            }
            extendedPad.rightThumbstick.valueChangedHandler = { dpad, xValue, yValue in
                if self.delegate != nil {
                    self.delegate!.stickEvent("rightstick", point:CGPoint(x: CGFloat(xValue),y: CGFloat(yValue)))
                }
            }
        }
    }
    
    func controllerRemoved() {
        gameControllerConnected = false
        gameControllerType = nil
    }
    
}
