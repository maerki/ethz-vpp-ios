//
//  PreViewController.swift
//  VPP
//
//  Created by Nicolas Märki on 07.11.14.
//  Copyright (c) 2014 Nicolas Märki. All rights reserved.
//

import UIKit

class PreViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let job = ETHZPrintJob.sharedPrintJob()
        
        self.webView.loadRequest(NSURLRequest(URL: job.defaultFileURL))
        self.navigationItem.title = job.fileName
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet weak var webView: UIWebView!

    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
