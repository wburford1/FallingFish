//
//  GameViewController.swift
//  FallingFish
//
//  Created by Will Burford on 3/2/16.
//  Copyright (c) 2016 Will Burford. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        if let scene = GameScene(fileNamed:"GameScene") {
            // Configure the view.
            let skView = self.view as! SKView
            skView.showsFPS = true
            skView.showsNodeCount = true
            
            /* Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = true
            
            /* Set the scale mode to scale to fit the window */
            scene.scaleMode = .AspectFill
            
            skView.presentScene(scene)
        }
    }

    override func shouldAutorotate() -> Bool {
        return false
    }

    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return .AllButUpsideDown
        } else {
            return .All
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func showDeathScreen(notification:NSNotification) {
        print("showing death screen in that method thang")
        let score = notification.userInfo?["score"]
        
        let deathScreen = DeathScreenView.init(frame: self.view.frame)
        deathScreen.score = Int(score! as! NSNumber)
        print("score = ",deathScreen.score)
        self.view.addSubview(deathScreen)
    }
    
    func replayButtonPressed(notification:NSNotification) {
        print("in vc!")
    }
    
    override func awakeFromNib() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "showDeathScreen:", name: "ShowDeathScreen", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "replayButtonPressed:", name: "ReplayButtonPressed", object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}
