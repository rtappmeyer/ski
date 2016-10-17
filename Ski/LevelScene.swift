//
//  LevelScene.swift
//  Ski
//
//  Created by Ralf Tappmeyer on 4/9/16.
//  Copyright (c) 2016 Ralf Tappmeyer. All rights reserved.
//

import SpriteKit
import GameplayKit

class LevelScene: BaseScene, tileMapDelegate {
    // MARK: Properties
    
    var level: Int
    var timeLimit: TimeInterval
    
    var worldGenerator = tileMap()
    var worldLayer = SKNode()

    var playerEntities = Set<GKEntity>()
    var entities = Set<GKEntity>()
    
    var leftButton = ButtonNode(buttonType: ButtonType.left)
    var rightButton = ButtonNode(buttonType: ButtonType.right)
    var fastButton = ButtonNode(buttonType: ButtonType.fast)
    
    lazy var stateMachine: GKStateMachine = GKStateMachine(states: [
        LevelSceneInitialState(scene: self),
        LevelSceneActiveState(scene: self),
        LevelScenePausedState(scene: self),
        LevelSceneFinishState(scene: self)
        ])
    
    lazy var componentSystems: [GKComponentSystem] = {
        let moveSystem = GKComponentSystem(componentClass: MoveComponent.self)
        let animationSystem = GKComponentSystem(componentClass: AnimationComponent.self)
        let stateSystem = GKComponentSystem(componentClass: StateComponent.self)
        return [moveSystem, animationSystem, stateSystem]
    }()
    
    var inputMovement = CGPoint.zero
    var inputPushButtonPressed = false
    
    var startTime = Date()
    
    // MARK: Initialization
    
