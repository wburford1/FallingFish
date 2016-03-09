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
    lazy var alive : Bool = false
    lazy var deadlyScaler : CGFloat = 1
    
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
        myLabel.text = "CLASSIC NOONS"
        myLabel.fontSize = 45
        myLabel.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame))
        myLabel.zPosition = -100
        
        self.addChild(myLabel)
        
        self.physicsWorld.contactDelegate = self;
        fishVelXComp = self.size.width/5

        let fish = SKSpriteNode(imageNamed: "JesusFish.png")
        let fishWidth = size.width/15
        fish.size = CGSize(width: fishWidth, height: (fishWidth)/(500/139))
        fish.position = CGPoint(x: size.width/2, y: size.height*3/4)
        fish.physicsBody = SKPhysicsBody(rectangleOfSize: fish.size)
        fish.physicsBody?.dynamic = true
        fish.physicsBody?.collisionBitMask = PhysicsCategory.None
        fish.physicsBody?.categoryBitMask = PhysicsCategory.Fish
        fish.physicsBody?.contactTestBitMask = PhysicsCategory.Wall | PhysicsCategory.Death
        fish.physicsBody?.restitution = 1.0
        fish.physicsBody?.friction = 0;
        fish.physicsBody?.affectedByGravity = false
        fish.physicsBody?.usesPreciseCollisionDetection = true;
        fish.physicsBody?.linearDamping = 0;
        fish.physicsBody?.angularDamping = 0;
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
        leftWall.physicsBody?.collisionBitMask = PhysicsCategory.None
        leftWall.physicsBody?.contactTestBitMask = PhysicsCategory.Fish
        leftWall.physicsBody?.affectedByGravity = false
        leftWall.physicsBody?.dynamic = false
        leftWall.physicsBody?.restitution = 1;
        leftWall.physicsBody?.friction = 0;
        leftWall.name = "left wall"
        leftWall.zPosition = -50
        self.addChild(leftWall)
        
        let rightWall = SKSpriteNode(imageNamed: "solidWall.png")
        rightWall.size = CGSize(width: size.width/20, height: size.height)
        //rightWall.position = CGPoint(x: size.width+size.width/10.0), y: size.height/2)
        rightWall.position = CGPoint(x:size.width/1.4, y: size.height/2)
        rightWall.physicsBody = SKPhysicsBody(rectangleOfSize: rightWall.size)
        rightWall.physicsBody?.categoryBitMask = PhysicsCategory.Wall
        rightWall.physicsBody?.contactTestBitMask = PhysicsCategory.Fish
        rightWall.physicsBody?.collisionBitMask = PhysicsCategory.None
        rightWall.physicsBody?.affectedByGravity = false
        rightWall.physicsBody?.dynamic = false
        rightWall.physicsBody?.restitution = 1;
        rightWall.physicsBody?.friction = 0;
        rightWall.name = "right wall"
        rightWall.zPosition = -50
        self.addChild(rightWall)
        
        let anemone = SKSpriteNode(imageNamed: "sea-anemone.png")
        anemone.size = CGSize(width: fish.size.width/3, height: fish.size.width/3)
        anemone.physicsBody = SKPhysicsBody(rectangleOfSize: anemone.size)
        anemone.physicsBody?.categoryBitMask = PhysicsCategory.Death
        anemone.physicsBody?.contactTestBitMask = PhysicsCategory.Fish
        anemone.physicsBody?.collisionBitMask = PhysicsCategory.None
        anemone.physicsBody?.affectedByGravity = false
        anemone.physicsBody?.dynamic = true
        anemone.physicsBody?.restitution = 1;
        anemone.physicsBody?.friction = 0;
        anemone.physicsBody?.linearDamping = 0;
        anemone.name = "anemone"
        
        
        characters.addObject(fish)
        characters.addObject(leftWall)
        characters.addObject(rightWall)
        characters.addObject(anemone)
        playInfinitGame()
    }
    
    func playInfinitGame(){
        alive = true;
        let fish = characters[0]
        fish.physicsBody?!.velocity = (CGVector(dx: (-1)*fishVelXComp, dy: 0))
        let deadlyThread = NSThread(target: self, selector: "spawnRandomDeadlyThings", object: nil)
        deadlyThread.start()
    }
    
    func spawnRandomDeadlyThings(){
        let veryDeadlyThings = NSMutableArray()
        for(var counter = 3;counter<characters.count; counter++){
            veryDeadlyThings[counter-3] = characters[counter]
        }
        let startTime = NSDate()
        let deathAppearanceInterval = 3.0
        let deathAppearanceIntervalRadius = 2.0
        while(alive){
            let timeCheck = NSDate()
            let timeSinceStart: Double =  timeCheck.timeIntervalSinceDate(startTime)
            let side = Int(arc4random_uniform(2))
            let objectType = Int(arc4random_uniform(UInt32(veryDeadlyThings.count)))
            print("object type = ", objectType)
            let deadlyThing = copySpriteNode(veryDeadlyThings[objectType] as! SKSpriteNode)
            
            if(side==0){//left side
                let spin = SKAction.rotateToAngle(CGFloat(3*M_PI/2.0), duration: 0)
                deadlyThing.runAction(spin)
                let wall = characters[1]
                //deadlyThing.position = CGPoint(x: wall.position.x+wall.size.width-deadlyThing.size.width, y: 0) //this is a total hack of a position bc still don't get how sizing and stuff works
                deadlyThing.position = CGPoint(x: size.width/2, y: size.height/2)
                deadlyThing.physicsBody?.velocity = CGVector(dx: 0, dy: size.height/5 * deadlyScaler)
            }
            else if(side==1){
                let spin = SKAction.rotateToAngle(CGFloat(M_PI/2.0), duration: 0)
                deadlyThing.runAction(spin)
                let wall = characters[2]
                deadlyThing.position = CGPoint(x: wall.position.x-wall.size.width+deadlyThing.size.width, y: 0) //this is a total hack of a position bc still don't get how sizing and stuff works
                deadlyThing.physicsBody?.velocity = CGVector(dx: 0, dy: size.height/5 * deadlyScaler)
            }
            self.addChild(deadlyThing)
            
            let sleepRadius = Double(arc4random_uniform(UInt32(deathAppearanceIntervalRadius+1 * 2)))-deathAppearanceIntervalRadius
            print("sleep plus minus = ", sleepRadius)
            let sleepTime = deathAppearanceInterval + sleepRadius
            if(sleepTime>0){
                sleep(UInt32(sleepTime))
            }
        }
    }
    
    func copySpriteNode(sprite: SKSpriteNode)-> SKSpriteNode{
        let copy = sprite.copy() as! SKSpriteNode
        copy.physicsBody = sprite.physicsBody?.copy() as! SKPhysicsBody
        return copy;
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
        else if((firstBody.categoryBitMask & PhysicsCategory.Fish != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.Death != 0)) {
                print("should die now")
                fishDidCollideWithDeath(firstBody.node as! SKSpriteNode, death: secondBody.node as! SKSpriteNode)
        }
        else{
            print("first = ", firstBody.categoryBitMask, ", second = ", secondBody.categoryBitMask)
            print("fish = ",PhysicsCategory.Fish)
            print(firstBody)
            print(secondBody)
        }
        
    }
    
    func fishDidCollideWithDeath(fish: SKSpriteNode, death: SKSpriteNode){
        print("well at least it called the death method")
        fish.removeFromParent()
        let youDied = SKLabelNode(fontNamed: "Gothic")
        youDied.text = "YOU DIED"
        youDied.position = CGPoint(x: size.width/2, y: size.height/4)
        self.addChild(youDied)
    }
    
    func fishDidCollideWithWall(fish: SKSpriteNode, wall: SKSpriteNode){
        let idkWhyThisDontWork = fishVelXComp
        print("collision with wall")
        //let fishImage = UIImage(named: "JesusFish.png")
        if(wall.name == "right wall"){
            fish.physicsBody?.velocity.dx = idkWhyThisDontWork*(-1)
            fish.texture = SKTexture(imageNamed: "JesusFish.png")
        }
        else{
            fish.physicsBody?.velocity.dx = idkWhyThisDontWork
            fish.texture = SKTexture(imageNamed: "JesusFish_Flipped.png")
        }
        //fish.removeFromParent()
        
    }
}
