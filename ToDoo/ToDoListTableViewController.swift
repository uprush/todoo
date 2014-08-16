//
//  ToDoListTableViewController.swift
//  ToDoo
//
//  Created by Jiang, Yifeng on 8/13/14.
//  Copyright (c) 2014 Uprush. All rights reserved.
//

import UIKit

class ToDoListTableViewController: UITableViewController, FBLoginViewDelegate {
    
    let AWS_ACCOUNT = "your-aws-account-id"
    let COGNITO_IDENTITY_POOL = "your-cognito-identity-pool-id"
    let UNAUTH_ROLE_ARN = "cognito-unauth-role-arn"
    let AUTH_ROLE_ARN = "cognito-auth-role-arn"
    

    var toDoItems:[ToDoItem] = [ToDoItem]()
    var syncClient: AWSCognito!
//    var syncClient = AWSCognito.defaultCognito()
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet var fbLoginView : FBLoginView!
    
    
    func loadInitialData() {
//        var item1 = ToDoItem(itemName: "Buy milk")
//        toDoItems.append(item1)
//        
//        var item2 = ToDoItem(itemName: "Buy eggs")
//        toDoItems.append(item2)
//
//        var item3 = ToDoItem(itemName: "Read a book")
//        toDoItems.append(item3)
    }
    
    @IBAction func login(sender: AnyObject) {
        var buttonTitle = loginButton.titleLabel.text
        
        if buttonTitle == "Login" {
            fbLoginView = FBLoginView()
            fbLoginView.frame = CGRectOffset(fbLoginView.frame, (self.view.center.x - (fbLoginView.frame.size.width / 2)), 5);
            fbLoginView.delegate = self
            fbLoginView.readPermissions = ["public_profile", "email", "user_friends"]
            
            self.view.addSubview(fbLoginView)
            
        } else {
            FBSession.activeSession().closeAndClearTokenInformation()
        }
        
    }

    func syncData() {
        println("Syncing data...")
        toDoItems.removeAll(keepCapacity: true)
        
        // sync data from Cognito
        if syncClient == nil {
            syncClient = AWSCognito.defaultCognito()
        }
        var dataset = syncClient.openOrCreateDataset("myDataSet")
        
//        dataset.clear() // for test only
        dataset.synchronize()
        
        if dataset.size() != 0 {
            var items: Dictionary = dataset.getAll()
            for (id, itemJson) in items {
                //                println("\(id): \(itemJson)")
                //                let itemJson:String = items[i].value
                //                println(itemJson)
                
                let data:NSData = itemJson.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
                let jsonObject : AnyObject! = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil)
                
                if let nsDictionaryObject = jsonObject as? NSDictionary {
                    if let swiftDictionary = nsDictionaryObject as Dictionary? {
                        //                        println(swiftDictionary)
                        //                        for (key, value) in swiftDictionary {
                        //                            println(key)
                        //                            println(value.description)
                        //                        }
                        var name:String = swiftDictionary["item_name"]!.description
                        var item = ToDoItem(itemName: name)
                        toDoItems.append(item)
                    }
                }
                else if let nsArrayObject = jsonObject as? NSArray {
                    if let swiftArray = nsArrayObject as Array? {
                        println(swiftArray)
                    }
                }
            }
            tableView.reloadData()
        }
        
    }
    
    // Facebook Delegate Methods
    
    func loginViewShowingLoggedInUser(loginView : FBLoginView!) {
        println("User Logged In")
        
        // AWS credentials with FB login
        var token = FBSession.activeSession().accessTokenData.accessToken
        var tokens: Dictionary<NSNumber , String> = [AWSCognitoLoginProviderKey.Facebook.toRaw() : token]
        
        var credentialsProvider = AWSCognitoCredentialsProvider.credentialsWithRegionType(AWSRegionType.USEast1, accountId: AWS_ACCOUNT, identityPoolId: COGNITO_IDENTITY_POOL, unauthRoleArn: UNAUTH_ROLE_ARN, authRoleArn: AUTH_ROLE_ARN, logins: tokens)
        
        var configuration = AWSServiceConfiguration(region: AWSRegionType.USEast1, credentialsProvider: credentialsProvider)
        AWSServiceManager.defaultServiceManager().setDefaultServiceConfiguration(configuration)
        
        
        // Retrieve your cognito ID.
        var cognitoId = credentialsProvider.getIdentityId().continueWithBlock {
            (task: BFTask!) -> NSString in
            if task.isCancelled() {
                // the task is cancelled
                println("task cancelled")
                return ""
                
            } else if task.error() {
                // the task failed
                println("task error")
                return ""
            } else {
                var id = credentialsProvider.identityId
                println("got cognitoid: \(id)")
                println()
                return id
            }
        }
    
        syncData()
        
        fbLoginView.removeFromSuperview()
        loginButton.setTitle("Logout", forState: UIControlState.Normal)
    }
    
    func loginViewFetchedUserInfo(loginView : FBLoginView!, user: FBGraphUser) {
        println("User: \(user)")
        println("User ID: \(user.objectID)")
        println("User Name: \(user.name)")
        var userEmail = user.objectForKey("email") as String
        println("User Email: \(userEmail)")

    }
    
    func loginViewShowingLoggedOutUser(loginView : FBLoginView!) {
        println("User Logged Out")
        loginButton.setTitle("Login", forState: UIControlState.Normal)
    }
    
    func loginView(loginView : FBLoginView!, handleError:NSError) {
        println("Error: \(handleError.localizedDescription)")
    }

    // TODO: this method doesn't get called
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: NSString?, annotation: AnyObject) -> Bool {
        var wasHandled:Bool = FBAppCall.handleOpenURL(url, sourceApplication: sourceApplication)
        println ("hoge=======")
        return wasHandled
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadInitialData()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return toDoItems.count
    }

    override func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        let cell = tableView.dequeueReusableCellWithIdentifier("ListPrototypeCell", forIndexPath: indexPath) as UITableViewCell

        // Configure the cell...
        var toDoItem = toDoItems[indexPath.row]
        cell.textLabel.text = toDoItem.itemName
        
        if toDoItem.completed {
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
        } else {
            cell.accessoryType = UITableViewCellAccessoryType.None
        }
        
        return cell
    }

    override func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        var tappedItem = toDoItems[indexPath.row]
        tappedItem.completed = !tappedItem.completed
        tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.None)
    }
    

    @IBAction func unwindToList(segue: UIStoryboardSegue) {
        // sync data from cloud
//        var source: AddToDoItemViewController = segue.sourceViewController as AddToDoItemViewController
//        if source.toDoItem != nil {
//            var item = source.toDoItem as ToDoItem
//            toDoItems.append(item)
//            tableView.reloadData()
//        }
        println("hoshofhosd~~~~~~~~~")
        syncData()
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

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
//        syncData()
    }

}
