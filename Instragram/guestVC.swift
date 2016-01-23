
//
//  guestVC.swift
//  Instragram
//
//  Created by Leonardo Testa on 1/15/16.
//  Copyright © 2016 LosKbres. All rights reserved.
//

import UIKit
import Parse

var guestname =  [String]()

class guestVC: UICollectionViewController {

    //UI Objects
    var refresher : UIRefreshControl!
    var page : Int = 10
    
    //arrays to hold data from server
    var uuidArray =  [String]()
    var picArray = [PFFile]()
    
    //default func
    override func viewDidLoad() {
        super.viewDidLoad()
    
        ///allow vertical scroll
        self.collectionView?.alwaysBounceVertical = true
    
        //background color
        self.collectionView?.backgroundColor = UIColor.whiteColor()
        
        //top title
        self.navigationItem.title = guestname.last
    
        //new back button
        self.navigationItem.hidesBackButton = true
        let backBtn = UIBarButtonItem(title: "back", style: UIBarButtonItemStyle.Plain, target: self, action: "back:")
        self.navigationItem.leftBarButtonItem = backBtn
        
        //swipe to go back
        let backSwipe = UISwipeGestureRecognizer(target: self, action: "back:")
        backSwipe.direction = UISwipeGestureRecognizerDirection.Right
        self.view.addGestureRecognizer(backSwipe)
        
        //pull to refresh
        refresher = UIRefreshControl()
        refresher.addTarget(self, action: "refresh", forControlEvents: UIControlEvents.ValueChanged)
        collectionView?.addSubview(refresher)
        
        //call load posts function
        loadPosts()
    }
    
    //back function
    func back(sender : UIBarButtonItem){
        
        //push back
        self.navigationController?.popViewControllerAnimated(true)
        
        //clean guest username or deduct the last guest username from guestname Array
        if !guestname.isEmpty{
            guestname.removeLast()
        }
    }

    //refresh function
    func refresh(){
        collectionView?.reloadData()
        refresher.endRefreshing()
    }
    
    //posts loading function
    func loadPosts(){
        //load posts
        let query = PFQuery(className: "posts")
        query.whereKey("username", equalTo: guestname.last!)
        query.limit=page
        query.findObjectsInBackgroundWithBlock { (objects:[PFObject]?, error:NSError?) -> Void in
            if error == nil {
                
                //clean up
                self.uuidArray.removeAll(keepCapacity: false)
                self.picArray.removeAll(keepCapacity: false)
                
                //find releated objects
                for object in objects!{
                    
                    //hold found information in arrays
                    self.uuidArray.append(object.valueForKey("uuid")as! String)
                    self.picArray.append(object.valueForKey("pic") as! PFFile)
                }
                
                self.collectionView?.reloadData()
            }else{
                print(error!.localizedDescription)
            }
        }
    }
    
    //cell numb
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
        
        //connect data from array to picImg object from pictureCell class
        picArray[indexPath.row].getDataInBackgroundWithBlock ({ (data:NSData?, error:NSError?) -> Void in
            if error == nil {
                cell.picImg.image = UIImage(data: data!)
            }else{
                print(error!.localizedDescription)
            }
        })
        
        return cell
    }
    
    
    //header config 
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        
        //define header
        let header = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: "Header", forIndexPath: indexPath) as! headerView
        
        //STEP 1. Load data of guest
        let infoQuery = PFQuery(className: "_User")
        infoQuery.whereKey("username", equalTo: guestname.last!)
        infoQuery.findObjectsInBackgroundWithBlock ({ (objects:[PFObject]?, error:NSError?) -> Void in
            if error == nil {
                
                //show wrong user
                if objects!.isEmpty{
                    print("wrong user")
                }
                
                //find releated to user information
                for object in objects!{
                    header.fullnameLbl.text = (object.objectForKey("fullname") as? String)?.uppercaseString
                    header.bioLbl.text = object.objectForKey("bio") as? String
                    header.bioLbl.sizeToFit()
                    header.webTxt.text = object.objectForKey("web") as? String
                    header.webTxt.sizeToFit()
                    let avaFile : PFFile = (object.objectForKey("ava") as? PFFile)!
                    avaFile.getDataInBackgroundWithBlock({ (data:NSData?, error:NSError?) -> Void in
                        header.avaImg.image = UIImage(data:data!)
                    })
                }
            }else{
                print (error?.localizedDescription)
            }
        })
        
        //STEP 2. Show do current user follow guest or do not
        let followQuery=PFQuery(className: "follow")
        followQuery.whereKey("follower", equalTo: PFUser.currentUser()!.username!)
        followQuery.whereKey("following", equalTo: guestname.last!)
        followQuery.countObjectsInBackgroundWithBlock ({ (count:Int32, error:NSError?) -> Void in
            if error == nil {
                if count == 0 {
                    header.button.setTitle("FOLLOW", forState: UIControlState.Normal)
                    header.button.backgroundColor=UIColor.lightGrayColor()
                }else{
                    header.button.setTitle("FOLLOWING", forState: UIControlState.Normal)
                    header.button.backgroundColor=UIColor.greenColor()
                }
            }else{
                print(error?.localizedDescription)
            }
        })
        
        //STEP 3. Count statistics
        //count post
        let posts = PFQuery(className: "posts")
        posts.whereKey("username", equalTo: guestname.last!)
        posts.countObjectsInBackgroundWithBlock ({ (count:Int32, error:NSError?) -> Void in
            if error == nil {
                header.posts.text="\(count)"
            }else{
                print(error?.localizedDescription)
            }
        })
        
        //count followers
        let followers = PFQuery(className: "follow")
        followers.whereKey("followers", equalTo: guestname.last!)
        followers.countObjectsInBackgroundWithBlock ({ (count:Int32, error:NSError?) -> Void in
            if error == nil {
                header.followers.text="\(count)"
            }else{
                print(error?.localizedDescription)
            }
        })
        
        //count followings
        let followings = PFQuery(className: "follow")
        followings.whereKey("follower", equalTo: guestname.last!)
        followings.countObjectsInBackgroundWithBlock ({ (count:Int32, error:NSError?) -> Void in
            if error == nil {
                header.followings.text="\(count)"
            }else{
                print(error?.localizedDescription)
            }
        })
        
        //STEP 4. Implement tap gestures
        //tap to posts label
        let postsTap=UITapGestureRecognizer(target: self, action: "postsTap")
        postsTap.numberOfTapsRequired = 1
        header.posts.userInteractionEnabled = true
        header.posts.addGestureRecognizer(postsTap)
        
        //tap to followers label
        let followersTap=UITapGestureRecognizer(target: self, action: "followersTap")
        followersTap.numberOfTapsRequired = 1
        header.followers.userInteractionEnabled = true
        header.followers.addGestureRecognizer(followersTap)
        
        //tap to followings label
        let followingsTap=UITapGestureRecognizer(target: self, action: "followingsTap")
        followingsTap.numberOfTapsRequired = 1
        header.followings.userInteractionEnabled = true
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
        user = guestname.last!
        show = "followers"
    
        //define followersVC
        let followers = self.storyboard?.instantiateViewControllerWithIdentifier("followersVC") as! followersVC
        
        //navigate to it
        self.navigationController?.pushViewController(followers, animated: true)
    }
    
    //tapped followings label
    func followingsTap(){
        user = guestname.last!
        show = "followings"
        
        //define followersVC
        let followings = self.storyboard?.instantiateViewControllerWithIdentifier("followersVC") as! followersVC
        
        //navigate to it
        self.navigationController?.pushViewController(followings, animated: true)
    }
}
























