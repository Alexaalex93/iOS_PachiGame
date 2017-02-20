//
//  GameScene.swift
//  Pachi
//
//  Created by Alejandro Fernandez Gonzalez on 18/02/2017.
//  Copyright © 2017 Alejandro Fernandez Gonzalez. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    //SKPhysicsContactDelegate añadido para implementar fisicas
    
    var scoreLabel: SKLabelNode! //UILAbel de SKsprite
    var score : Int = 0 {
        didSet {
            scoreLabel.text = "Puntuacion: \(score)"//Property observer. se mantiene observando a ver si cambia su valor
        }
    }
    
    var editLabel: SKLabelNode!
    var editingMode: Bool = false {
        didSet {
            if editingMode{
                editLabel.text = "Hecho"
            }else {
                editLabel.text = "Editar"
            }
        }
    
    }
    
    override func didMove(to view: SKView) {
        //AQUÍ HEMOS DEFINIDO MUCHOS NODOS MEDIANTE CODIGO, LO NORMAL ES QUE, EN LOS ELEMENTOS VISUALES, LOS POSICIONES DE MANERA GRAFICA. DE MANERA QUE HAY QUE IDENTIFICARLOS DANDOLES UN NOMBRE EN EL APARTADO GRAFICO E INICIALIZANDOLOS DE LA SIGUIENTE MANERA
        physicsWorld.contactDelegate = self
        
        let background = SKSpriteNode(imageNamed: "background.jpg") //Inicializamos el spriteNode con una imagen que es la del fondo
        background.position = CGPoint(x: 512, y: 384)//Estamos haciendo lo mismo que hemos hecho en GameScene pero por codigo
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)
        
        scoreLabel = SKLabelNode()
        scoreLabel.text = "Puntuación: 0"
        scoreLabel.horizontalAlignmentMode = .right
        scoreLabel.position = CGPoint(x: 980, y: 700)
        addChild(scoreLabel)
        
        editLabel = SKLabelNode()
        editLabel.text = "Editar"
        editLabel.position = CGPoint(x: 80, y: 700)
        addChild(editLabel)
        
        makeBouncer(at: CGPoint(x: 0, y: 0))
        makeBouncer(at: CGPoint(x: 256, y: 0))
        makeBouncer(at: CGPoint(x: 512, y: 0))
        makeBouncer(at: CGPoint(x: 768, y: 0))
        makeBouncer(at: CGPoint(x: 1024, y: 0))
        
        makeSlot(at: CGPoint(x: 128, y: 0), isGood: true)
        makeSlot(at: CGPoint(x: 384, y: 0), isGood: false)
        makeSlot(at: CGPoint(x: 640, y: 0), isGood: true)
        makeSlot(at: CGPoint(x: 896, y: 0), isGood: false)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first{
        
            let location = touch.location(in: self)
//            let box = SKSpriteNode(color: UIColor.red, size: CGSize(width: 64, height: 64))
//            box.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 64, height: 64))
//            physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
//            box.position = location
//            addChild(box)

            physicsBody = SKPhysicsBody(edgeLoopFrom: frame) //Fisica de la escena
            
            //Nodo para la bola
            let objects = nodes(at: location) //Estamos viendo si donde tocamos corresponde a un nodo
            if objects.contains(editLabel){
                editingMode = !editingMode
            } else {
                if editingMode{
                    //Crear barreras
                    let size = CGSize(width: GKRandomDistribution(lowestValue: 16, highestValue: 128).nextInt(), height: 16) //GKRandomDistribution crea valores aleatorios entre los valores indicados. nextInt indica que sea un entero
                    let barrera = SKSpriteNode(color: RandomColor(), size: size)
                    barrera.zRotation = RandomCGFloat(min: 0, max: 3)
                    barrera.position = location
                    
                    barrera.physicsBody = SKPhysicsBody(rectangleOf: barrera.size)
                    barrera.physicsBody?.isDynamic = false
                    addChild(barrera)

                } else {
                    
                    let ball = SKSpriteNode(imageNamed: "ballRed")
                    ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width / 2.0)
                    ball.physicsBody?.contactTestBitMask = (ball.physicsBody?.collisionBitMask)! //ContactTestBitMask indica de que choques quieres enterarte y collisionBitMask indica contra que objetos puede chocar. Por lo tanto al igualar indicamos que nos queremos enterar de todas las colisiones
                    let randomNumRest = CGFloat(arc4random_uniform(100))/100
                    ball.physicsBody?.restitution = randomNumRest//Restitution es la capacidad de rebotar que tiene el objeto
                    ball.position = location
                    var randomNum = Int(arc4random_uniform(50))
                    if randomNum == 0 {
                        randomNum = Int(arc4random_uniform(50))
                    }
                    ball.scale(to: CGSize(width: randomNum , height: randomNum))
                    ball.name = "ball"
                    addChild(ball)
                }
                
            }
            
       
            
            

        }
    }
    
    func makeBouncer(at position: CGPoint){  //El at es el nombre externo, como cuando creabas una variable y le ponias una "KEY" para llamarla en la funcion
    
        //Nodo para objeto ne el que reboten las bolas
        let bouncer = SKSpriteNode(imageNamed: "bouncer")
        bouncer.position = position
        bouncer.physicsBody = SKPhysicsBody(circleOfRadius: bouncer.size.width / 2.0)
        bouncer.physicsBody?.isDynamic = false //Indica si interacciona con otros objetos
        
        addChild(bouncer)
        
    }
    
    func makeSlot(at position: CGPoint, isGood: Bool){
    
        var slotBase: SKSpriteNode
        var slotGlow: SKSpriteNode
        
        if isGood {
            slotBase = SKSpriteNode(imageNamed: "slotBaseGood")
            slotGlow = SKSpriteNode(imageNamed: "slotGlowGood")
            slotBase.name = "good"
            
        } else {
            slotBase = SKSpriteNode(imageNamed: "slotBaseBad")
            slotGlow = SKSpriteNode(imageNamed: "slotGlowBad")
            slotBase.name = "bad"

        }
        
        slotBase.position = position
        slotGlow.position = position
       

        
        let spin = SKAction.rotate(byAngle: CGFloat.pi, duration: 10) //Aungulo de 180º durante 10 seg
        let spinForever = SKAction.repeatForever(spin)
        slotGlow.run(spinForever)
        
        slotBase.physicsBody = SKPhysicsBody(rectangleOf: slotBase.size)
        slotBase.physicsBody?.isDynamic = false //Para que no se muevan las barritas de colores
        
        addChild(slotBase)
        addChild(slotGlow)
        
    }
    
    func collisionBetween(ball: SKNode, object: SKNode){
    
        if object.name == "good" {
           
            destroy(ball: ball)
            score += 1
        
        } else if object.name == "bad" {
            
            destroy(ball: ball)
            score -= 1
        
        }
        
    
    }
    
    func destroy(ball: SKNode){
        
        if let fuego = SKEmitterNode(fileNamed: "FireParticles"){
            fuego.position = ball.position
            addChild(fuego)
        }
        ball.removeFromParent()
        
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        if contact.bodyA.node?.name == "ball" {
            collisionBetween(ball: contact.bodyA.node!, object: contact.bodyB.node!)
        } else if contact.bodyB.node?.name == "ball" {
            collisionBetween(ball: contact.bodyB.node!, object: contact.bodyA.node!)
        }
    }
    
