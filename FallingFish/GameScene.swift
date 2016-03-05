//
//  GameScene.swift
//  FallingFish
//
//  Created by Will Burford on 3/2/16.
//  Copyright (c) 2016 Will Burford. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
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
        let fishXMotion = SKAction.moveBy(CGVector(dx: -size.width/5, dy: 0), duration: 5)
        fish.runAction(fishXMotion)
        self.addChild(fish)
        
        //wall placement does not work correctly on iPads and iPhone 4s
        //Also, i think right wall is a tad bigger than the left one
        //but have no idea how the size.width thing works so i'm giving up for now
        let leftWall = SKSpriteNode(imageNamed: "solidWall.png")
        leftWall.size = CGSize(width: size.width/20, height: size.height)
        leftWall.position = CGPoint(x: size.width/3-size.width/20, y: size.height/2)
        self.addChild(leftWall)
        
        let rightWall = SKSpriteNode(imageNamed: "solidWall.png")
        rightWall.size = CGSize(width: size.width/20, height: size.height)
        //rightWall.position = CGPoint(x: size.width+size.width/10.0), y: size.height/2)
        rightWall.position = CGPoint(x:size.width/1.4, y: size.height/2)
        self.addChild(rightWall)
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
}
