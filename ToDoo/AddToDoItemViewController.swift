//
//  AddToDoItemViewController.swift
//  ToDoo
//
//  Created by Jiang, Yifeng on 8/13/14.
//  Copyright (c) 2014 Uprush. All rights reserved.
//

import UIKit

class AddToDoItemViewController: UIViewController {
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    var toDoItem: ToDoItem!
    
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
        }
        self.navigationController.dismissViewControllerAnimated(true, completion: nil)
        //        navigationController.popViewControllerAnimated(false)
//        self.navigationController.
    }


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if toDoItem != nil {
            var dest = segue.destinationViewController as ToDoListTableViewController
            dest.toDoItems.append(toDoItem)
            dest.tableView.reloadData()
        }
    }


}