//    private var label : SKLabelNode?
//    private var spinnyNode : SKShapeNode?
//    
//    override func didMove(to view: SKView) {
//        
//        // Get label node from scene and store it for use later
//        self.label = self.childNode(withName: "//helloLabel") as? SKLabelNode
//        if let label = self.label {
//            label.alpha = 0.0
//            label.run(SKAction.fadeIn(withDuration: 2.0))
//        }
//        
//        // Create shape node to use during mouse interaction
//        let w = (self.size.width + self.size.height) * 0.05
//        self.spinnyNode = SKShapeNode.init(rectOf: CGSize.init(width: w, height: w), cornerRadius: w * 0.3)
//        
//        if let spinnyNode = self.spinnyNode {
//            spinnyNode.lineWidth = 2.5
//            
//            spinnyNode.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(M_PI), duration: 1)))
//            spinnyNode.run(SKAction.sequence([SKAction.wait(forDuration: 0.5),
//                                              SKAction.fadeOut(withDuration: 0.5),
//                                              SKAction.removeFromParent()]))
//        }
//    }
//    
//    
//    func touchDown(atPoint pos : CGPoint) {
//        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
//            n.position = pos
//            n.strokeColor = SKColor.green
//            self.addChild(n)
//        }
//    }
//    
//    func touchMoved(toPoint pos : CGPoint) {
//        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
//            n.position = pos
//            n.strokeColor = SKColor.blue
//            self.addChild(n)
//        }
//    }
//    
//    func touchUp(atPoint pos : CGPoint) {
//        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
//            n.position = pos
//            n.strokeColor = SKColor.red
//            self.addChild(n)
//        }
//    }
//    
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        if let label = self.label {
//            label.run(SKAction.init(named: "Pulse")!, withKey: "fadeInOut")
//        }
//        
//        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
//    }
//    
//    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
//        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
//    }
//    
//    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
//    }
//    
//    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
//        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
//    }
//    
//    
//    override func update(_ currentTime: TimeInterval) {
//        // Called before each frame is rendered
//    }
}
