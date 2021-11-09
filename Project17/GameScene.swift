//
//  GameScene.swift
//  Project17
//  Day 62-63
//  Created by Igor Polousov on 07.11.2021.
//

import SpriteKit

// Добавли соотвествие протоколу SKPhysicsContactDelegate для создания столкновений
class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // Emitter node для того чтобы создать эффект движения звёзд на заднем плане
    var starField: SKEmitterNode!
    // Фигура ракеты игрока, которая будет взаимодействовать с предметами
    var player: SKSpriteNode!
    // Надпись с количеством набранных очков
    var scoreLabel: SKLabelNode!
    // Надпись при окончании игры
    var gameOverLabel: SKLabelNode!
    // Надпись чтобы начать новую игру
    var newGameLabel: SKLabelNode!
    // Надпись со счётчиком предметов на экране
    var trachCount: SKLabelNode!
    
    // Массив предметов которые будут лететь на встречу игроку
    var possibleEnemies = ["ball", "hammer", "tv"]
    // Тиаймер для регулировки запуска предметов
    var gameTimer: Timer?
    // Переменная определяющая закончилась игра или нет
    var gameOver = false
    
    // Переменная счётыика предметов со свойством обозревателя
    var spriteCount = 0 {
        didSet {
            trachCount.text = "Trash count: \(spriteCount)"
        }
    }
    
    // Переменная счётчика очков со свойством обозревателя
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    // Функция didMove  в которой заданы стартовые настройки игры аналог viewDidLoad
    override func didMove(to view: SKView) {
        
        // Установка заднего фона
        backgroundColor = .black
        starField = SKEmitterNode(fileNamed: "starfield")
        starField.position = CGPoint(x: 1024, y: 384)
        starField.advanceSimulationTime(10)
        addChild(starField)
        starField.zPosition = -1
        
        // Установка надписи New Game
        newGameLabel = SKLabelNode(fontNamed: "Chalkduster")
        newGameLabel.text = "New Game"
        newGameLabel.position = CGPoint(x: 100, y: 700)
        addChild(newGameLabel)
        
        // Установка игрока и его картинки
        player = SKSpriteNode(imageNamed: "player")
        player.position = CGPoint(x: 100, y: 384)
        player.physicsBody = SKPhysicsBody(texture: player.texture!, size: player.size)
        player.physicsBody?.contactTestBitMask = 1 // Посмотреть получше!!
        addChild(player)
        
        // Установка надписи количества предметов
        trachCount = SKLabelNode(fontNamed: "Chalkduster")
        trachCount.position = CGPoint(x: 300, y: 700)
        trachCount.horizontalAlignmentMode = .left
        addChild(trachCount)
        
        // Установка надписи количества очков
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.position = CGPoint(x: 16, y: 16)
        scoreLabel.horizontalAlignmentMode = .left
        addChild(scoreLabel)
      
        // Указали параметри physicsWorld
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        physicsWorld.contactDelegate = self

        // Установили с какой периодичностью и какая функция будет запускаться, задаётся только интервал и запускается сразу, без отсрочки
        gameTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(createEnemy), userInfo: nil, repeats: true)
    }
    
    // createEnemy() для создания предметов на фоне
    @objc func createEnemy() {
        // Получение случайного элемента из массива предметов
        guard let enemy = possibleEnemies.randomElement() else { return }
        // Создание врага
        let sprite = SKSpriteNode(imageNamed: enemy)
        
        // Установка диапазона появления предметов
        sprite.position = CGPoint(x: 1200, y: Int.random(in: 50...736))
        addChild(sprite)
        spriteCount += 1
        print(spriteCount)
        
        sprite.physicsBody = SKPhysicsBody(texture: sprite.texture!, size: sprite.size)
        sprite.physicsBody?.categoryBitMask = 1
        // Установка скорости предметов
        sprite.physicsBody?.velocity = CGVector(dx: -200, dy: 0)
        sprite.physicsBody?.angularVelocity = 5
        // Установка замедления предметов
        sprite.physicsBody?.linearDamping = 0
        sprite.physicsBody?.angularDamping = 0
        
        // Свитч в зависимости от количества уже созданных предметов изменяет скорость их появления путем установки нового таймера и новых параметров скорости
        switch spriteCount {
        case 1...5:
            gameTimer?.invalidate() // Отменяет установленный ранее таймер
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
            gameTimer?.invalidate()
            gameTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(createEnemy), userInfo: nil, repeats: true)
        }
        
        // Если произошло сталкновение и gameOver = true
        if gameOver {
            // Установка надписи Game Over
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
    
    // Update() производит мониторинг игрового поля и в зависимости от заданных параметров производит изменения
    override func update(_ currentTime: TimeInterval) {
        // Заданы параметры, если предмет пролетел весь экран, то он удаляется
        for node in children {
            if node.position.x < -300 {
                node.removeFromParent()
            }
        }
        // Если игра не закончена добавить + score
        if !gameOver {
            score += 1
        }
    }
 
    // Метод который определяет изменение положения оъектов
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        var location = touch.location(in: self)
       
        // Заданы ограничения для области передвижения объектов
        if location.y < 100 {
            location.y = 100
        } else if location.y > 668 {
            location.y = 668
        }
        player.position = location
    }
    
    // Фукнция когда происходит контакт предметов
    func didBegin(_ contact: SKPhysicsContact) {
        let explosion = SKEmitterNode(fileNamed: "explosion")!
        // Задано, что если положение игрока и предмета совпадает
        explosion.position = player.position
        addChild(explosion)
        // Удалить игрока
        player.removeFromParent()
        // Закончить игру
        gameOver = true
    }
    
    
    // ТouchesBegan() создана для опредения касаний к экрану или окну. В данной ситуаци создана для работы надписи New Game
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
    
    // Метод определяющий действие при завершении касания, палец отоврвется от объекта
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        var location = touch.location(in: self)
        let object = nodes(at: location)
        
        if !object.contains(player) {
            location.x = 100
            location.y = 384
            player.position = location
        }
    }
    
}
