//
//  homeVC.swift
//  Instragram
//
//  Created by Leonardo Testa on 1/14/16.
//  Copyright © 2016 LosKbres. All rights reserved.
//

import UIKit
import Parse

class homeVC: UICollectionViewController {

    //refresher variable
    var refresher:UIRefreshControl!
    
    //size of page
    var page: Int = 10
    
    var uuidArray=[String]()
    var picArray=[PFFile]()
    
    //default func
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //always vertical scroll
        self.collectionView?.alwaysBounceVertical = true
        
        //backgroud color
        collectionView?.backgroundColor = UIColor.whiteColor()
        
        //tittle at the top
        self.navigationItem.title=PFUser.currentUser()?.username?.uppercaseString
        
        //pull to refresh
        refresher=UIRefreshControl()
        refresher.addTarget(self, action: "refresh", forControlEvents: UIControlEvents.ValueChanged)
        collectionView?.addSubview(refresher)
        
        //receive notification from editVC
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reload:", name: "reload", object: nil)
        
        //receive notification from uploadVc
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "uploaded:", name: "uploaded", object: nil)
        
        
        //load posts func
        loadPosts()
    }
    
    //refresh func
    func refresh(){
        
        //reload data information
        collectionView?.reloadData()
        
        //stop refresher animating
        refresher.endRefreshing()
    }

    //reloading func after received notification
    func reload(notifycation:NSNotification){
        collectionView?.reloadData()
    }
    
    //reloading funct after received notification
    func uploaded(notification:NSNotification){
        loadPosts()
    }
    
    //load posts func
    func loadPosts(){
        
        let query=PFQuery(className: "posts")
        query.whereKey("username", equalTo: PFUser.currentUser()!.username!)
        query.limit=page
        
        query.findObjectsInBackgroundWithBlock ({ (objects:[PFObject]?, error:NSError?) -> Void in
            
            if error == nil{
                
                //clean up
                self.uuidArray.removeAll(keepCapacity: false)
                self.picArray.removeAll(keepCapacity: false)
                
                
                //find objects releated to our request
                for object in objects!{
                    
                    //add found data to arrays (holders)
                    self.uuidArray.append(object.valueForKey("uuid") as! String)
                    self.picArray.append(object.valueForKey("pic") as! PFFile)
                }
                
                self.collectionView?.reloadData()
                
            }else{
                print(error!.localizedDescription)
            }
        })
    }
        
    //cell number
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return picArray.count
    }
    
    //cell size
    func collectionview(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath:NSIndexPath) -> CGSize{

        let size = CGSize(width: self.view.frame.size.width/3, height: self.view.frame.size.width/3)
        return size
       
    }
    
    //cell config
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        //define cell
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! pictureCell
        
        //get picture from the picArray
        picArray[indexPath.row].getDataInBackgroundWithBlock { (data:NSData?, error:NSError?) -> Void in
            if error == nil{
                cell.picImg.image=UIImage(data: data!)
            }else{
                print(error!.localizedDescription)
            }
        }
        
        return cell
    }
    
    //header config
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        
        //define header
        let header=collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: "Header", forIndexPath: indexPath) as! headerView
        
        
        //STEP 1. Get user data
        //get user data with connections to columns of PFUser class
        header.fullnameLbl.text=(PFUser.currentUser()?.objectForKey("fullname") as? String)?.uppercaseString
        header.webTxt.text=PFUser.currentUser()?.objectForKey("web") as? String
        header.webTxt.sizeToFit()
        header.bioLbl.text=PFUser.currentUser()?.objectForKey("bio") as? String
        header.bioLbl.sizeToFit()
        
        //get image
        let avaQuery=PFUser.currentUser()?.objectForKey("ava") as! PFFile
        avaQuery.getDataInBackgroundWithBlock { (data:NSData?, error:NSError?) -> Void in
            header.avaImg.image=UIImage(data: data!)
        }
        
        header.button.setTitle("edit profile", forState:UIControlState.Normal)

        //STEP 2. Count statistics
        //count total posts
        let posts=PFQuery(className: "posts")
        posts.whereKey("username", equalTo: PFUser.currentUser()!.username!)
        posts.countObjectsInBackgroundWithBlock ({ (count:Int32, error:NSError?) -> Void in
            if error == nil{
                header.posts.text="\(count)"
            }
        })
        
        //count total followers
        let followers=PFQuery(className: "follow")
        followers.whereKey("following", equalTo: PFUser.currentUser()!.username!)
        followers.countObjectsInBackgroundWithBlock { (count:Int32, error:NSError?) -> Void in
            if error == nil{
                header.followers.text="\(count)"
            }
        }
        
        //count total followings
        let followings=PFQuery(className: "follow")
        followings.whereKey("follower", equalTo: PFUser.currentUser()!.username!)
        followings.countObjectsInBackgroundWithBlock { (count:Int32, error:NSError?) -> Void in
            if error == nil{
                header.followings.text="\(count)"
            }
        }
        
        //STEP 3. Implement tap gestures
        //tap post
        let postsTap=UITapGestureRecognizer(target: self, action: "postsTap")
        postsTap.numberOfTapsRequired=1
        header.posts.userInteractionEnabled=true
        header.posts.addGestureRecognizer(postsTap)
        
        //tap followers
        let followersTap=UITapGestureRecognizer(target: self, action: "followersTap")
        followersTap.numberOfTapsRequired=1
        header.followers.userInteractionEnabled=true
        header.followers.addGestureRecognizer(followersTap)

        //tap followers
        let followingsTap=UITapGestureRecognizer(target: self, action: "followingsTap")
        followingsTap.numberOfTapsRequired=1
        header.followings.userInteractionEnabled=true
        header.followings.addGestureRecognizer(followingsTap)

        
        return header
    }
    
    //tapped posts label
    func postsTap(){
        if !picArray.isEmpty{
            
            let index=NSIndexPath(forItem: 0, inSection: 0)
            self.collectionView?.scrollToItemAtIndexPath(index, atScrollPosition: UICollectionViewScrollPosition.Top, animated: true)
        }
        
    }
    
    //tapped followers label
    func followersTap(){
        
        user = PFUser.currentUser()!.username!
        show = "followers"
        
        //make reference to followersVC
        let followers=self.storyboard?.instantiateViewControllerWithIdentifier("followersVC") as! followersVC
        
        //present
        self.navigationController?.pushViewController(followers, animated: true)
    }

    //tapped followings label
    func followingsTap(){
        
        user = PFUser.currentUser()!.username!
        show = "followings"
        
        //make reference to followersVC
        let followers=self.storyboard?.instantiateViewControllerWithIdentifier("followersVC") as! followersVC
        
        //present
        self.navigationController?.pushViewController(followers, animated: true)
    }
    
    //clicked log out
    @IBAction func logout(sender: AnyObject) {
        
        PFUser.logOutInBackgroundWithBlock { (error:NSError?) -> Void in
            if error == nil {
                
                //remove logged in user from App memory
                NSUserDefaults.standardUserDefaults().setValue(nil, forKey: "username")
                NSUserDefaults.standardUserDefaults().synchronize()
                
                let sigIn=self.storyboard?.instantiateViewControllerWithIdentifier("signInVC") as! signInVC
                let appDelegate : AppDelegate=UIApplication.sharedApplication().delegate as! AppDelegate
                appDelegate.window?.rootViewController = sigIn
            }
        }
    }

}
