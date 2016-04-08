//
//  PrinterViewController.swift
//  VPP
//
//  Created by Nicolas Märki on 17.09.14.
//  Copyright (c) 2014 Nicolas Märki. All rights reserved.
//

import UIKit

let userDefaultsKeyPrinters:String = "userDefaultsKeyPrinters"


class PrinterViewController: UITableViewController, UISearchBarDelegate {
    
    
    struct Printer {
        var building:String
        var destination:String
        var device:String
        var floor:String
        var room:String
    }
    
    var printers:[[[String:String]]] = []
    
    let puller = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()

        if let printers:[[[String:String]]] = NSUserDefaults.standardUserDefaults().objectForKey(userDefaultsKeyPrinters) as? [[[String:String]]] {
            self.printers = printers
            self.tableView.reloadData()
        }
        if printers.count == 0 {
            self.loadPrinters()
        }
        
        puller.addTarget(self, action: #selector(PrinterViewController.loadPrinters), forControlEvents: UIControlEvents.ValueChanged)
        tableView.addSubview(puller)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return self.printers.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return self.printers[section].count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("CELL", forIndexPath: indexPath) as UITableViewCell

        let p = self.printers[indexPath.section][indexPath.row]
        
        if p["type"] == "pool" {
            cell.textLabel!.text = p["building"]
            cell.detailTextLabel?.text = NSLocalizedString("Alle", comment: "")
        }
        else {
            let building = p["building"]!
            let room = p["room"]!
            let floor = p["floor"]!
            let device = p["device"]!
            cell.textLabel!.text = "\(building) \(floor) \(room)"
            cell.detailTextLabel?.text = device
        }

        return cell
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let p = self.printers[section][0]
        
        if p["type"] == "pool" {
            return NSLocalizedString("Druckerpools", comment:"")
        }
        else {
            return p["building"]
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let p = self.printers[indexPath.section][indexPath.row];
        
        
        let job = ETHZPrintJob.sharedPrintJob()
        
        
        let building = p["building"]!
        let room = p["room"]!
        let floor = p["floor"]!
        let device = p["device"]!
        
        if p["type"] == "pool" {
            job.printer = ""
        }
        else {
            job.printer = device;
        }
        job.room = "\(building)\(floor)\(room)"
        
        
        
        job.writeToDisk()
        job.postChangeNotification()
        
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            let nc = self.navigationController?.navigationController
            nc!.popViewControllerAnimated(true)
        }
        
       

    }
    
    func loadPrinters() {

        ETHBackend.loadAction("vppprinters", complete: { (result:AnyObject!, error:NSError!) -> Void in
            
            print(error)
            
            self.puller.endRefreshing()
          
            if let printers:[[[String:String]]] = result as? [[[String:String]]] {
                self.printers = printers
                self.tableView.reloadData()
                NSUserDefaults.standardUserDefaults().setObject(printers, forKey: userDefaultsKeyPrinters)
                NSUserDefaults.standardUserDefaults().synchronize()
            }
        })
    
    }
    
    
    func searchBar(searchBar: UISearchBar, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        
        
        
        return true
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView!, canEditRowAtIndexPath indexPath: NSIndexPath!) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView!, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath!) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView!, moveRowAtIndexPath fromIndexPath: NSIndexPath!, toIndexPath: NSIndexPath!) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView!, canMoveRowAtIndexPath indexPath: NSIndexPath!) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
