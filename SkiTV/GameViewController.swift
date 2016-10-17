//
//  GameViewController.swift
//  SkiTV
//
//  Created by Ralf Tappmeyer on 6/10/16.
//  Copyright (c) 2016 Ralf Tappmeyer. All rights reserved.
//

import UIKit
import SpriteKit

var kScreenWidth = CGFloat()
var kScreenHeight = CGFloat()
var kScaleAmount = CGFloat()
var kSize = CGSize()

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        kScreenWidth = view.frame.size.width
        kScreenHeight = view.frame.size.height
        kScaleAmount = 0.3
        kSize = CGSize(width: 1024, height: 768)

        print("Detected screensize: width=\(kScreenWidth) height=\(kScreenHeight)")
        print("Detected bounds size= \((view.bounds.size))")
        
        let scene = HomeScene(size: kSize)

        // Configure the view.
        let skView = self.view as! SKView
        //skView.showsFPS = true
        //skView.showsNodeCount = true
        
        /* Sprite Kit applies additional optimizations to improve rendering performance */
        skView.ignoresSiblingOrder = true
        
        /* Set the scale mode to scale to fit the window */
        scene.scaleMode = .aspectFill
        
        skView.presentScene(scene)
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
}
