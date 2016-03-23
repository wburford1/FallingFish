//
//  DeathScreenView.swift
//  FallingFish
//
//  Created by Will Burford on 3/22/16.
//  Copyright © 2016 Will Burford. All rights reserved.
//

import UIKit
import RealmSwift

class DeathScreenView: UIView {
    var score = -1
    {
        didSet {
            addManyChildren()
        }
    }
    
    override init (frame : CGRect) {
        super.init(frame : frame)
        self.backgroundColor = UIColor.init(red: 255, green: 0, blue: 0, alpha: 0.5)
    }
    
    convenience init () {
        self.init(frame:CGRect.zero)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("This class does not support NSCoding")
    }
    
    func addManyChildren() {
        let labelHeight = CGFloat(30);
        let youDiedWidth = self.frame.size.width
        let youDied = UILabel(frame: CGRectMake(self.frame.width/2 - youDiedWidth/2, self.frame.height/4, youDiedWidth, labelHeight))
        youDied.text = "YOU DIED"
        youDied.textAlignment = NSTextAlignment.Center
        youDied.font = UIFont.init(name: "Georgia-Bold", size: 27)
        self.addSubview(youDied)
        
        let scoreWidth = self.frame.size.width
        let scoreLabel = UILabel(frame: CGRectMake(self.frame.width/2 - scoreWidth/2, self.frame.height/4+labelHeight, scoreWidth, labelHeight))
        scoreLabel.text = "Score: " + String(score)
        scoreLabel.font = UIFont.init(name: "Georgia-Bold", size: 27)
        scoreLabel.textAlignment = NSTextAlignment.Center
        self.addSubview(scoreLabel)
        
        let highScoreWidth = self.frame.size.width
        let highScoreLabel = UILabel(frame: CGRectMake(self.frame.width/2 - highScoreWidth/2, self.frame.height/4+labelHeight*2, highScoreWidth, labelHeight+2))
        let realm = try! Realm()
        var predicate = "score > "
        predicate += String(score)
        let previousHighScore = realm.objects(HighScore).filter(predicate)
        /*try! realm.write{
        realm.deleteAll()
        }*/
        if(previousHighScore.count<1){
            let newHighScore = HighScore()
            newHighScore.score = score
            newHighScore.name = "King Arthur"
            newHighScore.date = NSDate()
            let allHS = realm.objects(HighScore)
            try! realm.write {
                realm.delete(allHS)
                realm.add(newHighScore)
            }
            highScoreLabel.text = "New High Score!"
        }
        else{
            var hsString = "High Score: "
            hsString += String(previousHighScore.first!.score)
            highScoreLabel.text = hsString
        }
        highScoreLabel.font = UIFont.init(name: "Georgia-Bold", size: 27)
        highScoreLabel.textAlignment = NSTextAlignment.Center
        self.addSubview(highScoreLabel)
        
        let replayWidth = self.frame.size.width/4
        let replayHeight = replayWidth*(277.0/601.0)
        let replayButton = UIButton.init(frame: CGRectMake(self.frame.width/4*3 - replayWidth/2, self.frame.height/4+labelHeight*4+2, replayWidth, replayHeight))
        replayButton.setImage(UIImage.init(named: "replayButton.png"), forState: UIControlState.Normal)
        replayButton.addTarget(self, action: "replayButtonPressed:", forControlEvents: UIControlEvents.TouchUpInside)
        self.addSubview(replayButton)
    }
    
    func replayButtonPressed(sender:UIButton){
        print("replay button pressed")
        NSNotificationCenter.defaultCenter().postNotificationName("ReplayButtonPressed", object: nil, userInfo: nil)
    }
}
