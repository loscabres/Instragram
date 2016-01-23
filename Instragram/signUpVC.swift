//
//  signUpVC.swift
//  Instragram
//
//  Created by Leonardo Testa on 1/12/16.
//  Copyright © 2016 LosKbres. All rights reserved.
//

import UIKit
import Parse

class signUpVC: UIViewController , UIImagePickerControllerDelegate,UINavigationControllerDelegate{

    //profile image
    @IBOutlet weak var avaImg: UIImageView!
    
    
    //textfields
    @IBOutlet weak var usernameTxt: UITextField!
    @IBOutlet weak var passwordTxt: UITextField!
    @IBOutlet weak var repeatPasswordTxt: UITextField!
    @IBOutlet weak var fullnameTxt: UITextField!
    @IBOutlet weak var bioTxt: UITextField!
    @IBOutlet weak var webTxt: UITextField!
    @IBOutlet weak var emailTxt: UITextField!
    
    //scroolview
    @IBOutlet weak var scrollView: UIScrollView!
    
    //reset default size
    var scrollViewHeight:CGFloat=0
    
    //keyboard frame size
    var keyboard = CGRect()
    
    //buttons
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var signUpBtn: UIButton!

    //default func
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //scrollview frame size
        scrollView.frame=CGRectMake(0,0,self.view.frame.width,self.view.frame.height)
        scrollView.contentSize.height=self.view.frame.height
        scrollViewHeight=scrollView.frame.size.height
    
        //check notification if keyboard is shown or not
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "showKeyboard:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "hideKeyboard:", name: UIKeyboardWillHideNotification, object: nil)
        
        //declare hide keyboard tap
        let hideTap=UITapGestureRecognizer(target: self, action: "hideKeyboardTap:")
        hideTap.numberOfTapsRequired=1
        self.view.userInteractionEnabled=true
        self.view.addGestureRecognizer(hideTap)
        
        //round ava
        avaImg.layer.cornerRadius=avaImg.frame.size.width/2
        avaImg.clipsToBounds=true
        
        //declare select image tap
        let avaTap=UITapGestureRecognizer(target: self, action: "loadImg:")
        avaTap.numberOfTapsRequired=1
        avaImg.userInteractionEnabled=true
        avaImg.addGestureRecognizer(avaTap)
        
        //aligment
        avaImg.frame=CGRectMake(self.view.frame.size.width/2-40, 40, 80, 80)
        
        usernameTxt.frame=CGRectMake(10, avaImg.frame.origin.y+90, self.view.frame.size.width-20, 30)
        passwordTxt.frame=CGRectMake(10, usernameTxt.frame.origin.y+40, self.view.frame.size.width-20, 30)
        repeatPasswordTxt.frame=CGRectMake(10, passwordTxt.frame.origin.y+40, self.view.frame.size.width-20, 30)
        emailTxt.frame=CGRectMake(10, repeatPasswordTxt.frame.origin.y+60, self.view.frame.size.width-20, 30)
        fullnameTxt.frame=CGRectMake(10, emailTxt.frame.origin.y+40, self.view.frame.size.width-20, 30)
        bioTxt.frame=CGRectMake(10, fullnameTxt.frame.origin.y+40, self.view.frame.size.width-20, 30)
        webTxt.frame=CGRectMake(10, bioTxt.frame.origin.y+40, self.view.frame.size.width-20, 30)
    
        signUpBtn.frame=CGRectMake(10, webTxt.frame.origin.y+50, self.view.frame.size.width/4, 30)
        cancelBtn.frame=CGRectMake(self.view.frame.size.width - self.view.frame.size.width / 4 - 20, signUpBtn.frame.origin.y, self.view.frame.size.width/4, 30)
        
