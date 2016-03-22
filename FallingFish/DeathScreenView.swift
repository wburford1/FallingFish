//
//  DeathScreenView.swift
//  FallingFish
//
//  Created by Will Burford on 3/22/16.
//  Copyright © 2016 Will Burford. All rights reserved.
//

import UIKit

class DeathScreenView: UIView {
    
    override init (frame : CGRect) {
        super.init(frame : frame)
        addManyChildren()
    }
    
    convenience init () {
        self.init(frame:CGRect.zero)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("This class does not support NSCoding")
    }
    
    func addManyChildren (){
        
    }
}
