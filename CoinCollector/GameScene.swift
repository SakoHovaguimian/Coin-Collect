//
//  GameScene.swift
//  CoinCollector
//
//  Created by Sako Hovaguimian on 6/20/18.
//  Copyright © 2018 Sako Hovaguimian. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate{
    
    
    var coinTimer : Timer?
    var bombTimer : Timer?
    var cloudTimer : Timer?
    
    var coinMan: SKSpriteNode?
    var ground : SKSpriteNode?
    var ceil : SKSpriteNode?
    var scoreLabel : SKLabelNode?
    var yourScoreLabel : SKLabelNode?
    var finalScoreLabel : SKLabelNode?
    var bomb : SKSpriteNode?
    var clouds : SKSpriteNode?
    var coin : SKSpriteNode?
    
    var background : SKTexture?
    var allElements = [SKSpriteNode]()
    
    let coinManCategory: UInt32 = 0x1 << 1
    let coinCatagory: UInt32 = 0x1 << 2
    let bombCategory: UInt32 = 0x1 << 3
    let groundAndCeilCategory: UInt32 = 0x1 << 4
    

    var score = 0
    
    
    
    enum Depth : CGFloat {
        
        case background = 0
        case player = 1
        case coin = 2
        case bomb = 3
        case hud = 1000
    }
    
    
    override func didMove(to view: SKView) {
        
        scene?.scaleMode = SKSceneScaleMode.aspectFit
        
        physicsWorld.contactDelegate = self
        
//        view.showsPhysics = true
//        view.showsFPS = true
//        view.showsNodeCount = true
        
        coinMan = (childNode(withName: "coinMan") as? SKSpriteNode)
        
        coinMan?.physicsBody?.categoryBitMask = coinManCategory
        coinMan?.physicsBody?.contactTestBitMask = coinCatagory | bombCategory
        coinMan?.physicsBody?.collisionBitMask = groundAndCeilCategory
        
        
        coinMan?.zPosition = Depth.player.rawValue
        
       
        
        var coinManRun : [SKTexture] = []
        for number in 1...5 {
            coinManRun.append(SKTexture(imageNamed: "frame-\(number)"))
        }
        
        coinMan?.run(SKAction.repeatForever(SKAction.animate(with: coinManRun, timePerFrame: 0.04)))
        
        ceil = childNode(withName: "ceil") as? SKSpriteNode
        ceil?.physicsBody?.categoryBitMask = groundAndCeilCategory
        ceil?.physicsBody?.collisionBitMask = coinManCategory

        ceil?.zPosition = Depth.background.rawValue
        
        scoreLabel = childNode(withName: "scoreLabel") as? SKLabelNode
        scoreLabel?.fontColor = .black
        startTimers()
        createGrass()
        createBackground()
        createClouds()
        startGame()
    }
    
    // Timers
    
    func startTimers() {
        
        coinTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (timer) in
            self.createCoin()
        })
        
        bombTimer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true, block: { (timer) in
            self.createBomb()
        })
        
        cloudTimer = Timer.scheduledTimer(withTimeInterval: 4, repeats: true, block: { (timer) in
            self.createClouds()
        })
    }
    
    // Creating Coins,Clouds,Backgrounds,Grass
    
    func createGrass() {
        let sizingGrass = SKSpriteNode(imageNamed: "grass")
        let numberOfGrass = Int(size.width / sizingGrass.size.width) + 1
        for number in 0...numberOfGrass {
            let grass = SKSpriteNode(imageNamed: "grass")
            grass.physicsBody = SKPhysicsBody(rectangleOf: grass.size)
            grass.physicsBody?.categoryBitMask = groundAndCeilCategory
            grass.physicsBody?.collisionBitMask = coinManCategory
            grass.physicsBody?.affectedByGravity = false
            grass.physicsBody?.isDynamic = false
            addChild(grass)
            
            grass.zPosition = Depth.background.rawValue
            
            let grassX = -size.width / 2 + grass.size.width / 2 + grass.size.width * CGFloat(number)
            grass.position = CGPoint(x: grassX, y: -size.height / 2 + grass.size.height / 2 - 18)
            let speed = 100.0
            let moveLeft = SKAction.moveBy(x: -grass.size.width - grass.size.width * CGFloat(number), y: 0, duration:TimeInterval(grass.size.width + grass.size.width * CGFloat(number)) / speed)
            
            let resetGrass = SKAction.moveBy(x: size.width + grass.size.width, y: 0, duration: 0)
    
            let grassFullmove = SKAction.moveBy(x: -size.width - grass.size.width, y: 0, duration: TimeInterval(size.width + grass.size.width) / speed)
            let grassMovingForever = SKAction.repeatForever(SKAction.sequence([grassFullmove, resetGrass]))
            
            grass.run(SKAction.sequence([moveLeft, resetGrass, grassMovingForever]))
        }
    }
    
    func createCoin() {
        let coin = SKSpriteNode(imageNamed: "coin")
        coin.physicsBody = SKPhysicsBody(circleOfRadius: coin.size.width / 2)
        coin.physicsBody?.affectedByGravity = false
        coin.physicsBody?.categoryBitMask = coinCatagory
        coin.physicsBody?.contactTestBitMask = coinManCategory
        coin.physicsBody?.collisionBitMask = 0
        addChild(coin)
        
        coin.zPosition = Depth.coin.rawValue
        
        let sizingCoin = SKSpriteNode(imageNamed: "grass")
        
        
        
        let maxY = size.height / 2 - coin.size.height / 2
        let minY = -size.height / 2 + coin.size.height / 2 + sizingCoin.size.height
        
        let range = maxY - minY
        let coinY = maxY - CGFloat(arc4random_uniform(UInt32(range)))
        
        coin.position = CGPoint(x: size.width / 2 + coin.size.width / 2, y: coinY)
        
        
        
        let moveLeft = SKAction.moveBy(x: -size.width - coin.size.width, y: 0, duration: 5)
        coin.run(SKAction.sequence([moveLeft, SKAction.removeFromParent()]))
        
        allElements.append(coin)
    }
    
    func createBomb() {
        
        let bomb = SKSpriteNode(imageNamed: "bomb")
        bomb.physicsBody = SKPhysicsBody(circleOfRadius: bomb.size.width / 2 + 7)
       
        
        bomb.physicsBody?.affectedByGravity = false
        bomb.physicsBody?.categoryBitMask = bombCategory
        bomb.physicsBody?.contactTestBitMask = coinManCategory
        bomb.physicsBody?.collisionBitMask = 0
        bomb.zPosition = Depth.bomb.rawValue
        
        addChild(bomb)
        
        let sizingBomb = SKSpriteNode(imageNamed: "bomb")
        
        let maxY = size.height / 2 - bomb.size.height / 2
        let minY = -size.height / 2 + bomb.size.height / 2 + sizingBomb.size.height
        
        let range = maxY - minY
        let coinY = maxY - CGFloat(arc4random_uniform(UInt32(range)))
        
        bomb.position = CGPoint(x: size.width / 2 + bomb.size.width / 2, y: coinY)
        
        
        
        let moveLeft = SKAction.moveBy(x: -size.width - bomb.size.width, y: 0, duration: 5)
        bomb.run(SKAction.sequence([moveLeft, SKAction.removeFromParent()]))
        
        allElements.append(bomb)
    }
    
    func createBackground() {
        
        background = SKTexture(imageNamed: "background")
        
        for i in 0...1 {
            let background = SKSpriteNode(texture: self.background)
            background.zPosition = Depth.background.rawValue - 4000
            background.size = self.size
            background.position = CGPoint(x: (background.size.width * CGFloat(i)) - CGFloat(1 * i), y: 0)
            addChild(background)
            
            let moveLeft = SKAction.moveBy(x: -background.size.width, y: 0, duration: 10)
            let moveReset = SKAction.moveBy(x: background.size.width, y: 0, duration: 0)
            let moveLoop = SKAction.sequence([moveLeft, moveReset])
            let moveForever = SKAction.repeatForever(moveLoop)
            
            background.run(moveForever)
        }
        
        
    }
    
    
    func createClouds() {
        
        let backgroundTexture = SKTexture(imageNamed: "clouds")
        
        
        
        let clouds = SKSpriteNode(texture: backgroundTexture)
        clouds.zPosition = Depth.background.rawValue
        //background.anchorPoint = CGPoint.zero
        clouds.setScale(3)
        
        addChild(clouds)
        
        let range = size.height - clouds.size.height
        let coinY = CGFloat(arc4random_uniform(UInt32(range)))
        
        clouds.position = CGPoint(x: size.width / 2 + clouds.size.width / 2, y: coinY)
        
        let moveLeft = SKAction.moveBy(x: -clouds.size.width * 3, y: 0, duration: 10)
        let moveReset = SKAction.moveBy(x: clouds.size.width, y: 0, duration: 0)
        let moveLoop = SKAction.sequence([moveLeft, moveReset])
        let moveForever = SKAction.repeatForever(moveLoop)
        
        clouds.run(moveForever)
        
        
        clouds.run(SKAction.sequence([moveForever,SKAction.removeFromParent()]))
        
        allElements.append(clouds)
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if scene?.isPaused == false{
        coinMan?.physicsBody?.applyForce(CGVector(dx: 0, dy: 75000))
        }
        
        
        let touch = touches.first
        if let location = touch?.location(in: self) {
            let theNodes = nodes(at: location)
            
            for node in theNodes {
                if node.name == "play"{
                    
                    score = 0
                    node.removeFromParent()
                    finalScoreLabel?.removeFromParent()
                    yourScoreLabel?.removeFromParent()
                    scoreLabel?.text = "Score: \(score)"
                    scoreLabel?.zPosition = Depth.hud.rawValue
                    scoreLabel?.fontColor = .black
                    scene?.isPaused = false
                    
                    
                    coinMan?.position = CGPoint(x: -313.141, y: -367.429)
                    removeArray(allElements: allElements)
                    
                    startTimers()
                }
            }
        }
    }
    
    

    func didBegin(_ contact: SKPhysicsContact) {
        score += 1
        scoreLabel?.text = "Score: \(score)"
        
        if contact.bodyA.categoryBitMask == coinCatagory {
            contact.bodyA.node?.removeFromParent()
        }
        if contact.bodyB.categoryBitMask == coinCatagory {
            contact.bodyB.node?.removeFromParent()
        }
        
        if contact.bodyA.categoryBitMask == bombCategory {
            gameOver()
           
            
      
            contact.bodyA.node?.removeFromParent()
        }
        if contact.bodyB.categoryBitMask == bombCategory {
            gameOver()
            
            
          
            contact.bodyB.node?.removeFromParent()
        }
    }
    
    func gameOver() {
        scene?.isPaused = true
        
        coinTimer?.invalidate()
        bombTimer?.invalidate()
        cloudTimer?.invalidate()
        
        
        
        yourScoreLabel = SKLabelNode(text: "Your Score: ")
        yourScoreLabel?.position = CGPoint(x: 0, y: 200)
        yourScoreLabel?.fontSize = 100
        yourScoreLabel?.fontColor = .black
        yourScoreLabel?.zPosition = Depth.hud.rawValue
        if yourScoreLabel != nil {
            addChild(yourScoreLabel!)
        }
        score -= 1
        scoreLabel?.text = "Score: \(score)"
        
        finalScoreLabel = SKLabelNode(text: "\(score)")
        finalScoreLabel?.position = CGPoint(x: 0, y: 0)
        finalScoreLabel?.fontSize = 200
        finalScoreLabel?.fontColor = .black
        finalScoreLabel?.zPosition = Depth.hud.rawValue
        if finalScoreLabel != nil {
            addChild(finalScoreLabel!)
        }
        
        let playButton = SKSpriteNode(imageNamed: "play")
        playButton.position = CGPoint(x: 0, y: -150)
        playButton.name = "play"
        playButton.zPosition = Depth.hud.rawValue
        addChild(playButton)
        
        
    }
    
    func startGame() {
        scene?.isPaused = true
        
        coinTimer?.invalidate()
        bombTimer?.invalidate()
        let playButton = SKSpriteNode(imageNamed: "play")
        playButton.position = CGPoint(x: 0, y: 0)
        playButton.name = "play"
        playButton.zPosition = Depth.hud.rawValue
        addChild(playButton)
        
        
        yourScoreLabel = SKLabelNode(text: "Ready To Play? ")
        yourScoreLabel?.position = CGPoint(x: 0, y: 350)
        yourScoreLabel?.fontSize = 100
        yourScoreLabel?.fontColor = .black
        yourScoreLabel?.zPosition = Depth.hud.rawValue
        if yourScoreLabel != nil {
            addChild(yourScoreLabel!)
        
        }
    }
    
    func removeArray(allElements: [SKSpriteNode]) {
        for elements in allElements {
        elements.removeFromParent()
            
        }
    }

}