        //backgroud
        let bg=UIImageView(frame: CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height))
        bg.image=UIImage(named: "bg.jpg")
        bg.layer.zPosition = -1
        self.view.addSubview(bg)
    }
    
    //call picker to select image
    func loadImg(recognizer:UITapGestureRecognizer){
        let picker=UIImagePickerController()
        picker.delegate=self
        picker.sourceType = .PhotoLibrary
        picker.allowsEditing=true
        presentViewController(picker, animated: true, completion: nil)
    }
    
    //connect selected image to our ImageView
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        avaImg.image=info[UIImagePickerControllerEditedImage] as? UIImage
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    //hide keyboard if tapped
    func hideKeyboardTap(recognizer:UITapGestureRecognizer)
    {
        self.view.endEditing(true)
    }
    
    //show keyboard func
    func showKeyboard(notification:NSNotification){
        //define keyboard size
        keyboard=(notification.userInfo?[UIKeyboardFrameEndUserInfoKey]!.CGRectValue)!
        
        //MOVE UP ui
        UIView.animateWithDuration(0.4) { () -> Void in
            self.scrollView.frame.size.height=self.scrollViewHeight-self.keyboard.height
        }
    }
    
    //hide keyboard func
    func hideKeyboard(notification:NSNotification){
  
        //move down UI
        UIView.animateWithDuration(0.4) { () -> Void in
            self.scrollView.frame.size.height=self.view.frame.height
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //clicked sign up
    @IBAction func signUpBtn_click(sender: AnyObject) {
        print("sign uyp pressed")
    
        self.view.endEditing(true)
        
        //if fields are empty
        if ((usernameTxt.text!.isEmpty || passwordTxt.text!.isEmpty || repeatPasswordTxt.text!.isEmpty || emailTxt.text!.isEmpty || fullnameTxt.text!.isEmpty || bioTxt.text!.isEmpty || webTxt.text!.isEmpty)){
            
            //alert message
            let alert=UIAlertController(title: "PLEASE", message: "fill all fields", preferredStyle: UIAlertControllerStyle.Alert)
            let ok = UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil)
            alert.addAction(ok)
            self.presentViewController(alert, animated: true, completion: nil)
            
            return
        }
        
        //if different passwords
        if passwordTxt.text != repeatPasswordTxt.text{
            //alert message
            let alert=UIAlertController(title: "PASSWORDS", message: "do not match", preferredStyle: UIAlertControllerStyle.Alert)
            let ok = UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil)
            alert.addAction(ok)
            self.presentViewController(alert, animated: true, completion: nil)
            
            return
        }
        
        
        //sendj data to server to releated columns
        let user = PFUser()
        user.username=usernameTxt.text?.lowercaseString
        user.email=emailTxt.text?.lowercaseString
        user.password=passwordTxt.text
        
        user["fullname"]=fullnameTxt.text?.lowercaseString
        user["bio"]=bioTxt.text
        user["web"]=webTxt.text?.lowercaseString
        
        //in Edit Profile it's gonna be assigned
        user["tel"]=""
        user["gender"]=""
        
        //convert our image for sending to server
        let avaData=UIImageJPEGRepresentation(avaImg.image!, 0.5)
        let avaFile=PFFile(name: "ava.jpg", data: avaData!)
        user["ava"]=avaFile
        
        //save data in server
        user.signUpInBackgroundWithBlock { (success:Bool, error:NSError?) -> Void in
            if success{
                print("register")
                
                //remember loged user
                NSUserDefaults.standardUserDefaults().setObject(user.username, forKey: "username")
                NSUserDefaults.standardUserDefaults().synchronize()
                
                //call login func for AppDelegate.swift class
                let appDelegate:AppDelegate=UIApplication.sharedApplication().delegate as! AppDelegate
                appDelegate.login()
                
            }else{
                let alert=UIAlertController(title: "ERROR", message: error!.localizedDescription, preferredStyle:UIAlertControllerStyle.Alert)
                let ok=UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler:nil)
                alert.addAction(ok)
                self.presentViewController(alert, animated: true, completion: nil)            }
        }
        
        
    }
    

    //clicked cancel
    @IBAction func cancelBtn_click(sender: AnyObject) {
        print("cancel pressed")
        
        //hide keyboard when pressed cancel
        self.view.endEditing(true)
        
        dismissViewControllerAnimated(true , completion: nil)
    }
    

}
