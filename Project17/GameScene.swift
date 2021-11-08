//
//  GameScene.swift
//  Project17
//
//  Created by Igor Polousov on 07.11.2021.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var starField: SKEmitterNode!
    var player: SKSpriteNode!
    var scoreLabel: SKLabelNode!
    var gameOverLabel: SKLabelNode!
    var newGameLabel: SKLabelNode!
    var trachCount: SKLabelNode!
    
    var possibleEnemies = ["ball", "hammer", "tv"]
    var gameTimer: Timer?
    var gameOver = false
    
    var spriteCount = 0 {
        didSet {
            trachCount.text = "Trash count: \(spriteCount)"
        }
    }
    
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    override func didMove(to view: SKView) {
        
        backgroundColor = .black
        starField = SKEmitterNode(fileNamed: "starfield")
        starField.position = CGPoint(x: 1024, y: 384)
        starField.advanceSimulationTime(10)
        addChild(starField)
        starField.zPosition = -1
        
        newGameLabel = SKLabelNode(fontNamed: "Chalkduster")
        newGameLabel.text = "New Game"
        newGameLabel.position = CGPoint(x: 100, y: 700)
        addChild(newGameLabel)
        
        player = SKSpriteNode(imageNamed: "player")
        player.position = CGPoint(x: 100, y: 384)
        player.physicsBody = SKPhysicsBody(texture: player.texture!, size: player.size)
        player.physicsBody?.contactTestBitMask = 1
        addChild(player)
        
        trachCount = SKLabelNode(fontNamed: "Chalkduster")
        trachCount.position = CGPoint(x: 300, y: 700)
        trachCount.horizontalAlignmentMode = .left
        addChild(trachCount)
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.position = CGPoint(x: 16, y: 16)
        scoreLabel.horizontalAlignmentMode = .left
        addChild(scoreLabel)
        
        score = 0
        
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        physicsWorld.contactDelegate = self
        
        
     
            gameTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(createEnemy), userInfo: nil, repeats: true)
        
    }
    
    @objc func createEnemy() {
        guard let enemy = possibleEnemies.randomElement() else { return }
        let sprite = SKSpriteNode(imageNamed: enemy)
        
        sprite.position = CGPoint(x: 1200, y: Int.random(in: 50...736))
        addChild(sprite)
        spriteCount += 1
        print(spriteCount)
        
        sprite.physicsBody = SKPhysicsBody(texture: sprite.texture!, size: sprite.size)
        sprite.physicsBody?.categoryBitMask = 1
        sprite.physicsBody?.velocity = CGVector(dx: -200, dy: 0)
        sprite.physicsBody?.angularVelocity = 5
        sprite.physicsBody?.linearDamping = 0
        sprite.physicsBody?.angularDamping = 0
        
        switch spriteCount {
        case 1...5:
            gameTimer?.invalidate()
            gameTimer = Timer.scheduledTimer(timeInterval: 0.8, target: self, selector: #selector(createEnemy), userInfo: nil, repeats: true)
            sprite.physicsBody?.angularVelocity = 10
            sprite.physicsBody?.velocity = CGVector(dx: -300, dy: 0)
            
        case 6...10:
            gameTimer?.invalidate()
            gameTimer = Timer.scheduledTimer(timeInterval: 0.6, target: self, selector: #selector(createEnemy), userInfo: nil, repeats: true)
            sprite.physicsBody?.angularVelocity = 15
            sprite.physicsBody?.velocity = CGVector(dx: -400, dy: 0)
            
        case 11...15:
            gameTimer?.invalidate()
            gameTimer = Timer.scheduledTimer(timeInterval: 0.4, target: self, selector: #selector(createEnemy), userInfo: nil, repeats: true)
            sprite.physicsBody?.angularVelocity = 20
            sprite.physicsBody?.velocity = CGVector(dx: -500, dy: 0)
       
        default:
            gameTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(createEnemy), userInfo: nil, repeats: true)
        }
        
        if gameOver {
            gameOverLabel = SKLabelNode(fontNamed: "Chalkduster")
            gameOverLabel.position = CGPoint(x: 500, y: 350)
            gameOverLabel.zPosition = +1
            gameOverLabel.fontColor = .systemRed
            gameOverLabel.fontSize = 80
            gameOverLabel.text = "Game Over"
            addChild(gameOverLabel)
            sprite.removeFromParent()
            gameTimer?.invalidate()
        }
        
    }
    
    override func update(_ currentTime: TimeInterval) {
        
        for node in children {
            if node.position.x < -300 {
                node.removeFromParent()
            }
        }
        
        if !gameOver {
            score += 1
        }
    }
    
 
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        var location = touch.location(in: self)
       
        if location.y < 100 {
            location.y = 100
        } else if location.y > 668 {
            location.y = 668
        }
        player.position = location
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let explosion = SKEmitterNode(fileNamed: "explosion")!
        explosion.position = player.position
        addChild(explosion)
        
        player.removeFromParent()
        gameOver = true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let object = nodes(at: location)
        
        if object.contains(newGameLabel) && gameOver {
            gameOverLabel.removeFromParent()
            gameOver = false
            spriteCount = 0
            gameTimer?.invalidate()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
                self?.player.position = CGPoint(x: 100, y: 384)
                self?.addChild((self?.player)!)
                self?.createEnemy()
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        var location = touch.location(in: self)
        let object = nodes(at: location)
        
        if object.contains(player) {
            location.x = 100
            location.y = 384
            player.position = location
        }
    }
    
}
