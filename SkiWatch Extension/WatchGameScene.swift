//
//  WatchGameScene.swift
//  Ski
//
//  Created by Ralf Tappmeyer on 10/26/16.
//  Copyright © 2016 Ralf Tappmeyer. All rights reserved.
//

import SpriteKit

let kScaleAmount: CGFloat = 1.0

class WatchGameScene: SKScene, tileMapDelegate {
    // MARK: Properties
    
    var level: Int
    var timeLimit: TimeInterval
    
    var worldGenerator = tileMap()
    var worldLayer = SKNode()
    var guiLayer = SKNode()
    var overlayLayer = SKNode()

    var scoreLabel = SKLabelNode()
    var timeLabel = SKLabelNode()
    
    var lastUpdateTimeInterval: TimeInterval = 0
    let maximumUpdateDeltaTime: TimeInterval = 1.0 / 60.0
    var lastDeltaTime: TimeInterval = 0

    var playerNode = PlayerNode()
    var score = 0
    var movement = CGPoint.zero
    
    // Debaug
    var testAnimation: SKAction!
    
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
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
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
        backgroundColor = UIColor.white
        addChild(worldLayer)
        camera!.addChild(guiLayer)
        guiLayer.addChild(overlayLayer)

        // Add Labels
        scoreLabel = createLabel(name: "scoreLabel", text: "00", position: CGPoint(x: 480, y: 200), color: UIColor.black, alignment: .right)
        timeLabel = createLabel(name: "timeLabel", text: "00:00", position: CGPoint(x: 480, y: -60), color: UIColor.c64brownColor(), alignment: .right)
        
        guiLayer.addChild(createLabel(name: "scoreTitleLabel", text: "Score", position: CGPoint(x: 480, y: 230), color: UIColor.black, alignment: .right))
        guiLayer.addChild(scoreLabel)
        guiLayer.addChild(createLabel(name: "timeTitleLabel", text: "Time", position: CGPoint(x: 480, y: -30), color: UIColor.c64brownColor(), alignment: .right))
        guiLayer.addChild(timeLabel)

