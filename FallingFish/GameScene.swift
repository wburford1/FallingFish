//
//  GameScene.swift
//  FallingFish
//
//  Created by Will Burford on 3/2/16.
//  Copyright (c) 2016 Will Burford. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    
    struct PhysicsCategory {
        static let None      : UInt32 = 0
        static let All       : UInt32 = UInt32.max
        static let Fish   : UInt32 = 0b0       // 0
        static let Wall   : UInt32 = 0b1       // 1
        static let Death  : UInt32 = 0b10      // 2
    }
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        let myLabel = SKLabelNode(fontNamed:"Chalkduster")
        myLabel.text = "Hello, World!"
        myLabel.fontSize = 45
        myLabel.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame))
        
        self.addChild(myLabel)
        
        let fish = SKSpriteNode(imageNamed: "JesusFish.png")
        let fishWidth = size.width/15
        fish.size = CGSize(width: fishWidth, height: (fishWidth)/(500/139))
        fish.position = CGPoint(x: size.width/2, y: size.height*3/4)
        fish.physicsBody = SKPhysicsBody(rectangleOfSize: fish.size)
        fish.physicsBody?.dynamic = true
        fish.physicsBody?.collisionBitMask = 0b0
        fish.physicsBody?.categoryBitMask = PhysicsCategory.Fish
        fish.physicsBody?.contactTestBitMask = PhysicsCategory.Wall | PhysicsCategory.Death
        fish.physicsBody?.restitution = 1.0
        fish.physicsBody?.friction = 0;
        fish.physicsBody?.affectedByGravity = false
        fish.physicsBody?.usesPreciseCollisionDetection = true;
        //fish.physicsBody?.velocity = (CGVector(dx: size.width/10, dy: 0))
        self.addChild(fish)
        
        //wall placement does not work correctly on iPads and iPhone 4s
        //Also, i think right wall is a tad bigger than the left one
        //but have no idea how the size.width thing works so i'm giving up for now
        let leftWall = SKSpriteNode(imageNamed: "solidWall.png")
        leftWall.size = CGSize(width: size.width/20, height: size.height)
        leftWall.position = CGPoint(x: size.width/3-size.width/20, y: size.height/2)
        leftWall.physicsBody = SKPhysicsBody(rectangleOfSize: leftWall.size)
        leftWall.physicsBody?.categoryBitMask = PhysicsCategory.Wall
        leftWall.physicsBody?.collisionBitMask = 0b1
        leftWall.physicsBody?.contactTestBitMask = PhysicsCategory.Fish
        leftWall.physicsBody?.affectedByGravity = false
        leftWall.physicsBody?.dynamic = true
        leftWall.physicsBody?.restitution = 1;
        leftWall.physicsBody?.friction = 0;
        self.addChild(leftWall)
        
        let rightWall = SKSpriteNode(imageNamed: "solidWall.png")
        rightWall.size = CGSize(width: size.width/20, height: size.height)
        //rightWall.position = CGPoint(x: size.width+size.width/10.0), y: size.height/2)
        rightWall.position = CGPoint(x:size.width/1.4, y: size.height/2)
        rightWall.physicsBody = SKPhysicsBody(rectangleOfSize: rightWall.size)
        rightWall.physicsBody?.categoryBitMask = PhysicsCategory.Wall
        rightWall.physicsBody?.contactTestBitMask = PhysicsCategory.Fish
        rightWall.physicsBody?.collisionBitMask = 0b1
        rightWall.physicsBody?.affectedByGravity = false
        rightWall.physicsBody?.dynamic = true
        rightWall.physicsBody?.restitution = 1;
        rightWall.physicsBody?.friction = 0;
        self.addChild(rightWall)
        
        let sceneObjects = NSMutableArray()
        sceneObjects.addObject(fish)
        sceneObjects.addObject(leftWall)
        sceneObjects.addObject(rightWall)
        playInfinitGame(sceneObjects)
    }
    
    func playInfinitGame(sceneObjects: NSMutableArray){
        let fish = sceneObjects[0]
        fish.physicsBody?!.velocity = (CGVector(dx: size.width, dy: 0))
        print(fish.physicsBody)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
       /* Called when a touch begins */
        
        for touch in touches {
            let location = touch.locationInNode(self)
            
            let sprite = SKSpriteNode(imageNamed:"Spaceship")
            
            sprite.xScale = 0.5
            sprite.yScale = 0.5
            sprite.position = location
            
            let action = SKAction.rotateByAngle(CGFloat(M_PI), duration:1)
            
            sprite.runAction(SKAction.repeatActionForever(action))
            
            self.addChild(sprite)
        }
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        print("didbegincontact")
        // 1
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        // 2
        if ((firstBody.categoryBitMask & PhysicsCategory.Fish != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.Wall != 0)) {
                fishDidCollideWithWall(firstBody.node as! SKSpriteNode, wall: secondBody.node as! SKSpriteNode)
        }
        
    }
    
    func fishDidCollideWithWall(fish: SKSpriteNode, wall: SKSpriteNode){
        print("collision with wall")
        let originalVelocity = fish.physicsBody?.velocity
        fish.physicsBody?.velocity = CGVector(dx: (originalVelocity?.dx)!*(-1), dy: 0)
        //fish.removeFromParent()
        
    }
}
