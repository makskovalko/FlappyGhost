//
//  GameScene.swift
//  FlappyClone
//
//  Created by Maxim Kovalko on 11.06.16.
//  Copyright (c) 2016 Maxim Kovalko. All rights reserved.
//

import SpriteKit

enum PhysicsCategory {
    static let Ghost: UInt32 = 0x1 << 1
    static let Ground: UInt32 = 0x1 << 2
    static let Wall: UInt32 = 0x1 << 3
    static let Score: UInt32 = 0x1 << 4
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var ground = SKSpriteNode()
    var ghost = SKSpriteNode()
    var wallPair = SKNode()
    var moveAndRemove = SKAction()
    var gameStarted = Bool()
    var score = Int()
    var scoreLabel  = SKLabelNode()
    var died = Bool()
    var restartButton = SKSpriteNode()
    
    func restartScene() {
        self.removeAllChildren()
        self.removeAllActions()
        died = false
        gameStarted = false
        score = 0
        createScene()
    }
    
    func createScene() {
        self.physicsWorld.contactDelegate = self
        
        for i in 0..<2 {
            let background = SKSpriteNode(imageNamed: "Background")
            background.anchorPoint = CGPointZero
            background.position = CGPoint(x: CGFloat (i) * self.frame.width, y: 0)
            background.name = "background"
            background.size = (self.view?.bounds.size)!
            self.addChild(background)
        }
        
        scoreLabel.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2 + self.frame.height / 2.5)
        scoreLabel.text = "\(score)"
        scoreLabel.fontName = "04b_19"
        scoreLabel.fontSize = 60
        scoreLabel.zPosition = 5
        self.addChild(scoreLabel)
        
        ground = SKSpriteNode(imageNamed: "Ground")
        ground.setScale(0.5)
        ground.position = CGPoint(x: self.frame.width / 2, y: ground.frame.height / 2)
        
        ground.physicsBody = SKPhysicsBody(rectangleOfSize: ground.size)
        ground.physicsBody?.categoryBitMask = PhysicsCategory.Ground
        ground.physicsBody?.collisionBitMask = PhysicsCategory.Ghost
        ground.physicsBody?.contactTestBitMask = PhysicsCategory.Ghost
        ground.physicsBody?.affectedByGravity = false
        ground.physicsBody?.dynamic = false
        ground.zPosition = 3
        
        self.addChild(ground)
        
        ghost = SKSpriteNode(imageNamed: "Ghost")
        ghost.size = CGSize(width: 60, height: 70)
        ghost.position = CGPoint(x: self.frame.width / 2 - ghost.frame.width, y: self.frame.height / 2)
        
        ghost.physicsBody = SKPhysicsBody(circleOfRadius: ghost.frame.height / 2)
        ghost.physicsBody?.categoryBitMask = PhysicsCategory.Ghost
        ghost.physicsBody?.collisionBitMask = PhysicsCategory.Ground | PhysicsCategory.Wall
        ghost.physicsBody?.contactTestBitMask = PhysicsCategory.Ground | PhysicsCategory.Wall | PhysicsCategory.Score
        ghost.physicsBody?.affectedByGravity = false
        ghost.physicsBody?.dynamic = true
        ghost.zPosition = 2
        
