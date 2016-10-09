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
    var onScreenControlsLayer = SKNode()
    
    var entities = Set<GKEntity>()
    
    var scoreLabel = SKLabelNode()
    var timeLabel = SKLabelNode()
    
    var leftButton = ButtonNode(buttonType: ButtonType.left)
    var rightButton = ButtonNode(buttonType: ButtonType.right)
    var fastButton = ButtonNode(buttonType: ButtonType.fast)
    
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
    
    var inputMovement = CGPoint.zero
    var inputPushButtonPressed = false
    var beginTouchLocation = CGPoint.zero
    
    var lastUpdateTimeInterval: TimeInterval = 0
    let maximumUpdateDeltaTime: TimeInterval = 1.0 / 60.0
    var lastDeltaTime: TimeInterval = 0
    
    var score = 0
    var startTime = Date()
    var timeLimitSeconds = 60
    
    // Touch Debugging
    //let touchBox = SKSpriteNode(color: UIColor.redColor(), size: CGSize(width: 100, height: 100))
    
    // MARK: Life Cycle
    
    override func didMove(to view: SKView) {
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
        overlayLayer.addChild(onScreenControlsLayer)
        
        // Game Controllers
        GameController.sharedInstance.delegate = self
        
        // Add Labels
        scoreLabel = createLabel(name: "scoreLabel", text: "00", position: CGPoint(x: 480, y: 200), color: UIColor.black, alignment: .right)
        timeLabel = createLabel(name: "timeLabel", text: "00:00", position: CGPoint(x: 480, y: -60), color: UIColor.c64brownColor(), alignment: .right)
        
        guiLayer.addChild(createLabel(name: "scoreTitleLabel", text: "Score", position: CGPoint(x: 480, y: 230), color: UIColor.black, alignment: .right))
        guiLayer.addChild(scoreLabel)
        guiLayer.addChild(createLabel(name: "timeTitleLabel", text: "Time", position: CGPoint(x: 480, y: -30), color: UIColor.c64brownColor(), alignment: .right))
        guiLayer.addChild(timeLabel)
        
        // Add On-screen controls
        #if os(iOS)
            leftButton.node.position = CGPoint(x: controllerSettings.onScreenButtonLeftX, y: controllerSettings.onScreenButtonsY)
            rightButton.node.position = CGPoint(x: controllerSettings.onScreenButtonRightX, y: controllerSettings.onScreenButtonsY)
            fastButton.node.position = CGPoint(x: controllerSettings.onScreenButtonFastX, y: controllerSettings.onScreenButtonsY)
            guiLayer.addChild(leftButton.node)
            guiLayer.addChild(rightButton.node)
            guiLayer.addChild(fastButton.node)
        #endif
        
        // Touch debugging
        //addChild(touchBox)

        // Entering Gamestates
        stateMachine.enter(GameSceneInitialState.self)
    }
    
    
    // MARK: Touch handling delegate
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        switch stateMachine.currentState {
        case is GameSceneActiveState:
            // Control the player
            #if os(iOS)
                for touch in touches {
                    let positionInScene = touch.location(in: self)
                    let touchedNode = self.atPoint(positionInScene)
                    if touchedNode.name == ButtonType.left.rawValue {
                        inputMovement.x = -1
                        leftButton.showHighlighted()
                    }
                    if touchedNode.name == ButtonType.right.rawValue {
                        inputMovement.x = 1
                        rightButton.showHighlighted()
                    }
                    if touchedNode.name == ButtonType.fast.rawValue {
                        inputPushButtonPressed = true
                        fastButton.showHighlighted()
                    }
                }
            #endif
        case is GameSceneFinishState:
            // Restart the game
            restartLevel()
        
        case is GameScenePausedState:
            // Resume the game
            self.stateMachine.enter(GameSceneActiveState.self)
            
        default:
            break
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        #if os(iOS)
            for touch in touches {
                let positionInScene = touch.location(in: self)
                let touchedNode = self.atPoint(positionInScene)
                if touchedNode.name == ButtonType.left.rawValue {
                    inputMovement.x = -1
                    leftButton.showHighlighted()
                } else if touchedNode.name == ButtonType.right.rawValue {
                    inputMovement.x = 1
                    rightButton.showHighlighted()
                } else if touchedNode.name == ButtonType.fast.rawValue {
                    // Uncommenting this: If touches moved, it shouldn't affect the fast button (on/off)
                    //inputPushButtonPressed = true
                    fastButton.showHighlighted()
                } else {
                    inputMovement.x = 0
                }
            }
        #endif
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        #if os(iOS)
            for touch in touches {
                let positionInScene = touch.location(in: self)
                let touchedNode = self.atPoint(positionInScene)
                if touchedNode.name == ButtonType.left.rawValue {
                    inputMovement.x = 0
                    leftButton.showDefault()
                    rightButton.showDefault()
                } else if touchedNode.name == ButtonType.right.rawValue {
                    inputMovement.x = 0
                    rightButton.showDefault()
                    leftButton.showDefault()
                } else if touchedNode.name == ButtonType.fast.rawValue {
                    inputPushButtonPressed = false
                    fastButton.showDefault()
                } else {
                    leftButton.showDefault()
                    rightButton.showDefault()
                }
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
                stateMachine.enter(GameScenePausedState.self)
            }
        case is GameSceneFinishState:
            if event == "buttonA" {
                // Restart the game
                restartLevel()
            }
        case is GameScenePausedState:
            if event == "buttonA" {
                // Resume the game
                self.stateMachine.enter(GameSceneActiveState.self)
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
    
    override func update(_ currentTime: TimeInterval) {
        
        // Calculate delta time
        var deltaTime = currentTime - lastUpdateTimeInterval
        deltaTime = deltaTime > maximumUpdateDeltaTime ? maximumUpdateDeltaTime : deltaTime
        lastUpdateTimeInterval = currentTime

        //if scene.paused { return }  TODO: check if this can be removed
        
        // Player controls and camera
        //if let playerNode = worldLayer.childNodeWithName("playerNode") as? EntityNode {
        //    if let playerEntity = playerNode.entity as? PlayerEntity {
        //        if !(playerEntity.reachedFinishLine) {
        //            if let playerMoveComponent = playerEntity.componentForClass(MoveComponent.self) {
        //                playerMoveComponent.movement = inputMovement
        //                playerMoveComponent.pushButton = inputPushButtonPressed
        //            }
        //        }
        //    }
        //}
        // Player camera
        var highestY: CGFloat = 0.0
        for entity in entities where (entity.component(ofType: MoveComponent.self) != nil) {
            if entity.component(ofType: RenderComponent.self)!.node.position.y < highestY {
                highestY = entity.component(ofType: RenderComponent.self)!.node.position.y
            }
            entity.component(ofType: MoveComponent.self)!.movement = inputMovement
            entity.component(ofType: MoveComponent.self)!.pushButton = inputPushButtonPressed
        }
        let newCameraPosition = CGPoint(x: 0, y: highestY + playerSettings.cameraOffset.y)
        centerCameraOnPoint(point: newCameraPosition)
        
        //if let playerNode = worldLayer.childNodeWithName("playerNode") as? EntityNode {
        //    if let playerEntity = playerNode.entity as? PlayerEntity {
        //        let newCameraPosition = CGPoint(x: 0, y: playerEntity.renderComponent.node.position.y + playerSettings.cameraOffset.y)
        //        centerCameraOnPoint(newCameraPosition)
        //    }
        //}
        
        // Update all components
        for componentSystem in componentSystems {
            componentSystem.update(deltaTime: deltaTime)
        }
        
        // Update the GameScene's state machine
        stateMachine.update(deltaTime: deltaTime)

        // Reset the inputPushButton press
        //inputPushButtonPressed = false
    }
    
    override func didFinishUpdate() {
        // Update score display
        if let scoreLabel = guiLayer.childNode(withName: "scoreLabel") as? SKLabelNode {
            if let playerNode = worldLayer.childNode(withName: "playerNode") as? EntityNode {
                if let playerEntity = playerNode.parentEntity as? PlayerEntity {
                    scoreLabel.text = "\(playerEntity.score)"
            
                }
            }
        }
    }
    
    
    // MARK: Physics contact delegate
    
    func didBegin(_ contact: SKPhysicsContact) {
        //if playerEntity.isCrashed || playerEntity.reachedFinishLine { return }
        
        let bodyA = contact.bodyA.node
        let bodyB = contact.bodyB.node
        //print("\(bodyA!.name!) hit \(bodyB!.name!)")
        
        // Did Player reach the finish line?
        if bodyA?.name == "finishNode" {
            if bodyB?.name == "playerNode" {
                if let playerNode = bodyB as? EntityNode {
                    if let playerEntity = playerNode.parentEntity as? PlayerEntity {
                        
                        playerEntity.reachedFinishLine = true
                        stateMachine.enter(GameSceneFinishState.self)
                    }
                }
            }
        }
        // Did Player pass through a gate?
        if bodyA?.name == "gateNode" {
            if bodyB?.name == "playerNode" {
                if let gateEntity = (bodyA as? EntityNode)?.parentEntity as? GateEntity {
                    gateEntity.stateComponent.stateMachine.enter(GatePassedState.self)
                }
            }
        }
        // Did Player ran outside a gate?
        if bodyA?.name == "missedNode" {
            if bodyB?.name == "playerNode" {
                if let playerNode = bodyB as? EntityNode {
                    if let playerEntity = playerNode.parentEntity as? PlayerEntity {

                        if let missedNode = bodyA as? MissedNode {
                            if let gateNode = missedNode.parent as? GateNode {
                                if let gateEntity = gateNode.parentEntity {
                                    gateEntity.stateComponent.stateMachine.enter(GateRunOutsideState.self)
                                    playerEntity.gateScoringMultiplier = gateSettings.minScoringMultiplier
                                }
                            }
                        }
                    }
                }
            }
        }
        // Did Player run over a post?
        if bodyA?.name == "postNode" {
            if bodyB?.name == "playerNode" {
                if let playerNode = bodyB as? EntityNode {
                    if let playerEntity = playerNode.parentEntity as? PlayerEntity {
                        if let postNode = bodyA as? PostNode {
                            let gateNode = postNode.parent as! GateNode
                            if let gateEntity = gateNode.parentEntity {
                                gateEntity.stateComponent.stateMachine.enter(GateRunOverPostState.self)
                                postNode.displayCrookedPost()
                            }
                            playerEntity.gateScoringMultiplier = gateSettings.minScoringMultiplier
                        }
                    }
                }
            }
        }
        // Did Player hit an obstacle?
        if bodyA?.name == "obstacleNode" {
            if bodyB?.name == "playerNode" {
                if let playerNode = bodyB as? EntityNode {
                    if let playerEntity = playerNode.parentEntity as? PlayerEntity {
                        playerEntity.isCrashed = true
                        playerEntity.gateScoringMultiplier = gateSettings.minScoringMultiplier
                    }
                }
            }
        }
    }
    
    func didEnd(_ contact: SKPhysicsContact) {
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
                if let playerNode = bodyB as? EntityNode {
                    if let playerEntity = playerNode.parentEntity as? PlayerEntity {
                        if let gateEntity = (bodyA as? EntityNode)?.parentEntity as? GateEntity {
                            // Check if the gate is passed
                            if gateEntity.stateComponent.stateMachine.currentState is GatePassedState {
                                // Determine score to be awarded for this gate
                                let score = gateSettings.score * playerEntity.gateScoringMultiplier
                                
                                // Display the score in the gate
                                //gateEntity.didPassGate(score)
                                let gateNode = gateEntity.gateNode
                                gateNode?.displayGateScore(score: score)
                                
                                // Award player with this score
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
        }
    }
    
    // MARK: TileMap Delegate
    
    func createNodeOf(type:tileType, location:CGPoint) {
        switch type {
        case .tileTree:
            addObstacle(obstacleType: ObstacleType.Tree, position: location)
            break
        case .tileRock:
            addObstacle(obstacleType: ObstacleType.Rock, position: location)
            break
        case .tileGate:
            addGate(position: location)
            break
        case .tileStart:
            addPlayer(position: location)
            break
        case .tileFinish:
            addFinish(position: location)
            break
        case .tileOpponent:
            addPlayer(position: location)
            break
        default:
            break
        }
    }
    
    func addPlayer(position: CGPoint) {
        let entity = PlayerEntity()
        let node = entity.renderComponent.node
        node.position = position
        node.name = "playerNode"
        node.zPosition = 10
        setPlayerConstraints(entity: entity)
        setCameraConstraints()
        addEntity(entity: entity)
    }
    
    func addObstacle(obstacleType: ObstacleType, position: CGPoint) {
        let obstacleEntity = ObstacleEntity(obstacleType: obstacleType)
        let obstacleNode = obstacleEntity.renderComponent.node
        obstacleNode.position = position
        obstacleNode.name = "obstacleNode"
        obstacleNode.zPosition = 50
        addEntity(entity: obstacleEntity)
    }
    
    func addGate(position: CGPoint) {
        let gateEntity = GateEntity()
        let gateNode = gateEntity.renderComponent.node
        gateNode.position = position
        gateNode.name = "gateNode"
        addEntity(entity: gateEntity)
    }
    
    func addFinish(position: CGPoint) {
        let atlasTiles = SKTextureAtlas(named: "world")
        let texture = atlasTiles.textureNamed("finish_192x64_00")
        texture.filteringMode = SKTextureFilteringMode.nearest
        let node = SKSpriteNode(texture: texture)
        node.size = CGSize(width: 192, height: 96)
        node.position = position
        node.zPosition = 50
        node.name = "finishNode"
        node.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 256, height: 32), center: CGPoint(x: 0, y: 64))
        node.physicsBody?.categoryBitMask = ColliderType.finish.rawValue
        node.physicsBody?.contactTestBitMask = ColliderType.player.rawValue
        node.physicsBody?.collisionBitMask = ColliderType.none.rawValue
        node.physicsBody?.isDynamic = true
        worldLayer.addChild(node)
    }
    
    func addEntity(entity: GKEntity) {
        entities.insert(entity)
        
        for componentSystem in self.componentSystems {
            componentSystem.addComponent(foundIn: entity)
        }
        
        if let renderNode = entity.component(ofType: RenderComponent.self)?.node {
            worldLayer.addChild(renderNode)
        }
        
        if let stateComponent = entity.component(ofType: StateComponent.self) {
            stateComponent.enterInitialState()
        }
        
    }
    

    // MARK: Convenience
    
    func setupLevel() {
        worldGenerator.generateLevel(defaultValue: 0)
        worldGenerator.createLevel()
        worldGenerator.presentLayerViaDelegate()
    }
    
    func restartLevel() {
        let newScene = GameScene(fileNamed:"GameScene")
        newScene!.scaleMode = .aspectFill
        let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
        self.view?.presentScene(newScene!, transition: reveal)
    }
    
    func createLabel(name: String, text: String, position: CGPoint, color: UIColor, alignment: SKLabelHorizontalAlignmentMode) -> SKLabelNode {
        let label = SKLabelNode(fontNamed: "Commodore-64-Pixelized")
        label.position = position
        label.fontColor = color
        label.horizontalAlignmentMode = alignment
        label.text = text.uppercased()
        label.name = name
        label.zPosition = 1000
        return label
    }
    
    func getButtonTexture(textureName: String) -> SKTexture {
        // Configure new texture
        let atlas = SKTextureAtlas(named: "controls")
        let defaultTexture = atlas.textureNamed(textureName)
        defaultTexture.filteringMode = SKTextureFilteringMode.nearest
        return defaultTexture
    }
    
    func centerCameraOnPoint(point: CGPoint) {
        if let camera = camera {
            camera.position = point
        }
    }
    
    fileprivate func setCameraConstraints() {
        guard let camera = camera else { return }
        
        // The camera will snap into a specific point horizontally, so that just enough of the world width is visible, plus a bit extra space on the right side for labels (score, time, etc.)
        let fixedHorizontalRange = SKRange(constantValue: ((size.width/2)*kScaleAmount) - 10)
        let playerHorizontalConstraint = SKConstraint.positionX(fixedHorizontalRange)
        
        // The camera will stop moving below the bottom of the world.
        let tilemapSize = worldGenerator.tilemapSize()
        let fixedVerticalRange = SKRange(lowerLimit: (tilemapSize.height * -1) + 90, upperLimit: 0) // plus 90
        let playerVerticalConstraint = SKConstraint.positionY(fixedVerticalRange)
        
        camera.constraints = [playerHorizontalConstraint, playerVerticalConstraint]
    }
    
    fileprivate func setPlayerConstraints(entity: PlayerEntity) {
        // Calculate the rightmost position a player can go
        let tilemapSize = worldGenerator.tilemapSize()
        let tileSize = worldGenerator.tileSize
        
        // We're taking one tileSize width off the entire width of the world, as a buffer
        let upperLimit: CGFloat = tilemapSize.width - tileSize.width
        entity.renderComponent.node.constraints = [SKConstraint.positionX(SKRange(lowerLimit: 0, upperLimit: upperLimit))]
    }
}
