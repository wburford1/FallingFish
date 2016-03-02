//
//  MenuViewController.swift
//  FallingFish
//
//  Created by Will Burford on 3/2/16.
//  Copyright © 2016 Will Burford. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        var label = UILabel(frame: CGRectMake(0,0,200,200))
        label.textAlignment = NSTextAlignment.Center
        label.text = "Testing the menu label"
        self.view.addSubview(label)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
