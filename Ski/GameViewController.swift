//
//  GameViewController.swift
//  Ski
//
//  Created by Ralf Tappmeyer on 4/9/16.
//  Copyright (c) 2016 Ralf Tappmeyer. All rights reserved.
//

import UIKit
import SpriteKit

var kScreenWidth = CGFloat()
var kScreenHeight = CGFloat()
var kScaleAmount = CGFloat()

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        if let scene = GameScene(fileNamed:"GameScene") {
            
            kScreenWidth = view.frame.size.width
            kScreenHeight = view.frame.size.height
            kScaleAmount = 0.3
            print("Detected screensize: width=\(kScreenWidth) height=\(kScreenHeight)")
            
            // Configure the view.
            let skView = self.view as! SKView
            //skView.showsFPS = true
            //skView.showsNodeCount = true
            //skView.showsPhysics = true
            
            // Allow multiple touches
            skView.multipleTouchEnabled = true

            /* Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = true
            
            /* Set the scale mode to scale to fit the window */
            scene.scaleMode = .AspectFill
            
            skView.presentScene(scene)
        }
    }

    override func shouldAutorotate() -> Bool {
        return true
    }

    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return .LandscapeRight
        } else {
            return .LandscapeRight
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