        setupLevel()
        
//        let timePerFrame = TimeInterval(1.0 / 4.0) // 0.25ms
//        let atlas = SKTextureAtlas(named: "player")
//        let defaultTexture = atlas.textureNamed("left__00.png")
//        let testAnimation = SKAction.animate(with: [defaultTexture], timePerFrame: timePerFrame, resize: true, restore: false)
//        playerNode.run(testAnimation)
//        
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
        playerNode.position = position
        playerNode.name = "playerNode"
        playerNode.zPosition = 10
        worldLayer.addChild(playerNode)
    }
    
    func addObstacle(obstacleType: ObstacleType, position: CGPoint) {
        let obstacleNode = ObstacleNode(obstacleType: obstacleType)
        obstacleNode.position = position
        obstacleNode.name = "obstacleNode"
        obstacleNode.zPosition = 50
        worldLayer.addChild(obstacleNode)
    }
    
    func addGate(position: CGPoint) {
        let gateNode = GateNode()
        gateNode.position = position
        gateNode.name = "gateNode"
        worldLayer.addChild(gateNode)
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
    
    // MARK: Game Loop
    
    override func update(_ currentTime: TimeInterval) {
        // Calculate delta time
        var deltaTime = currentTime - lastUpdateTimeInterval
        deltaTime = deltaTime > maximumUpdateDeltaTime ? maximumUpdateDeltaTime : deltaTime
        lastUpdateTimeInterval = currentTime
        
        // Player camera
        //let newCameraPosition = CGPoint(x: 0, y: playerNode.position.y + playerSettings.cameraOffset.y)
        //centerCameraOnPoint(point: newCameraPosition)
        
        // Player movement
        if playerNode.isCrashed { return }  // No updates if player is crashed
        let xMovement = ((movement.x * CGFloat(deltaTime)) * playerSettings.movementSpeed)
        let yMovement = ((playerSettings.downhillSpeedMin / -100 * CGFloat(deltaTime)) * playerSettings.movementSpeed)
        playerNode.position = CGPoint(x: playerNode.position.x + xMovement, y: playerNode.position.y + yMovement)
        
        // Player animation
        if movement.x < -0.1 {
            if playerNode.currentAnimationState != nil && playerNode.currentAnimationState! == .left { return}
            runAnimation(node: playerNode.spriteNode, animation: playerNode.animations[.left]!)
            playerNode.currentAnimationState = .left
        } else if movement.x > 0.1 {
            if playerNode.currentAnimationState != nil && playerNode.currentAnimationState! == .right { return}
            runAnimation(node: playerNode.spriteNode, animation: playerNode.animations[.right]!)
            playerNode.currentAnimationState = .right
        } else {
            if playerNode.currentAnimationState != nil && playerNode.currentAnimationState! == .idle { return}
            runAnimation(node: playerNode.spriteNode, animation: playerNode.animations[.idle]!)
            playerNode.currentAnimationState = .idle
        }
        
        movement = CGPoint.zero
    }
    
    override func didFinishUpdate() {
        // Update score display
        if let scoreLabel = guiLayer.childNode(withName: "scoreLabel") as? SKLabelNode {
            scoreLabel.text = "\(score)"
        }
    }
    
    
    // MARK: Convenience
    
    func setupLevel() {
        worldGenerator.generateLevel(defaultValue: 0)
        worldGenerator.createLevel(level: self.level)
        worldGenerator.presentLayerViaDelegate()
        setPlayerConstraints()
        setCameraConstraints()
        
        // Play Initial Sound
        worldLayer.run(SKAction.playSoundFileNamed("Skiier_Start.m4a", waitForCompletion: false))
    }
    
    func createLabel(name: String, text: String, position: CGPoint, color: UIColor, alignment: SKLabelHorizontalAlignmentMode) -> SKLabelNode {
        //let label = SKLabelNode(fontNamed: "Commodore-64-Pixelized")
        let label = SKLabelNode()
        label.fontName = "Helvetica"
        label.position = position
        label.fontColor = color
        label.horizontalAlignmentMode = alignment
        label.text = text.uppercased()
        label.name = name
        label.zPosition = 1000
        return label
    }
    
    func runAnimation(node: SKNode, animation: Animation) {
        let actionKey = "Animation"
        let timePerFrame = TimeInterval(1.0 / 4.0) // 0.25ms

        node.removeAction(forKey: actionKey)
        let texturesAction: SKAction
        if animation.repeatTexturesForever {
            texturesAction = SKAction.repeatForever(SKAction.animate(with: animation.textures, timePerFrame: timePerFrame, resize: true, restore: true))
        } else {
            texturesAction = SKAction.animate(with: animation.textures, timePerFrame: timePerFrame, resize: true, restore: false)
        }
        node.run(texturesAction, withKey: actionKey)
    }
    
    func centerCameraOnPoint(point: CGPoint) {
        if let camera = camera {
            camera.position = point
        }
    }
    
    fileprivate func setCameraConstraints() {
        guard let camera = camera else { return }
        
        // Stay close to the player
        let zeroRange = SKRange(constantValue: 0.0)
        let playerLocationConstraint = SKConstraint.distance(zeroRange, to: playerNode)
        
        // Stay within the slope
        let scaledSize = CGSize(width: size.width * camera.xScale, height: size.height * camera.yScale)
        let worldContentRect = worldLayer.calculateAccumulatedFrame()
        print("width=\(worldContentRect.width) and height=\(worldContentRect.height)")
        let xInset = min((scaledSize.width / 2) - 20.0, worldContentRect.width / 2)
        let yInset = min((scaledSize.height / 2) - 20.0, worldContentRect.height / 2)
        let insetContentRect = worldContentRect.insetBy(dx: xInset, dy: yInset)
        let xRange = SKRange(lowerLimit: insetContentRect.minX, upperLimit: insetContentRect.maxX)
        let yRange = SKRange(lowerLimit: insetContentRect.minY, upperLimit: insetContentRect.maxY)
        let levelEdgeConstraint = SKConstraint.positionX(xRange, y: yRange)
        levelEdgeConstraint.referenceNode = worldLayer

        //let fixedHorizontalRange = SKRange(constantValue: ((size.width/2) * kScaleAmount)-10)
        //let fixedHorizontalRange = SKRange(lowerLimit: (size.width/2)-20, upperLimit: (size.width/2)+20)
        //let playerHorizontalConstraint = SKConstraint.positionX(fixedHorizontalRange)
        
        // The camera will stop moving below the bottom of the world.
        //let tilemapSize = worldGenerator.tilemapSize()
        //let fixedVerticalRange = SKRange(lowerLimit: (tilemapSize.height * -1) + 90, upperLimit: 0) // plus 90
        //let playerVerticalConstraint = SKConstraint.positionY(fixedVerticalRange)
        
        camera.constraints = [playerLocationConstraint, levelEdgeConstraint]
    }
    
    fileprivate func setPlayerConstraints() {
        // Calculate the rightmost position a player can go
        let tilemapSize = worldGenerator.tilemapSize()
        let tileSize = worldGenerator.tileSize
        
        // We're taking one tileSize width off the entire width of the world, as a buffer
        let upperLimit: CGFloat = tilemapSize.width - tileSize.width
        playerNode.constraints = [SKConstraint.positionX(SKRange(lowerLimit: 0, upperLimit: upperLimit))]
    }
}

extension WatchGameScene: SKPhysicsContactDelegate {
    
}
