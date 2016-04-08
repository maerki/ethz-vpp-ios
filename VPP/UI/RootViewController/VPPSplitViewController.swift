//
//  VPPSplitViewController.swift
//  VPP
//
//  Created by Nicolas Märki on 24.10.14.
//  Copyright (c) 2014 Nicolas Märki. All rights reserved.
//

import UIKit

class VPPSplitViewController: UISplitViewController, UISplitViewControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.delegate = self
        self.preferredDisplayMode = UISplitViewControllerDisplayMode.AllVisible
        self.maximumPrimaryColumnWidth = 100000.0
        self.preferredPrimaryColumnWidthFraction = 0.45;
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
   
    func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController: UIViewController, ontoPrimaryViewController primaryViewController: UIViewController) -> Bool {
        return true
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
