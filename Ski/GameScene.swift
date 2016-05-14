//
//  GameScene.swift
//  Ski
//
//  Created by Ralf Tappmeyer on 4/9/16.
//  Copyright (c) 2016 Ralf Tappmeyer. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, tileMapDelegate {
    // World
    var worldGenerator = tileMap()
    var worldLayer = SKNode()
    
    var guiLayer = SKNode()
    var overlayLayer = SKNode()
    
    // State Machine
    lazy var stateMachine: GKStateMachine = GKStateMachine(states: [GameSceneInitialState(scene: self), GameSceneActiveState(scene: self), GameScenePausedState(scene: self), GameSceneLimboState(scene: self), GameSceneWinState(scene: self), GameSceneLoseState(scene: self)])
    
    // Entities
    var entities = Set<GKEntity>()
    
    // Movement
    var movement = CGPointZero
    var beginTouchLocation = CGPointZero
    
    var lastUpdateTimeInterval: NSTimeInterval = 0
    let maximumUpdateDeltaTime: NSTimeInterval = 1.0 / 60.0
    var lastDeltaTime: NSTimeInterval = 0
    
    var score = 1000
    var tapState = tapAction.startGame
    
    lazy var componentSystems: [GKComponentSystem] = {
        let animationSystem = GKComponentSystem(componentClass: AnimationComponent.self)
        let playerMoveSystem = GKComponentSystem(componentClass: PlayerMoveComponent.self)
        return [animationSystem, playerMoveSystem]
    }()

    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        
        print(size.width)
        // Delegates
        worldGenerator.delegate = self
        
        // Setup Camera
        let myCamera = SKCameraNode()
        camera = myCamera
        addChild(myCamera)
        updateCameraScale()
        
        // Config World
        addChild(worldLayer)
        camera!.addChild(guiLayer)
        guiLayer.addChild(overlayLayer)
        
        // Gamestate
        stateMachine.enterState(GameSceneInitialState.self)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        /* Called when a touch begins */
        
        if touches.count > 0  {
            switch tapState {
            case .startGame:
                stateMachine.enterState(GameSceneActiveState.self)
                break
            case .steerPlayer:
                for touch in touches {
                    //let key = String.init(format:"%d", touch)
                    beginTouchLocation = touch.locationInNode(self)
                }
                break
            case .dismissPause:
                stateMachine.enterState(GameSceneActiveState.self)
                break
            default:
                break
            }
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        /* Called when a touch moved */
        if touches.count > 0 {
            for touch in touches {
                //let key = String.init(format:"%d", touch)
                let dragLocation = touch.locationInNode(self)
                if (dragLocation.x - beginTouchLocation.x >= 100 || dragLocation.x - beginTouchLocation.x <= -100) {
                    // Dragged too far, reset the location
                    beginTouchLocation = dragLocation
                } else {
                    let motion = CGPointMake((dragLocation.x - beginTouchLocation.x)/100, (dragLocation.y - beginTouchLocation.y)/100)
                    movement = motion
                }
            }
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        //if touches.count > 0 {
            //for touch in touches {
                //let key = String.init(format:"%d", touch)
            //}
        //}
    }

   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        
        if gameLoopPaused { return }
        
        // Calculate delta time
        var deltaTime = currentTime - lastUpdateTimeInterval
        deltaTime = deltaTime > maximumUpdateDeltaTime ? maximumUpdateDeltaTime : deltaTime
        lastUpdateTimeInterval = currentTime
        
        // player controls
        if let player = worldLayer.childNodeWithName("playerNode") as? EntityNode, let playerEntity = player.entity as? PlayerEntity {
            if !(movement == CGPointZero) {
                playerEntity.moveComponent.movement = movement
            }
        }
        
        // Update all components
        for componentSystem in componentSystems {
            componentSystem.updateWithDeltaTime(deltaTime)
        }
        
        // Update player after components
        if let player = worldLayer.childNodeWithName("playerNode") as? EntityNode
        {
            var cameraPosition: CGPoint = player.position
            cameraPosition.x = ((size.width/2)*kScaleAmount) - 10 // Basically adding 10 points as a buffer
            centerCameraOnPoint(cameraPosition)
        }
    }
    
    override func didFinishUpdate() {
        if let label = guiLayer.childNodeWithName("scoreLabel") as? SKLabelNode {
            label.text = "\(score)"
        }
    }
    
    func setupLevel() {
        //Update
        worldGenerator.generateLevel(0)
        print("TileMapSize=\(worldGenerator.tilemapSize())")
        
        //Add
        worldGenerator.generateLevel()
        worldGenerator.presentLayerViaDelegate()
    }
    
    func createNodeOf(type type:tileType, location:CGPoint) {
        let atlasTiles = SKTextureAtlas(named: "world")

        switch type {
        case .tileAir:
            break
        case .tileSnow:
            let node = SKSpriteNode(texture: atlasTiles.textureNamed("snow_16x32_00"))
            node.size = CGSize(width: 16, height: 32)
            node.position = location
            node.zPosition = 1
            addChild(node)
            break
        case .tileTree:
            let texture = atlasTiles.textureNamed("tree_30x32_00")
            texture.filteringMode = SKTextureFilteringMode.Nearest
            let node = SKSpriteNode(texture: texture)
            node.size = CGSize(width: 30, height: 32)
            node.position = location
            node.zPosition = 50
            node.name = "Tree"
            worldLayer.addChild(node)
            break
        case .tileRock:
            let texture = atlasTiles.textureNamed("rock_16x12_00")
            texture.filteringMode = SKTextureFilteringMode.Nearest
            let node = SKSpriteNode(texture: texture)
            node.size = CGSize(width: 16, height: 12)
            node.position = location
            node.zPosition = 50
            node.name = "Rock"
            worldLayer.addChild(node)
            break
        case .tilePost:
            let texture = atlasTiles.textureNamed("post_16x16_00")
            texture.filteringMode = SKTextureFilteringMode.Nearest
            let node = SKSpriteNode(texture: texture)
            node.size = CGSize(width: 16, height: 16)
            node.position = location
            node.zPosition = 50
            node.name = "Post"
            worldLayer.addChild(node)
            let actionAnimation = SKAction.animateWithTextures([atlasTiles.textureNamed("post_16x16_00"), atlasTiles.textureNamed("post_16x16_01")], timePerFrame: 0.2)
            node.runAction(SKAction.repeatActionForever(actionAnimation))
            break
        case .tileStart:
            let playerEntity = PlayerEntity()
            let playerNode = playerEntity.spriteComponent.node
            playerNode.position = location
            playerNode.name = "playerNode"
            playerNode.zPosition = 10
            playerNode.anchorPoint = CGPointMake(0.5, 0.2)
            playerEntity.animationComponent.requestedAnimationState = .Idle
            addEntity(playerEntity)
            break
        default:
            break
        }
    }
    
    func addEntity(entity: GKEntity) {
        entities.insert(entity)
        if let spriteNode = entity.componentForClass(SpriteComponent.self)?.node {
            worldLayer.addChild(spriteNode)
        }
        for componentSystem in self.componentSystems {
            componentSystem.addComponentWithEntity(entity)
        }
    }
    
    // MARK: camera controls
    
    func centerCameraOnPoint(point: CGPoint) {
        if let camera = camera {
            camera.position = point
        }
    }
    
    func updateCameraScale() {
        if let camera = camera {
            camera.setScale(kScaleAmount)
        }
    }


}
