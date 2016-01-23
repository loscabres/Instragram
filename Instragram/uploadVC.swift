//
//  uploadVC.swift
//  Instragram
//
//  Created by Leonardo Testa on 1/23/16.
//  Copyright © 2016 LosKbres. All rights reserved.
//

import UIKit
import Parse

class uploadVC: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {

    //UI Objects
    @IBOutlet weak var picImg: UIImageView!
    @IBOutlet weak var titleTxt: UITextView!
    @IBOutlet weak var publishBtn: UIButton!
    @IBOutlet weak var removeBtn: UIButton!
    
    //default func
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //disable publish Btn
        publishBtn.enabled = false
        publishBtn.backgroundColor = UIColor.lightGrayColor()

        //hide remove button
        removeBtn.hidden=true
        
        //standart UI containt
        picImg.image = UIImage(named: "pbg.jpg")
        
        //hide keyboard tap
        let hideTap=UITapGestureRecognizer(target: self, action: "hideKeyboard")
        hideTap.numberOfTapsRequired=1
        self.view.userInteractionEnabled=true
        self.view.addGestureRecognizer(hideTap)
        
        //select image tap
        let picTap=UITapGestureRecognizer(target: self, action: "selectImg")
        picTap.numberOfTapsRequired=1
        picImg.userInteractionEnabled=true
        picImg.addGestureRecognizer(picTap)
        
        //call aligment function
        aligment()
    }

    func hideKeyboard(){
        self.view.endEditing(true)
    }
    
    //func to cal pickerViewController
    func selectImg(){
        let picker=UIImagePickerController()
        picker.delegate=self
        picker.sourceType = .PhotoLibrary
        picker.allowsEditing=true
        presentViewController(picker, animated: true, completion: nil)
    }
    
    //hold selected image in picImg object and dismiss PickerController()
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        picImg.image=info[UIImagePickerControllerEditedImage] as? UIImage
        self.dismissViewControllerAnimated(true, completion: nil)
        
        //enable publish Btn
        publishBtn.enabled = true
        publishBtn.backgroundColor = UIColor(red: 52.0/255.0, green: 169.0/255.0, blue: 255.0/255.0, alpha: 1)

        //unhide remove button
        removeBtn.hidden=false
        
        //implemen second tap for zooming image
        let zoomTap=UITapGestureRecognizer(target: self, action: "zoomImg")
        zoomTap.numberOfTapsRequired=1
        picImg.userInteractionEnabled=true
        picImg.addGestureRecognizer(zoomTap)
    }
    
    //zooming IN/OUT function
    func zoomImg(){
        
        //define frame of zoomed image
        let zoomed = CGRectMake(0, self.view.center.y - self.view.center.x, self.view.frame.size.width, self.view.frame.size.width)
      
        //frame of unzoomed (small) image
        let unzoomed = CGRectMake(15, self.navigationController!.navigationBar.frame.size.height+30, self.view.frame.size.width / 4.5, self.view.frame.size.width / 4.5)
        
        //if picture is unzoomed, zoom it
        if picImg.frame == unzoomed{
            
            //with animation
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                //resize image frame
                self.picImg.frame=zoomed
                
                //hide objects from background
                self.view.backgroundColor = .blackColor()
                self.titleTxt.alpha=0
                self.publishBtn.alpha=0
                self.removeBtn.alpha=0
            })
        
            // to unzoom
        }else{
            //width animation
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.picImg.frame=unzoomed
                
                //unhide objects from background
                self.view.backgroundColor = .whiteColor()
                self.titleTxt.alpha=1
                self.publishBtn.alpha=1
                self.removeBtn.alpha=1
            })
        }

        
        
    }
    
    //aligment
    func aligment(){
        let width=self.view.frame.size.width
        
        picImg.frame = CGRectMake(15, self.navigationController!.navigationBar.frame.size.height+30, width / 4.5, width / 4.5)

        titleTxt.frame = CGRectMake(picImg.frame.size.width + 25, picImg.frame.origin.y , width - titleTxt.frame.origin.x - 10, picImg.frame.size.height)
        
        publishBtn.frame = CGRectMake(0, self.tabBarController!.tabBar.frame.origin.y - width / 8, width, width/8)
        
        removeBtn.frame = CGRectMake(picImg.frame.origin.x ,picImg.frame.origin.y + picImg.frame.size.height  , picImg.frame.size.width,20)
    }
    
    //clicked publish button
    @IBAction func publishBtn_clicked(sender: AnyObject) {
        //dismiss keyboard
        self.view.endEditing(true)
        
        //send data to server to "posts" class in Parse
        let object=PFObject(className: "posts")
        object["username"] = PFUser.currentUser()!.username
        object["ava"] = PFUser.currentUser()!.valueForKey("ava") as! PFFile
        object["uuid"] = "\(PFUser.currentUser()!.username) \(NSUUID().UUIDString)"
        
        if titleTxt.text.isEmpty{
            object["title"]=""
        }else{
            object["title"]=titleTxt.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        }
        
        //send pic to server after convering to FILE and compression
        let imageData = UIImageJPEGRepresentation(picImg.image!, 0.5)
        let imageFile = PFFile(name: "post.jpg", data: imageData!)
        object["pic"] = imageFile
        
        //finaly save information
        object.saveInBackgroundWithBlock ({ (success:Bool, error:NSError?) -> Void in
            if error == nil {
                
                //send notification with name "uploaded"
                NSNotificationCenter.defaultCenter().postNotificationName("uploaded", object: nil)
                
                //switch to another ViewController at 0 index to tabbar
                self.tabBarController!.selectedIndex=0
                
                //reset everything
                self.viewDidLoad()
                self.titleTxt.text=""
            }
            
        })
        
    }
    
    //clicked remove button
    @IBAction func removeBtn_clicked(sender: AnyObject) {
        self.viewDidLoad()
    }

}










