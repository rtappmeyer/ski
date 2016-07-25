//
//  GameScene.swift
//  Ski
//
//  Created by Ralf Tappmeyer on 4/9/16.
//  Copyright (c) 2016 Ralf Tappmeyer. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, tileMapDelegate, SKPhysicsContactDelegate, GameControllerDelegate {
    // MARK: Properties
    
    var worldGenerator = tileMap()
    var worldLayer = SKNode()
    var guiLayer = SKNode()
    var overlayLayer = SKNode()
    
    let playerEntity = PlayerEntity()
    var entities = Set<GKEntity>()
    
    var scoreLabel = SKLabelNode()
    var timeLabel = SKLabelNode()
    
    lazy var stateMachine: GKStateMachine = GKStateMachine(states: [
        GameSceneInitialState(scene: self),
        GameSceneActiveState(scene: self),
        GameScenePausedState(scene: self),
        GameSceneFinishState(scene: self)
        ])
    
    lazy var componentSystems: [GKComponentSystem] = {
        let moveSystem = GKComponentSystem(componentClass: MoveComponent.self)
        let animationSystem = GKComponentSystem(componentClass: AnimationComponent.self)
        let stateSystem = GKComponentSystem(componentClass: StateComponent.self)
        return [moveSystem, animationSystem, stateSystem]
    }()
    
    var inputMovement = CGPointZero
    var inputPushButtonPressed = false
    var beginTouchLocation = CGPointZero
    
    var lastUpdateTimeInterval: NSTimeInterval = 0
    let maximumUpdateDeltaTime: NSTimeInterval = 1.0 / 60.0
    var lastDeltaTime: NSTimeInterval = 0
    
    var score = 0
    var startTime = NSDate()
    var timeLimitSeconds = 60
    
    // Touch Debugging
    //let touchBox = SKSpriteNode(color: UIColor.redColor(), size: CGSize(width: 100, height: 100))
    
    // MARK: Life Cycle
    
    override func didMoveToView(view: SKView) {
        // Delegates
        worldGenerator.delegate = self
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = CGVector.zero
        
        // Setup Camera
        let myCamera = SKCameraNode()
        myCamera.setScale(kScaleAmount)
        camera = myCamera
        addChild(myCamera)
        
        // Config World
        addChild(worldLayer)
        camera!.addChild(guiLayer)
        guiLayer.addChild(overlayLayer)
        
        // Game Controllers
        GameController.sharedInstance.delegate = self
        
        // Add Labels
        scoreLabel = createLabel("scoreLabel", text: "00", position: CGPointMake(480, 230), color: UIColor.blackColor(), alignment: .Right)
        timeLabel = createLabel("timeLabel", text: "00:00", position: CGPointMake(480, -60), color: UIColor.c64brownColor(), alignment: .Right)
        
        guiLayer.addChild(createLabel("scoreTitleLabel", text: "Score", position: CGPointMake(480, 260), color: UIColor.blackColor(), alignment: .Right))
        guiLayer.addChild(scoreLabel)
        guiLayer.addChild(createLabel("timeTitleLabel", text: "Time", position: CGPointMake(480, -30), color: UIColor.c64brownColor(), alignment: .Right))
        guiLayer.addChild(timeLabel)
        
        // Touch debugging
        //addChild(touchBox)

        // Entering Gamestates
        stateMachine.enterState(GameSceneInitialState.self)
    }
    
    
    // MARK: Touch handling delegate
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        switch stateMachine.currentState {
        case is GameSceneActiveState:
            // Control the player
            #if os(iOS)
            if touches.count > 0  {
                for touch in touches {
                    beginTouchLocation = touch.locationInNode(self)
                    //touchBox.position = beginTouchLocation
                }
                inputPushButtonPressed = true
            }
            #endif
        case is GameSceneFinishState:
            // Restart the game
            restartLevel()
        
        case is GameScenePausedState:
            // Resume the game
            self.stateMachine.enterState(GameSceneActiveState)
            
        default:
            break
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        #if os(iOS)
        if touches.count > 0 {
            for touch in touches {
                let dragLocation = touch.locationInNode(self)
                //touchBox.position = dragLocation
                if (dragLocation.x - beginTouchLocation.x >= 100 || dragLocation.x - beginTouchLocation.x <= -100) {
                    // Dragged too far, reset the location
                    beginTouchLocation = dragLocation
                } else {
                    let touchMotion = CGPointMake((dragLocation.x - beginTouchLocation.x)/100, (dragLocation.y - beginTouchLocation.y)/100)
                    inputMovement = touchMotion
                }
            }
            // Speed up the player
            inputPushButtonPressed = true
        }
        #endif
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        #if os(iOS)
        if touches.count > 0 {
            // slow down the player
            inputPushButtonPressed = false
        }
        #endif
    }

    
    // MARK: GameController handling delegate
    
    func buttonEvent(event: String, velocity: Float, pushedOn: Bool) {
        switch stateMachine.currentState {
        case is GameSceneActiveState:
            if event == "buttonX" {
                // Speed up the player
                if pushedOn == true {
                    inputPushButtonPressed = true
                }
                if pushedOn == false {
                    inputPushButtonPressed = false
                }
            }
            if event == "dpad_left" {
                inputMovement.x = CGFloat(velocity) * -1
            }
            if event == "dpad_right" {
                inputMovement.x = CGFloat(velocity) * +1
            }
            if event == "Pause" {
                stateMachine.enterState(GameScenePausedState.self)
            }
        case is GameSceneFinishState:
            if event == "buttonA" {
                // Restart the game
                restartLevel()
            }
        case is GameScenePausedState:
            if event == "buttonA" {
                // Resume the game
                self.stateMachine.enterState(GameSceneActiveState.self)
            }
        default:
            break
        }
    }
    
    func stickEvent(event: String, point: CGPoint) {
        switch stateMachine.currentState {
        case is GameSceneActiveState:
            if event == "leftstick" {
                inputMovement = point
            }
            if event == "rightstick" {
                inputMovement = point
            }
        default:
            break
        }
    }


    // MARK: Game Loop
    
    override func update(currentTime: CFTimeInterval) {
        
        // Calculate delta time
        var deltaTime = currentTime - lastUpdateTimeInterval
        deltaTime = deltaTime > maximumUpdateDeltaTime ? maximumUpdateDeltaTime : deltaTime
        lastUpdateTimeInterval = currentTime

        //if scene.paused { return }
        
        // Player controls and camera
        if !(playerEntity.reachedFinishLine){
            if let playerMoveComponent = playerEntity.componentForClass(MoveComponent.self) {
                playerMoveComponent.movement = inputMovement
                playerMoveComponent.pushButton = inputPushButtonPressed
            }
        }
        if !(playerEntity.isCrashed || playerEntity.reachedFinishLine) {
            let newCameraPosition = CGPoint(x: 0, y: playerEntity.renderComponent.node.position.y + playerSettings.cameraOffset.y)
            centerCameraOnPoint(newCameraPosition)
        }
        
        // Update all components
        for componentSystem in componentSystems {
            componentSystem.updateWithDeltaTime(deltaTime)
        }
        
        // Update the GameScene's state machine
        stateMachine.updateWithDeltaTime(deltaTime)

        // Reset the inputPushButton press
        //inputPushButtonPressed = false
    }
    
    override func didFinishUpdate() {
        // Update score display
        if let scoreLabel = guiLayer.childNodeWithName("scoreLabel") as? SKLabelNode {
            scoreLabel.text = "\(playerEntity.score)"
        }
    }
    
    
    // MARK: Physics contact delegate
    
    func didBeginContact(contact: SKPhysicsContact) {
        if playerEntity.isCrashed || playerEntity.reachedFinishLine { return }
        
        let bodyA = contact.bodyA.node
        let bodyB = contact.bodyB.node
        //print("\(bodyA!.name!) hit \(bodyB!.name!)")
        
        // Did Player reach the finish line?
        if bodyA?.name == "finishNode" {
            if bodyB?.name == "playerNode" {
                playerEntity.reachedFinishLine = true
                stateMachine.enterState(GameSceneFinishState.self)
            }
        }
        // Did Player pass through a gate?
        if bodyA?.name == "gateNode" {
            if bodyB?.name == "playerNode" {
                if let gateEntity = (bodyA as? EntityNode)?.entity as? GateEntity {
                    gateEntity.stateComponent.stateMachine.enterState(GatePassedState.self)
                }
            }
        }
        // Did Player ran outside a gate?
        if bodyA?.name == "missedNode" {
            if bodyB?.name == "playerNode" {
                if let missedNode = bodyA as? MissedNode {
                    if let gateNode = missedNode.parent as? GateNode {
                        if let gateEntity = gateNode.entity {
                            gateEntity.stateComponent.stateMachine.enterState(GateRunOutsideState.self)
                            playerEntity.gateScoringMultiplier = gateSettings.minScoringMultiplier
                        }
                    }
                }
            }
        }
        // Did Player run over a post?
        if bodyA?.name == "postNode" {
            if bodyB?.name == "playerNode" {
                if let postNode = bodyA as? PostNode {
                    let gateNode = postNode.parent as! GateNode
                    if let gateEntity = gateNode.entity {
                        gateEntity.stateComponent.stateMachine.enterState(GateRunOverPostState.self)
                        postNode.displayCrookedPost()
                    }
                    playerEntity.gateScoringMultiplier = gateSettings.minScoringMultiplier
                }
            }
        }
        // Did Player hit an obstacle?
        if bodyA?.name == "obstacleNode" {
            if bodyB?.name == "playerNode" {
                playerEntity.isCrashed = true
                playerEntity.gateScoringMultiplier = gateSettings.minScoringMultiplier
            }
        }
    }
    
    func didEndContact(contact: SKPhysicsContact) {
        let bodyA = contact.bodyA.node
        let bodyB = contact.bodyB.node
        
        // Player did hit an obstacle
        if bodyA?.name == "obstacleNode" {
            if bodyB?.name == "playerNode" {
                // Remove the obstacle the player crashed into
                bodyA!.removeFromParent()
            }
        }
    
        // Player did pass a gate
        if bodyA?.name == "gateNode" {
            if bodyB?.name == "playerNode" {
                if let gateEntity = (bodyA as? EntityNode)?.entity as? GateEntity {
                    // Check if the gate is passed
                    if gateEntity.stateComponent.stateMachine.currentState is GatePassedState {
                        // Determine score to be awarded for this gate
                        let score = gateSettings.score * playerEntity.gateScoringMultiplier
                        
                        // Display the score in the gate
                        //gateEntity.didPassGate(score)
                        let gateNode = gateEntity.gateNode
                        gateNode.displayGateScore(score)
                        
                        // Award player with this core
                        playerEntity.score += score
                        
                        // Increase the scoring multiplier
                        if (playerEntity.gateScoringMultiplier <= gateSettings.maxScoringMultiplier) {
                            playerEntity.gateScoringMultiplier += 1
                        }
                    }
                }
            }
        }
    }
    
    // MARK: TileMap Delegate
    
    func createNodeOf(type type:tileType, location:CGPoint) {
        switch type {
        case .tileTree:
            addObstacle(ObstacleType.Tree, position: location)
            break
        case .tileRock:
            addObstacle(ObstacleType.Rock, position: location)
            break
        case .tileGate:
            addGate(location)
            break
        case .tileStart:
            addPlayer(location)
            break
        case .tileFinish:
            addFinish(location)
            break
        default:
            break
        }
    }
    
    func addPlayer(position: CGPoint) {
        // playerEntity is already defined as a property of this scene
        let playerNode = playerEntity.renderComponent.node
        playerNode.position = position
        playerNode.name = "playerNode"
        playerNode.zPosition = 10
        setPlayerConstraints()
        setCameraConstraints()
        addEntity(playerEntity)
    }
    
    func addObstacle(obstacleType: ObstacleType, position: CGPoint) {
        let obstacleEntity = ObstacleEntity(obstacleType: obstacleType)
        let obstacleNode = obstacleEntity.renderComponent.node
        obstacleNode.position = position
        obstacleNode.name = "obstacleNode"
        obstacleNode.zPosition = 50
        addEntity(obstacleEntity)
    }
    
    func addGate(position: CGPoint) {
        let gateEntity = GateEntity()
        let gateNode = gateEntity.renderComponent.node
        gateNode.position = position
        gateNode.name = "gateNode"
        addEntity(gateEntity)
    }
    
    func addFinish(position: CGPoint) {
        let atlasTiles = SKTextureAtlas(named: "world")
        let texture = atlasTiles.textureNamed("finish_192x64_00")
        texture.filteringMode = SKTextureFilteringMode.Nearest
        let node = SKSpriteNode(texture: texture)
        node.size = CGSize(width: 192, height: 64)
        node.position = position
        node.zPosition = 50
        node.name = "finishNode"
        node.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: 256, height: 32), center: CGPoint(x: 0, y: 64))
        node.physicsBody?.categoryBitMask = ColliderType.Finish.rawValue
        node.physicsBody?.contactTestBitMask = ColliderType.Player.rawValue
        node.physicsBody?.collisionBitMask = ColliderType.None.rawValue
        node.physicsBody?.dynamic = true
        worldLayer.addChild(node)
    }
    
    func addEntity(entity: GKEntity) {
        entities.insert(entity)
        
        for componentSystem in self.componentSystems {
            componentSystem.addComponentWithEntity(entity)
        }
        
        if let renderNode = entity.componentForClass(RenderComponent.self)?.node {
            worldLayer.addChild(renderNode)
        }
        
        if let stateComponent = entity.componentForClass(StateComponent.self) {
            stateComponent.enterInitialState()
        }
        
    }
    

    // MARK: Convenience
    
    func setupLevel() {
        worldGenerator.generateLevel(0)
        worldGenerator.createLevel()
        worldGenerator.presentLayerViaDelegate()
    }
    
    func restartLevel() {
        let newScene = GameScene(fileNamed:"GameScene")
        newScene!.scaleMode = .AspectFill
        let reveal = SKTransition.flipHorizontalWithDuration(0.5)
        self.view?.presentScene(newScene!, transition: reveal)
    }
    
    func createLabel(name: String, text: String, position: CGPoint, color: UIColor, alignment: SKLabelHorizontalAlignmentMode) -> SKLabelNode {
        let label = SKLabelNode(fontNamed: "Commodore-64-Pixelized")
        label.position = position
        label.fontColor = color
        label.horizontalAlignmentMode = alignment
        label.text = text.uppercaseString
        label.name = name
        label.zPosition = 1000
        return label
    }
    
    func centerCameraOnPoint(point: CGPoint) {
        if let camera = camera {
            camera.position = point
        }
    }
    
    private func setCameraConstraints() {
        guard let camera = camera else { return }
        
        // The camera will snap into a specific point horizontally, so that just enough of the world width is visible, plus a bit extra space on the right side for labels (score, time, etc.)
        let fixedHorizontalRange = SKRange(constantValue: ((size.width/2)*kScaleAmount) - 10)
        let playerHorizontalConstraint = SKConstraint.positionX(fixedHorizontalRange)
        
        // The camera will stop moving below the bottom of the world.
        let tilemapSize = worldGenerator.tilemapSize()
        let fixedVerticalRange = SKRange(lowerLimit: (tilemapSize.height * -1), upperLimit: 0)
        let playerVerticalConstraint = SKConstraint.positionY(fixedVerticalRange)
        
        camera.constraints = [playerHorizontalConstraint, playerVerticalConstraint]
    }
    
    private func setPlayerConstraints() {
        // Calculate the rightmost position a player can go
        let tilemapSize = worldGenerator.tilemapSize()
        let tileSize = worldGenerator.tileSize
        
        // We're taking one tileSize width off the entire width of the world, as a buffer
        let upperLimit: CGFloat = tilemapSize.width - tileSize.width
        playerEntity.renderComponent.node.constraints = [SKConstraint.positionX(SKRange(lowerLimit: 0, upperLimit: upperLimit))]
    }
}
