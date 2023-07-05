//
//  InterfaceController.swift
//  SkiWatch Extension
//
//  Created by Ralf Tappmeyer on 10/31/16.
//  Copyright © 2016 Ralf Tappmeyer. All rights reserved.
//

import WatchKit
import Foundation

class InterfaceController: WKInterfaceController, WKCrownDelegate {
    
    @IBOutlet var skInterface: WKInterfaceSKScene!
    
    let skScene = WatchGameScene(size: WKInterfaceDevice.current().screenBounds.size) //, level: 1)
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Set the scale mode to scale to fit the window
        //skScene.scaleMode = .aspectFill
        //skView.showsFPS = true
        //skView.showsNodeCount = true
        //skView.showsPhysics = true
        
        // Present the scene
        self.skInterface.presentScene(skScene)
        
        // Use a value that will maintain a consistent frame rate
        //self.skInterface.preferredFramesPerSecond = 30
        
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        crownSequencer.delegate = self
        crownSequencer.focus()
        //skScene.start()
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        //skScene.stop()
        super.didDeactivate()
    }
    
    func crownDidRotate(_ crownSequencer: WKCrownSequencer?, rotationalDelta: Double) {
        if rotationalDelta > watchSettings.crownRotation {
            skScene.movement.x = 1
        } else if rotationalDelta < (watchSettings.crownRotation * -1) {
            skScene.movement.x = -1
        } else {
            skScene.movement.x = 0
        }
        
        //skScene.movement.x += CGFloat(rotationalDelta * 2.0)
    }
    
}
