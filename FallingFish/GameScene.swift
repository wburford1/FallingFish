//
//  GameScene.swift
//  FallingFish
//
//  Created by Will Burford on 3/2/16.
//  Copyright (c) 2016 Will Burford. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    lazy var fishVelXComp : CGFloat = -100000
    lazy var characters : NSMutableArray = NSMutableArray()
    
    struct PhysicsCategory {
        static let None      : UInt32 = 0
        static let All       : UInt32 = UInt32.max
        static let Fish   : UInt32 = 0b1        // 1
        static let Wall   : UInt32 = 0b10       // 2
        static let Death  : UInt32 = 0b11       // 3
    }
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        let myLabel = SKLabelNode(fontNamed:"Chalkduster")
        myLabel.text = "UNDER THE SEA"
        myLabel.fontSize = 45
        myLabel.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame))
        
        self.addChild(myLabel)
        
        self.physicsWorld.contactDelegate = self;
        fishVelXComp = self.size.width/5

        let fish = SKSpriteNode(imageNamed: "JesusFish.png")
        let fishWidth = size.width/15
        fish.size = CGSize(width: fishWidth, height: (fishWidth)/(500/139))
        fish.position = CGPoint(x: size.width/2, y: size.height*3/4)
        fish.physicsBody = SKPhysicsBody(rectangleOfSize: fish.size)
        fish.physicsBody?.dynamic = true
        fish.physicsBody?.collisionBitMask = PhysicsCategory.Fish
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
        leftWall.physicsBody?.collisionBitMask = PhysicsCategory.Wall
        leftWall.physicsBody?.contactTestBitMask = PhysicsCategory.Fish
        leftWall.physicsBody?.affectedByGravity = false
        leftWall.physicsBody?.dynamic = true
        leftWall.physicsBody?.restitution = 1;
        leftWall.physicsBody?.friction = 0;
        leftWall.name = "left wall"
        self.addChild(leftWall)
        
        let rightWall = SKSpriteNode(imageNamed: "solidWall.png")
        rightWall.size = CGSize(width: size.width/20, height: size.height)
        //rightWall.position = CGPoint(x: size.width+size.width/10.0), y: size.height/2)
        rightWall.position = CGPoint(x:size.width/1.4, y: size.height/2)
        rightWall.physicsBody = SKPhysicsBody(rectangleOfSize: rightWall.size)
        rightWall.physicsBody?.categoryBitMask = PhysicsCategory.Wall
        rightWall.physicsBody?.contactTestBitMask = PhysicsCategory.Fish
        rightWall.physicsBody?.collisionBitMask = PhysicsCategory.Wall
        rightWall.physicsBody?.affectedByGravity = false
        rightWall.physicsBody?.dynamic = true
        rightWall.physicsBody?.restitution = 1;
        rightWall.physicsBody?.friction = 0;
        rightWall.name = "right wall"
        self.addChild(rightWall)
        
        let sceneObjects = NSMutableArray()
        sceneObjects.addObject(fish)
        sceneObjects.addObject(leftWall)
        sceneObjects.addObject(rightWall)
        playInfinitGame(sceneObjects)
    }
    
    func playInfinitGame(sceneObjects: NSMutableArray){
        let fish = sceneObjects[0]
        characters = sceneObjects
        fish.physicsBody?!.velocity = (CGVector(dx: fishVelXComp, dy: 0))
        print(fish.physicsBody)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
       /* Called when a touch begins */
        
        for touch in touches {
            let location = touch.locationInNode(self)
            let fish = characters[0]
            let dist = location.y - fish.position.y
            fish.physicsBody?!.velocity.dy = dist
            
            /*let sprite = SKSpriteNode(imageNamed:"Spaceship")
            
            sprite.xScale = 0.5
            sprite.yScale = 0.5
            sprite.position = location
            
            let action = SKAction.rotateByAngle(CGFloat(M_PI), duration:1)
            
            sprite.runAction(SKAction.repeatActionForever(action))
            
            self.addChild(sprite)*/
        }
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        print("didbegincontact")
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        if ((firstBody.categoryBitMask & PhysicsCategory.Fish != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.Wall != 0)) {
                fishDidCollideWithWall(firstBody.node as! SKSpriteNode, wall: secondBody.node as! SKSpriteNode)
        }
        
    }
    
    func fishDidCollideWithWall(fish: SKSpriteNode, wall: SKSpriteNode){
        let idkWhyThisDontWork = fishVelXComp
        print("collision with wall")
        if(wall.name == "right wall"){
            fish.physicsBody?.velocity.dx = idkWhyThisDontWork*(-1)
        }
        else{
            fish.physicsBody?.velocity.dx = idkWhyThisDontWork
        }
        //fish.removeFromParent()
        
    }
}
