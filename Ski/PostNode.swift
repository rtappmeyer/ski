//
//  PostNode.swift
//  Ski
//
//  Created by Ralf Tappmeyer on 6/6/16.
//  Copyright © 2016 Ralf Tappmeyer. All rights reserved.
//
//  Abstract: The PostNode vends a SKSpriteNode illustrating one of the two posts that make a GateNode for the player to pass through to get points.

import SpriteKit

class PostNode: SKSpriteNode {    
    // MARK: Initialization
    
    init(offset: CGPoint) {
        
        let atlasTiles = SKTextureAtlas(named: "world")
        let texture = atlasTiles.textureNamed("post_16x16_00")
        let size = CGSize(width: 16, height: 16)
        
        super.init(texture: texture, color: UIColor.clear, size: size)

        position = offset
        zPosition = 50
        name = "postNode"
        
        let postPhysicsBody = SKPhysicsBody(rectangleOf: CGSize(width:4, height: 6), center: CGPoint(x: -6.0, y: -4.0))
        postPhysicsBody.categoryBitMask = ColliderType.post.rawValue
        postPhysicsBody.contactTestBitMask = ColliderType.player.rawValue
        postPhysicsBody.collisionBitMask = ColliderType.none.rawValue
//        postPhysicsBody.isDynamic = true
        
        physicsBody = postPhysicsBody

        let actionAnimation = SKAction.animate(with: [
            atlasTiles.textureNamed("post_16x16_00"),
            atlasTiles.textureNamed("post_16x16_01")
            ], timePerFrame: 0.2)
        self.run(SKAction.repeatForever(actionAnimation), withKey: "postAnimation")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func displayCrookedPost() {
        // Stop animation of the flag
        self.removeAction(forKey: "postAnimation")
        
        // Replace the image of the flag with the crooked flag
        let atlasTiles = SKTextureAtlas(named: "world")
        let crookedPostTexture = atlasTiles.textureNamed("post_crooked_16x16_00")
        self.run(SKAction.setTexture(crookedPostTexture, resize: true))
    }
}
