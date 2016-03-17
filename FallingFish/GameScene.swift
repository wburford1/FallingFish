//
//  GameScene.swift
//  FallingFish
//
//  Created by Will Burford on 3/2/16.
//  Copyright (c) 2016 Will Burford. All rights reserved.
//
import SpriteKit
import RealmSwift

class HighScore : Object{
    dynamic var score = Int()
    dynamic var name = ""
    dynamic var date = NSDate()
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    let button = UIButton()
    lazy var fishVelXComp : CGFloat = -100000
    lazy var alive : Bool = false
    let bubblyScaler = Int(arc4random_uniform(3))

    lazy var deadlyScaler : CGFloat = 1
    lazy var infinitStartTime : NSDate = NSDate()
    lazy var infinitEndTime : NSDate = NSDate()
    lazy var fish : SKSpriteNode = SKSpriteNode()
    lazy var walls : NSMutableArray = NSMutableArray()
    lazy var leftWall : SKSpriteNode = SKSpriteNode()
    lazy var rightWall : SKSpriteNode = SKSpriteNode()
    let numberDeadlyThings : Int = 1
    let deathScreenItems = NSMutableArray()
    lazy var startLabel : SKLabelNode = SKLabelNode()
    
    struct PhysicsCategory {
        static let None      : UInt32 = 0
        static let All       : UInt32 = UInt32.max
        static let Fish   : UInt32 = 0b1        // 1
        static let Wall   : UInt32 = 0b10       // 2
        static let Death  : UInt32 = 0b11       // 3
        static let LowWall : UInt32 = 0b100     // 4
        static let TopWall : UInt32 = 0b101     // 5
        static let Bubbles : UInt32 = 0b111     // 6
        static let Coins : UInt32 = 0b110       // 7
    }
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        
        let myLabel = SKLabelNode(fontNamed:"Zapfino")
        myLabel.text = "Falling Fish"
        myLabel.fontSize = 45
        myLabel.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame))
        myLabel.zPosition = -100
        startLabel = myLabel
        startLabel.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: size.width/2, height: size.height/2))
        startLabel.physicsBody?.collisionBitMask = PhysicsCategory.None
        self.addChild(startLabel)
        
        self.physicsWorld.contactDelegate = self;
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0) //added to fix apparent slow down of deadlyThings
        fishVelXComp = self.size.width/5

        fish = makeFish()
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
        self.leftWall = leftWall
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
        self.rightWall = rightWall
        self.addChild(rightWall)
        
        let topWall = SKSpriteNode(imageNamed: "flatWall.png")
        topWall.size = CGSize(width: size.width*2, height: size.height/32-size.height/33)
        topWall.position = CGPoint(x:0, y: size.height)
        topWall.physicsBody = SKPhysicsBody(rectangleOfSize: topWall.size)
        topWall.physicsBody?.categoryBitMask = PhysicsCategory.TopWall
        topWall.physicsBody?.contactTestBitMask = PhysicsCategory.Fish
        topWall.physicsBody?.collisionBitMask = PhysicsCategory.None
        topWall.physicsBody?.affectedByGravity = false
        topWall.physicsBody?.dynamic = false
        topWall.physicsBody?.restitution = 1;
        topWall.physicsBody?.friction = 0;
        topWall.name = "top wall"
        self.addChild(topWall)
        
        let lowWall = SKSpriteNode(imageNamed: "flatWall.png")
        lowWall.size = CGSize(width: size.width*2, height: size.height/32-size.height/33)
        lowWall.position = CGPoint(x:0, y: 0)
        lowWall.physicsBody = SKPhysicsBody(rectangleOfSize: lowWall.size)
        lowWall.physicsBody?.categoryBitMask = PhysicsCategory.LowWall
        lowWall.physicsBody?.contactTestBitMask = PhysicsCategory.Fish | PhysicsCategory.Death
        lowWall.physicsBody?.collisionBitMask = PhysicsCategory.None
        lowWall.physicsBody?.affectedByGravity = false
        lowWall.physicsBody?.dynamic = false
        lowWall.physicsBody?.restitution = 1;
        lowWall.physicsBody?.friction = 0;
        lowWall.name = "low wall"
        self.addChild(lowWall)
        
        walls.addObject(leftWall)
        walls.addObject(rightWall)
        walls.addObject(topWall)
        walls.addObject(lowWall)
        
        
//        let button = UIButton();
        button.setTitle("Play", forState: .Normal)
        button.setTitleColor(UIColor.blueColor(), forState: .Normal)
        button.frame = CGRectMake((self.view?.frame.size.width)!/2, (self.view?.frame.size.height)!/2, 100, 50)
