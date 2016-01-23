//
//  followersVC.swift
//  Instragram
//
//  Created by Leonardo Testa on 1/14/16.
//  Copyright © 2016 LosKbres. All rights reserved.
//

import UIKit
import Parse

var show=String()
var user=String()

class followersVC: UITableViewController {

    //arrays to hold data received from servers
    var usernameArray = [String]()
    var avaArray=[PFFile]()
    
    //array showing who do we follow or who followings us
    var followArray = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //title at the top
        
        self.navigationItem.title=show.uppercaseString
        
        //load followers if tapped on followers label
        if show == "followers"{
            loadFollowers()
        }
        
        //load followings if tapped on followings label
        if show == "followings"{
            loadFollowings()
        }
        
    }

    //loading followers
    func loadFollowers(){
        //STEP 1. Find in FOLLOW class people following User
        //find followers of user
        let followQuery=PFQuery(className: "follow")
        followQuery.whereKey("following", equalTo: user)
        followQuery.findObjectsInBackgroundWithBlock ({ (objects:[PFObject]?, error:NSError?) -> Void in
            if error == nil{
                //clean up
                self.followArray.removeAll(keepCapacity: false)

                //STEP 2. Hold received data
                //find releated objects depending on query settings
                for object in objects!{
                    self.followArray.append(object.valueForKey("follower") as! String)
                }

                //STEP 3. Find in USER class data of users following "user"
                //find users following user
                let query = PFUser.query()
                query?.whereKey("username", containedIn: self.followArray)
                query?.addDescendingOrder("createdAt")
                query?.findObjectsInBackgroundWithBlock({ (objects:[PFObject]?, error:NSError?) -> Void in
                    if error == nil {
                        
                        //clean up
                        self.usernameArray.removeAll(keepCapacity: false)
                        self.avaArray.removeAll(keepCapacity: false)
                        
                        //find releated objects in user class of Parse
                        for object in objects!{
                            self.usernameArray.append(object.objectForKey("username") as! String)
                            self.avaArray.append(object.objectForKey("ava") as! PFFile)
                            self.tableView.reloadData()
                        }
                    }else{
                        print(error!.localizedDescription)
                    }
                })
            }else{
                print(error!.localizedDescription)
            }
        })
    }
    
    //loading followings
    func loadFollowings(){
        //find followers of user
        let followQuery=PFQuery(className: "follow")
        followQuery.whereKey("follower", equalTo: user)
        followQuery.findObjectsInBackgroundWithBlock ({ (objects:[PFObject]?, error:NSError?) -> Void in
            if error == nil{
                //clean up
                self.followArray.removeAll(keepCapacity: false)
                
                //find releated objects in "follow" class of Parse
                for object in objects!{
                    self.followArray.append(object.valueForKey("following") as! String)
                }
                
                //find users followeb by user
                let query = PFQuery(className: "_User")
                query.whereKey("username", containedIn: self.followArray)
                query.addDescendingOrder("createdAt")
                query.findObjectsInBackgroundWithBlock({ (objects:[PFObject]?, error:NSError?) -> Void in
                    if error == nil {
                        
                        //clean up
                        self.usernameArray.removeAll(keepCapacity: false)
                        self.avaArray.removeAll(keepCapacity: false)
                        
                        //find releated objects in user class of Parse
                        for object in objects!{
                            self.usernameArray.append(object.objectForKey("username") as! String)
                            self.avaArray.append(object.objectForKey("ava") as! PFFile)
                            self.tableView.reloadData()
                        }
                    }else{
                        print(error!.localizedDescription)
                    }
                })
            }else{
                print(error!.localizedDescription)
            }
        })
    }
    
    //cell numb
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usernameArray.count
    }
    
    //cell height
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return self.view.frame.size.width/4
    }
    
    //cell config
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell=tableView.dequeueReusableCellWithIdentifier("Cell") as! followersCell
        
        //STEP 1. connect data from serv to objects
        cell.usernameLbl.text=usernameArray[indexPath.row]
        avaArray[indexPath.row].getDataInBackgroundWithBlock ({(data:NSData?, error:NSError?) -> Void in
            if error == nil{
                cell.avaImg.image=UIImage(data: data!)
            }else{
                print(error!.localizedDescription)
            }
        })
        
        //STEP 2. show do user following or do not
        let query=PFQuery(className: "follow")
        query.whereKey("follower", equalTo: PFUser.currentUser()!.username!)
        query.whereKey("following",equalTo:cell.usernameLbl.text!)
        query.countObjectsInBackgroundWithBlock({ (count:Int32, error:NSError?) -> Void in
            if error == nil{
                if count == 0{
                    cell.followBtn.setTitle("FOLLOW", forState: UIControlState.Normal)
                    cell.followBtn.backgroundColor = UIColor.lightGrayColor()
                }else{
                    cell.followBtn.setTitle("FOLLOWING", forState: UIControlState.Normal)
                    cell.followBtn.backgroundColor = UIColor.greenColor()
                }
            }
        })

        //hide follow button for current user
        if cell.usernameLbl.text == PFUser.currentUser()?.username{
            cell.followBtn.hidden=true
        }
        
        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //recall cell to call futher cell's data
        
        let cell=tableView.cellForRowAtIndexPath(indexPath) as! followersCell
        
        //if user tapped on himself, go hom, else go guest
        if cell.usernameLbl.text! == PFUser.currentUser()!.username!{
            let home = self.storyboard?.instantiateViewControllerWithIdentifier("homeVC") as! homeVC
            self.navigationController?.pushViewController(home, animated: true)
        }else{
            guestname.append(cell.usernameLbl.text!)
            let guest = self.storyboard?.instantiateViewControllerWithIdentifier("guestVC") as! guestVC
            self.navigationController?.pushViewController(guest, animated: true)
        }
    }
    
}