    init(size: CGSize, level: Int ) {
        if level <= levelSettings.levels.count {
            print("Initializing Level:")
            self.timeLimit = levelSettings.levels[level-1].timeLimit
            self.level = level
            print("Level=\(self.level)")
            print("Timelimit=\(self.timeLimit)")
        } else {
            print("WARNING Level data does not exist! Moving back to level 1.")
            self.level = 1
            self.timeLimit = levelSettings.levels[0].timeLimit
        }

        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Life Cycle
    
    override func didMove(to view: SKView) {

        // Delegates
        worldGenerator.delegate = self
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = CGVector.zero
        
        // Config World
        setupBackgroundColor()
        setupCamera()
        addChild(worldLayer)
        
        // Game Controllers
        GameController.sharedInstance.delegate = self
        
        addScoreAndTimeLabels()
        
        // Add On-screen controls
        #if os(iOS)
            leftButton.node.position = CGPoint(x: controllerSettings.onScreenButtonLeftX, y: controllerSettings.onScreenButtonsY)
            rightButton.node.position = CGPoint(x: controllerSettings.onScreenButtonRightX, y: controllerSettings.onScreenButtonsY)
            fastButton.node.position = CGPoint(x: controllerSettings.onScreenButtonFastX, y: controllerSettings.onScreenButtonsY)
            onScreenControlsLayer.addChild(leftButton.node)
            onScreenControlsLayer.addChild(rightButton.node)
            onScreenControlsLayer.addChild(fastButton.node)
        #endif

        setupLevel()
        
        // Make sure to start off with a score of 0 when playing the first level
        if self.level == 1 {
            for entity in playerEntities {
                (entity as! PlayerEntity).resetScoreToZero()
            }
        }
        
        // Entering Gamestates
        stateMachine.enter(LevelSceneInitialState.self)
    }
    
    // MARK: Touch handling
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        switch stateMachine.currentState {
        case is LevelSceneActiveState:
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
        case is LevelSceneFinishState:
            // Restart the game
            print("starting level \(self.level)")
            let newScene = LevelScene(size: kSize, level: self.level)
            newScene.scaleMode = .aspectFill
            let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
            self.view?.presentScene(newScene, transition: reveal)
            
        case is LevelScenePausedState:
            // Resume the game
            self.stateMachine.enter(LevelSceneActiveState.self)
            
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

    // MARK: Game Loop
    override func update(_ currentTime: TimeInterval) {
        
        // Calculate delta time
        var deltaTime = currentTime - lastUpdateTimeInterval
        deltaTime = deltaTime > maximumUpdateDeltaTime ? maximumUpdateDeltaTime : deltaTime
        lastUpdateTimeInterval = currentTime
        
        // Player clock
        if stateMachine.currentState is LevelSceneActiveState {
            for entity in playerEntities {
                (entity as! PlayerEntity).elapsedTime += deltaTime      // TODO: Multiplayer
            }
        }

        // Player camera
        var highestY: CGFloat = 0.0
        for entity in playerEntities {
            if entity.component(ofType: RenderComponent.self)!.node.position.y < highestY {             // TODO: Multiplayer
                highestY = entity.component(ofType: RenderComponent.self)!.node.position.y
                if !(entity as! PlayerEntity).reachedFinishLine {
                    entity.component(ofType: MoveComponent.self)!.movement = inputMovement
                    entity.component(ofType: MoveComponent.self)!.pushButton = inputPushButtonPressed
                }
            }
        }
        
        let newCameraPosition = CGPoint(x: 0, y: highestY + playerSettings.cameraOffset.y)
        centerCameraOnPoint(point: newCameraPosition)
        
        // Update all components
        for componentSystem in componentSystems {
            componentSystem.update(deltaTime: deltaTime)
        }
        
        // Update the GameScene's state machine
        stateMachine.update(deltaTime: deltaTime)

    }
    
    override func didFinishUpdate() {
        // Update score & time display
        for entity in playerEntities {
            scoreLabel.text = "\((entity as! PlayerEntity).score)"                      // TODO: Multiplayer
            var components = DateComponents()
            components.second = Int(max(0.0, (entity as! PlayerEntity).elapsedTime))
            timeLabel.text = "\(elapsedTimeFormatter.string(from: components)!)"
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
        let entity = PlayerEntity(playerId: 1)      // TODO: Multiplayer: Somewhere we'll have to count the players in the level
        let node = entity.renderComponent.node
        node.position = position
        node.name = "playerNode"
        node.zPosition = 10
        setPlayerConstraints(entity: entity)
        setCameraConstraints()
        addEntity(entity: entity)
        playerEntities.insert(entity)
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
        worldGenerator.createLevel(level: self.level)
        worldGenerator.presentLayerViaDelegate()
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


// MARK: - SKPhysicsContact Delegate

extension LevelScene: SKPhysicsContactDelegate {
    
    func didBegin(_ contact: SKPhysicsContact) {
        let bodyA = contact.bodyA.node
        let bodyB = contact.bodyB.node
        //print("\(bodyA!.name!) hit \(bodyB!.name!)")
        
        // Did Player reach the finish line?
        if bodyA?.name == "finishNode" {
            if bodyB?.name == "playerNode" {
                // Start the finish sequence
                let playerEntity = (bodyB as! EntityNode).parentEntity as! PlayerEntity
                playerEntity.reachedFinishLine = true
                stateMachine.enter(LevelSceneFinishState.self)  // TODO: Multiplayer only go here if all players reached the finishline
            }
        }
        // Did Player pass through a gate?
        if bodyA?.name == "gateNode" {
            if bodyB?.name == "playerNode" {
                // Gate successfully passed
                let gateEntity = (bodyA as! EntityNode).parentEntity as! GateEntity
                gateEntity.stateComponent.stateMachine.enter(GatePassedState.self)
                print("Gate: Passed")
            }
        }
        // Did Player run outside a gate?
        if bodyA?.name == "missedNode" {
            if bodyB?.name == "playerNode" {
                // Mark this gate as missed and reset scoring multiplier
                let gateEntity = ((bodyA as! MissedNode).parent as! GateNode).parentEntity as GateEntity
                gateEntity.stateComponent.stateMachine.enter(GateRunOutsideState.self)
                let playerEntity = (bodyB as! EntityNode).parentEntity as! PlayerEntity
                playerEntity.gateScoringMultiplier = gateSettings.minScoringMultiplier
                print("Gate: Missed")
            }
        }
        // Did Player run over a post?
        if bodyA?.name == "postNode" {
            if bodyB?.name == "playerNode" {
                // Mark this gate as missed, display crooked post, and reset scoring multiplier
                let playerEntity = (bodyB as! EntityNode).parentEntity as! PlayerEntity
                playerEntity.gateScoringMultiplier = gateSettings.minScoringMultiplier
                let gateEntity = ((bodyA as! PostNode).parent as! GateNode).parentEntity as GateEntity
                gateEntity.stateComponent.stateMachine.enter(GateRunOverPostState.self)
                let postNode = bodyA as! PostNode
                postNode.displayCrookedPost()
                print("Gate: Missed (run over)")
            }
        }
        // Did Player hit an obstacle?
        if bodyA?.name == "obstacleNode" {
            if bodyB?.name == "playerNode" {
                // Player crashes and reset scoring multiplier
                let playerEntity = (bodyB as! EntityNode).parentEntity as! PlayerEntity
                playerEntity.isCrashed = true
                playerEntity.gateScoringMultiplier = gateSettings.minScoringMultiplier
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
        
        // Player moved past a gate
        if bodyA?.name == "gateNode" {
            if bodyB?.name == "playerNode" {
                // After contact with the gate ends, check if gate's passed and calculate and display the score and it's multiplier. If player missed the gate, we're adding penalty time
                let gateEntity = (bodyA as! EntityNode).parentEntity as! GateEntity
                let playerEntity = (bodyB as! EntityNode).parentEntity as! PlayerEntity
                // Was this gate successfully passed? (The statemachine will tell us)
                if gateEntity.stateComponent.stateMachine.currentState is GatePassedState {
                    print("Gate: Past as good")
                    // Determine the player's gate scoring multiplier
                    let score = gateSettings.score * playerEntity.gateScoringMultiplier
                    // Display the score in the gate
                    gateEntity.gateNode.displayGateScore(score: score)
                    // Award player with this score
                    playerEntity.incrementScore(increment: score)
                    // Increase the scoring multiplier
                    if (playerEntity.gateScoringMultiplier <= gateSettings.maxScoringMultiplier) {
                        playerEntity.gateScoringMultiplier += 1
                    }
                } else {
                    print("Gate: Past as not good")
                    // Add penalty time to player's clock
                    playerEntity.elapsedTime += gateSettings.missedGateTimePenalty
                }
            }
        }
    }
}


// MARK: GameController handling delegate

extension LevelScene: GameControllerDelegate {
    
    func buttonEvent(event: String, velocity: Float, pushedOn: Bool) {
        switch stateMachine.currentState {
        case is LevelSceneActiveState:
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
                stateMachine.enter(LevelScenePausedState.self)
            }
        case is LevelSceneFinishState:
            if event == "buttonA" {
                // Restart the game
                self.stateMachine.enter(LevelSceneInitialState.self)
            }
        case is LevelScenePausedState:
            if event == "buttonA" {
                // Resume the game
                self.stateMachine.enter(LevelSceneActiveState.self)
            }
        default:
            break
        }
    }
    
    func stickEvent(event: String, point: CGPoint) {
        switch stateMachine.currentState {
        case is LevelSceneActiveState:
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

}