//        button.frame = CGRectMake(15, -50, 300, 500)

        button.addTarget(self, action: "onPlay:", forControlEvents: .TouchUpInside)
        

        self.view?.addSubview(button)
        
        
//        playInfinitGame()
    }
    
    
    func onPlay(sender:UIButton){
//        alive = true;
        if sender.titleLabel?.text == "Play"{
            startLabel.physicsBody?.velocity = CGVector(dx: 0, dy: size.height/5)
        }
        playInfinitGame()
        sender.removeFromSuperview()

    }
    func makeAnemone() -> SKSpriteNode{
        let anemone = SKSpriteNode(imageNamed: "sea-anemone.png")
        anemone.size = CGSize(width: fish.size.width/3, height: fish.size.width/3)
        anemone.physicsBody = SKPhysicsBody(rectangleOfSize: anemone.size)
        anemone.physicsBody?.categoryBitMask = PhysicsCategory.Death
        anemone.physicsBody?.contactTestBitMask = PhysicsCategory.Fish | PhysicsCategory.TopWall
        anemone.physicsBody?.collisionBitMask = PhysicsCategory.None
        anemone.physicsBody?.affectedByGravity = true
        anemone.physicsBody?.dynamic = true
        anemone.physicsBody?.restitution = 1;
        anemone.physicsBody?.friction = 0;
        anemone.physicsBody?.linearDamping = 0;
        anemone.name = "anemone"
        print("made anemone = ", anemone)
        
        return anemone
    }
    
    func makeBubble() -> SKSpriteNode{
        let bubble = SKSpriteNode(imageNamed: "bubble.png")
        bubble.size = CGSize(width: fish.size.width/3, height: fish.size.width/3)
        bubble.physicsBody = SKPhysicsBody(rectangleOfSize: bubble.size)
        bubble.physicsBody?.categoryBitMask = PhysicsCategory.Bubbles
        bubble.physicsBody?.contactTestBitMask = PhysicsCategory.None
        bubble.physicsBody?.collisionBitMask = PhysicsCategory.None
        bubble.physicsBody?.affectedByGravity = true
        bubble.physicsBody?.dynamic = true
        bubble.physicsBody?.restitution = 1;
        bubble.physicsBody?.friction = 0;
        bubble.physicsBody?.linearDamping = 0;
        bubble.name = "bubble"
        print("made bubble = ", bubble)
        
        return bubble
    }
    
    func makeFish() -> SKSpriteNode{
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
        fish.physicsBody?.velocity = (CGVector(dx: (-1)*fishVelXComp, dy: 0))

        return fish
    }
    
    func playInfinitGame(){
        alive = true;
        deadlyScaler = 1;
//        fish.physicsBody?.velocity = (CGVector(dx: (-1)*fishVelXComp, dy: 0))
        let left = "left"
        let right = "right"
//        let middle = "middle"
        let deadlyLeftThread = NSThread(target: self, selector: "spawnRandomDeadlyThings:", object: left)
        let deadlyRightThread = NSThread(target: self, selector: "spawnRandomDeadlyThings:", object: right)
        let scoreTracker = NSThread(target: self, selector: "trackScore", object: nil)
        let middleThread = NSThread(target: self, selector: "spawnBubbles", object: nil)
        deadlyLeftThread.start()
        deadlyRightThread.start()
        infinitStartTime = NSDate()
        scoreTracker.start()
        middleThread.start()
    }
    
    
    
    func trackScore(){
        let scoreboard = SKLabelNode(fontNamed: "Digital")
        scoreboard.position = CGPoint(x: size.width-size.width/2.9, y: size.height-size.height/20)
        scoreboard.text = "0000"
        self.addChild(scoreboard)
        var timeCheck = NSDate()
        while(alive){
            timeCheck = NSDate()
            let timeSinceStart: Double =  timeCheck.timeIntervalSinceDate(infinitStartTime)
            scoreboard.text = String(Int(timeSinceStart*10))
            if(timeSinceStart>2)&&(Int(timeSinceStart*10%10)==0)&&(deadlyScaler<2.0){
                deadlyScaler+=0.05
            }
            
            usleep(100000)
        }
        infinitEndTime = timeCheck
        scoreboard.removeFromParent()
        dispatch_async(dispatch_get_main_queue(), { () in
            self.endInfinitGame()
        })
    }
    
    func endInfinitGame(){
        let realm = try! Realm()
        print("infintStartTime = ",infinitStartTime)
        print("infinitEndTime = ",infinitEndTime)
        let timeSinceStart: Double =  infinitEndTime.timeIntervalSinceDate(infinitStartTime)
        let scoreLabel = SKLabelNode(fontNamed: "Gothic")
        let score = Int(timeSinceStart*10)
        scoreLabel.text = "Score: " + String(score)
        var predicate = "score > "
        predicate += String(score)
        print(predicate)
        let previousHighScore = realm.objects(HighScore).filter(predicate)
        //print("previous HS = ",previousHighScore)
        let highScoreLabel = SKLabelNode(fontNamed: "Gothic")
        /*try! realm.write{
            realm.deleteAll()
        }*/
        if(previousHighScore.count<1){
            let newHighScore = HighScore()
            newHighScore.score = score
            newHighScore.name = "King Arthur"
            newHighScore.date = NSDate()
            let allHS = realm.objects(HighScore)
            //print("all HS1 = ", allHS)
            try! realm.write {
                realm.delete(allHS)
                realm.add(newHighScore)
            }
            //print("all HS2 = ",allHS)
            highScoreLabel.text = "New High Score!"
        }
        else{
            var hsString = "High Score: "
            hsString += String(previousHighScore.first!.score)
            highScoreLabel.text = hsString
        }
        /*deathView.frame = (self.view?.frame)!
        deathView.backgroundColor = UIColor.clearColor()*/
        
        let youDied = SKLabelNode(fontNamed: "Gothic")
        youDied.text = "YOU DIED"
        youDied.position = CGPoint(x: size.width/2, y: 3*size.height/4)
        self.addChild(youDied)
        deathScreenItems.addObject(youDied)
        
        /*let youDied = UILabel(frame: CGRectMake(deathView.frame.width/2, deathView.frame.height/4, deathView.frame.width, 100))
        youDied.text = "YOU DIED"
        deathView.addSubview(youDied)*/
        
        
        scoreLabel.position = CGPoint(x: size.width/2, y: youDied.position.y - youDied.frame.height-5)
        self.addChild(scoreLabel)
        deathScreenItems.addObject(scoreLabel)
        
        highScoreLabel.position = CGPoint(x: size.width/2, y: scoreLabel.position.y - scoreLabel.frame.height-5)
        self.addChild(highScoreLabel)
        deathScreenItems.addObject(highScoreLabel)
        
        let retry = UIButton()
        retry.setTitle("Retry", forState: .Normal)
        retry.setTitleColor(UIColor.blueColor(), forState: .Normal)
        //retry.frame = CGRectMake(size.width/2, highScoreLabel.position.y - highScoreLabel.frame.height-5, 100, 50)
        retry.frame = CGRectMake((self.view?.frame.size.width)!/2, (self.view?.frame.size.height)!/2, 100, 50)
        retry.addTarget(self, action: "onRetry:", forControlEvents: .TouchUpInside)
        deathScreenItems.addObject(retry)
        self.view?.addSubview(retry)
    }
    
    func onRetry(sender:UIButton){
        fish = makeFish()
        self.addChild(fish)
        for(var counter=0;counter<deathScreenItems.count;counter++){
            print("counter = ", counter)
            if let item = deathScreenItems[counter] as? SKLabelNode {
                print("this is a sprite node ", item)
                item.removeFromParent()
            }
            else if let item = deathScreenItems[counter] as? UIButton {
                print("this is a button", item)
                item.removeFromSuperview()
            }
        }
        onPlay(sender)
    }
    
    /*
    func spawnBubbles(){
//        var deathAppearanceIntervalRadius = 0.8

        var bubbleInterval = 1.0
//        let bubblyScaler  = Int(arc4random_uniform(3))
        while(true){
            bubbleInterval /= (Double(bubblyScaler))
            let bubble = makeBubble()
            let spin = SKAction.rotateToAngle(CGFloat(M_PI/2.0), duration: 0)
            bubble.runAction(spin)
            let possibleX = Int(arc4random_uniform(200)) + 200
            bubble.position = CGPoint(x: possibleX, y: 0)
//            let var yVelocity = size.hesight/5
            bubble.physicsBody?.velocity = CGVector(dx: 0, dy: Int(size.height/5 * 2))
            
            
            dispatch_async(dispatch_get_main_queue(), { () in
                self.addChild(bubble)
            })
            /*
            let sleepRadius = Double(arc4random())/Double(UInt32.max)*(deathAppearanceIntervalRadius * 2) - deathAppearanceIntervalRadius
            print("sleep plus minus = ", sleepRadius)
            let sleepTime = (bubbleInterval + sleepRadius)*1000000
            if(sleepTime>0){
                usleep(UInt32(sleepTime))
            
            }
            */
        }
    }