        self.addChild(ghost)
    }
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        createScene()
    }
    
    func createButton() {
        restartButton = SKSpriteNode(imageNamed: "RestartBtn")
        restartButton.size = CGSize(width: 200, height: 100)
        restartButton.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2)
        restartButton.zPosition = 6
        restartButton.setScale(0)
        self.addChild(restartButton)
        restartButton.runAction(SKAction.scaleTo(1.0, duration: 0.3))
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        let firstBody = contact.bodyA
        let secondBody = contact.bodyB
        
        //Collision with walls
        if firstBody.categoryBitMask == PhysicsCategory.Ghost && secondBody.categoryBitMask == PhysicsCategory.Wall ||
            secondBody.categoryBitMask == PhysicsCategory.Ghost && firstBody.categoryBitMask == PhysicsCategory.Wall {
            
            enumerateChildNodesWithName("wallPair", usingBlock: { (node, error) in
                node.speed = 0
                self.removeAllActions()
            })
            
            if died == false {
                died = true
                createButton()
            }
        }
        
        //Collision with ground
        if firstBody.categoryBitMask == PhysicsCategory.Ghost && secondBody.categoryBitMask == PhysicsCategory.Ground ||
            secondBody.categoryBitMask == PhysicsCategory.Ghost && firstBody.categoryBitMask == PhysicsCategory.Ground {
            
            enumerateChildNodesWithName("wallPair", usingBlock: { (node, error) in
                node.speed = 0
                self.removeAllActions()
            })
            
            if died == false {
                died = true
                createButton()
            }
        }
        
        //Collision with coins
        if firstBody.categoryBitMask == PhysicsCategory.Ghost && secondBody.categoryBitMask == PhysicsCategory.Score {
            score += 1
            scoreLabel.text = "\(score)"
            secondBody.node?.removeFromParent()
        }
        if firstBody.categoryBitMask == PhysicsCategory.Score && secondBody.categoryBitMask == PhysicsCategory.Ghost {
            score += 1
            scoreLabel.text = "\(score)"
            firstBody.node?.removeFromParent()
        }
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if (gameStarted == false) {
            gameStarted = true
            
            ghost.physicsBody?.affectedByGravity = true
            
            let spawn = SKAction.runBlock {
                self.createWalls()
            }
            
            let delay = SKAction.waitForDuration(2.0)
            
            let spawnDelay = SKAction.sequence([spawn, delay])
            let spawnDelayForever = SKAction.repeatActionForever(spawnDelay)
            
            self.runAction(spawnDelayForever)
            
            let distance = CGFloat(self.frame.width + wallPair.frame.width)
            let movePipes = SKAction.moveByX(-distance -  50, y: 0, duration: NSTimeInterval(0.01 * distance))
            let removePipes = SKAction.removeFromParent()
            
            moveAndRemove = SKAction.sequence([movePipes, removePipes])
            
            ghost.physicsBody?.velocity = CGVectorMake(0, 0)
            ghost.physicsBody?.applyImpulse(CGVectorMake(0, 90))
        } else {
            if died == true {
                
            } else {
                ghost.physicsBody?.velocity = CGVectorMake(0, 0)
                ghost.physicsBody?.applyImpulse(CGVectorMake(0, 90))
            }
        }
        
        for touch in touches {
            let location = touch.locationInNode(self)
            if died == true {
                if (restartButton.containsPoint(location)) {
                    restartScene()
                }
            }
        }
        
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        if gameStarted == true {
            if died == false {
                enumerateChildNodesWithName("background", usingBlock: { (node, error) in
                    let background = node as! SKSpriteNode
                    background.position = CGPoint(x: background.position.x - 2, y: background.position.y)
                    
                    if background.position.x <= -background.size.width {
                        background.position = CGPointMake(background.position.x + background.size.width * 2, background.position.y)
                    }
                    
                })
            }
        }
    }
    
    func createWalls() {
        let scoreNode = SKSpriteNode(imageNamed: "Coin")
        scoreNode.size = CGSize(width: 50, height: 50)
        scoreNode.position = CGPoint(x: self.frame.width + 25, y: self.frame.height / 2)
        scoreNode.physicsBody = SKPhysicsBody(rectangleOfSize: scoreNode.size)
        scoreNode.physicsBody?.affectedByGravity = false
        scoreNode.physicsBody?.dynamic = false
        scoreNode.physicsBody?.categoryBitMask = PhysicsCategory.Score
        scoreNode.physicsBody?.collisionBitMask = 0
        scoreNode.physicsBody?.contactTestBitMask = PhysicsCategory.Ghost
        
        wallPair = SKNode()
        wallPair.name = "wallPair"
        
        let topWall = SKSpriteNode(imageNamed: "Wall")
        let bottomWall = SKSpriteNode(imageNamed: "Wall")
        
        topWall.position = CGPoint(x: self.frame.width + 25, y: self.frame.height / 2 + 350)
        bottomWall.position = CGPoint(x:  self.frame.width + 25, y: self.frame.height / 2 - 350)
        topWall.setScale(0.5)
        bottomWall.setScale(0.5)
        topWall.zRotation = CGFloat(M_PI)
        
        topWall.physicsBody = SKPhysicsBody(rectangleOfSize: topWall.frame.size)
        topWall.physicsBody?.categoryBitMask = PhysicsCategory.Wall
        topWall.physicsBody?.collisionBitMask = PhysicsCategory.Ghost
        topWall.physicsBody?.contactTestBitMask = PhysicsCategory.Ghost
        topWall.physicsBody?.affectedByGravity = false
        topWall.physicsBody?.dynamic = false
        
        bottomWall.physicsBody = SKPhysicsBody(rectangleOfSize: bottomWall.frame.size)
        bottomWall.physicsBody?.categoryBitMask = PhysicsCategory.Wall
        bottomWall.physicsBody?.collisionBitMask = PhysicsCategory.Ghost
        bottomWall.physicsBody?.contactTestBitMask = PhysicsCategory.Ghost
        bottomWall.physicsBody?.affectedByGravity = false
        bottomWall.physicsBody?.dynamic = false
        
        wallPair.addChild(topWall)
        wallPair.addChild(bottomWall)
        
        wallPair.zPosition = 1
        
        let randomPosition = CGFloat.random(min: -200, max: 200)
        wallPair.position.y = wallPair.position.y + randomPosition
        wallPair.addChild(scoreNode)
        
        wallPair.runAction(moveAndRemove)
        
        self.addChild(wallPair)
    }
}