//
//  AddToDoItemViewController.swift
//  ToDoo
//
//  Created by Jiang, Yifeng on 8/13/14.
//  Copyright (c) 2014 Uprush. All rights reserved.
//

import UIKit
import Foundation

class AddToDoItemViewController: UIViewController {
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    var toDoItem: ToDoItem!
    var syncClient: AWSCognito!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func doneButtonPressed(sender : AnyObject) {
        if !textField.text.isEmpty {
            toDoItem = ToDoItem(itemName: textField.text)
            
            // open or create a Cognito dataset
            if syncClient == nil {
                syncClient = AWSCognito.defaultCognito()
            }
            var dataset = syncClient.openOrCreateDataset("myDataSet")
            
            // write the todo item
//            dataset.setString(toDoItem.itemName, forKey: "item_name")
//            dataset.setString(toDoItem.creationDate.description, forKey: "creation_date")
//            dataset.setString(toDoItem.completed.description, forKey: "completed")
            
            
            var item: Dictionary<String , String> = [
                "id": toDoItem.id.__conversion(),
                "item_name": toDoItem.itemName,
                "creation_date": toDoItem.creationDate.description,
                "completed": toDoItem.completed.description
            ]
            var jsonCreationError:NSError?
            let json:NSData = NSJSONSerialization.dataWithJSONObject(item, options: NSJSONWritingOptions.PrettyPrinted, error: &jsonCreationError)
            
            if jsonCreationError {
                println("Errors: \(jsonCreationError)")
            }
            else {
                var datastring: String = NSString(data:json, encoding:NSUTF8StringEncoding)
                println(datastring)
                dataset.setString(datastring, forKey: toDoItem.id.__conversion())
            }
            
            // synchronize
            dataset.synchronize().continueWithBlock{
                (task: BFTask!) -> NSString in
                if task.isCancelled() {
                    // the task is cancelled
                    println("sync task cancelled")
                    return "CANCELLED"
                    
                } else if task.error() {
                    // the task failed
                    println("sync task error")
                    return "FAILED"
                } else {
                    return "SYNCED"
                }
            }
        }
//        var vc:ToDoListTableViewController = self.navigationController.presentedViewController as ToDoListTableViewController
//        vc.syncData()
        self.navigationController.dismissViewControllerAnimated(true, completion: nil)
    }


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if toDoItem != nil {
            var dest = segue.destinationViewController as ToDoListTableViewController
            dest.syncData()
        }
    }


}