*/
    

    
    func spawnRandomDeadlyThings(side: String){//not using this method anymore
        var deathAppearanceInterval = 1.2
        var deathAppearanceIntervalRadius = 0.8
        while(alive){
            deathAppearanceInterval /= (Double(deadlyScaler))
            //deathAppearanceIntervalRadius /= (Double(deadlyScaler))
            //let side = Int(arc4random_uniform(2))
            let objectType = Int(arc4random_uniform(UInt32(numberDeadlyThings)))
            print("object type = ", objectType)
            //let deadlyThing = copySpriteNode(veryDeadlyThings[objectType] as! SKSpriteNode)
            let deadlyThing = makeAnemone()
            print("side = ", side)
            if(side=="left"){//left side
                let spin = SKAction.rotateToAngle(CGFloat(3*M_PI/2.0), duration: 0)
                deadlyThing.runAction(spin)
                let wall = leftWall//walls[0]
                deadlyThing.position = CGPoint(x: wall.position.x+wall.size.width-deadlyThing.size.width, y: 0) //this is a total hack of a position bc still don't get how sizing and stuff works
                deadlyThing.physicsBody?.velocity = CGVector(dx: 0, dy: size.height/5 * deadlyScaler)
            }
            else if(side=="right"){
                let spin = SKAction.rotateToAngle(CGFloat(M_PI/2.0), duration: 0)
                deadlyThing.runAction(spin)
                let wall = rightWall//walls[1]
                deadlyThing.position = CGPoint(x: wall.position.x-wall.size.width+deadlyThing.size.width, y: 0) //this is a total hack of a position bc still don't get how sizing and stuff works
                deadlyThing.physicsBody?.velocity = CGVector(dx: 0, dy: size.height/5 * deadlyScaler)
            }
            print("deadlyThing = ", deadlyThing)
            dispatch_async(dispatch_get_main_queue(), { () in
                self.addChild(deadlyThing)
            })
            //let sleepRadius = Double(arc4random_uniform(UInt32(deathAppearanceIntervalRadius+1 * 2)))-deathAppearanceIntervalRadius
            let sleepRadius = Double(arc4random())/Double(UInt32.max)*(deathAppearanceIntervalRadius * 2) - deathAppearanceIntervalRadius
            print("sleep plus minus = ", sleepRadius)
            let sleepTime = (deathAppearanceInterval + sleepRadius)*1000000
            if(sleepTime>0){
                usleep(UInt32(sleepTime))
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
        
        //for(var counter=0;counter<touches.count;counter++) {
        //if alive{
            let touch = touches.first
            let location = touch!.locationInNode(self)
            let dist = location.y - fish.position.y
            fish.physicsBody?.velocity.dy = dist
       // }
        
            /*let sprite = SKSpriteNode(imageNamed:"Spaceship")
            
            sprite.xScale = 0.5
            sprite.yScale = 0.5
            sprite.position = location
            
            let action = SKAction.rotateByAngle(CGFloat(M_PI), duration:1)
            
            sprite.runAction(SKAction.repeatActionForever(action))
            
            self.addChild(sprite)*/
        //}
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
        
        if ((firstBody.categoryBitMask == PhysicsCategory.Fish) &&
            (secondBody.categoryBitMask == PhysicsCategory.Wall)) {
                print("supossed wall = ", secondBody.node)
                print("category = ", secondBody.categoryBitMask)
                print("wall = ", PhysicsCategory.Wall, "death = ",PhysicsCategory.Death)
                fishDidCollideWithWall(firstBody.node as! SKSpriteNode, wall: secondBody.node as! SKSpriteNode)
        }
        else if((firstBody.categoryBitMask == PhysicsCategory.Fish) &&
            (secondBody.categoryBitMask == PhysicsCategory.Death)) {
                print("should die now")
                fishDidCollideWithDeath(firstBody.node as! SKSpriteNode, death: secondBody.node as! SKSpriteNode)
        }
            
        else if((firstBody.categoryBitMask == PhysicsCategory.Fish) && ((secondBody.categoryBitMask == PhysicsCategory.TopWall) || (secondBody.categoryBitMask == PhysicsCategory.LowWall))){
            fishDidCollideWithDeath(firstBody.node as! SKSpriteNode, death: secondBody.node as! SKSpriteNode)
        }
        
        else if((firstBody.categoryBitMask == PhysicsCategory.Death) && (secondBody.categoryBitMask == PhysicsCategory.TopWall)){
            print("death hit top wall")
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
        alive = false;
    }
    
    func fishDidCollideWithWall(fish: SKSpriteNode, wall: SKSpriteNode){
        print("did collide with wall")
        let idkWhyThisDontWork = fishVelXComp
        //let fishImage = UIImage(named: "JesusFish.png")
        if(wall.name == "right wall"){
            fish.physicsBody?.velocity.dx = fishVelXComp*(-1)
            fish.texture = SKTexture(imageNamed: "JesusFish.png")
        }
        else{
            fish.physicsBody?.velocity.dx = idkWhyThisDontWork
            fish.texture = SKTexture(imageNamed: "JesusFish_Flipped.png")
        }
    }
}
