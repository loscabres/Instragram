//
//  signInVC.swift
//  Instragram
//
//  Created by Leonardo Testa on 1/12/16.
//  Copyright © 2016 LosKbres. All rights reserved.
//

import UIKit
import Parse

class signInVC: UIViewController {

    //label
    @IBOutlet weak var label: UILabel!
    
    //textfield
    @IBOutlet weak var usernameTxt: UITextField!
    @IBOutlet weak var passwordTxt: UITextField!
    
    //buttons
    @IBOutlet weak var signInBtn: UIButton!
    @IBOutlet weak var signUpBtn: UIButton!
    @IBOutlet weak var forgotBtn: UIButton!
  
    //default func
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    
        //Pacifico font of label
        label.font=UIFont(name: "Pacifico", size: 25)
        
        label.frame=CGRectMake(10, 80, self.view.frame.size.width-20, 50)
        
        usernameTxt.frame=CGRectMake(10, label.frame.origin.y + 70, self.view.frame.size.width-20, 30)
        
        passwordTxt.frame=CGRectMake(10, usernameTxt.frame.origin.y + 40, self.view.frame.size.width-20, 30)
        
        forgotBtn.frame=CGRectMake(10, passwordTxt.frame.origin.y + 30, self.view.frame.size.width-20, 30)
        signInBtn.frame=CGRectMake(10, forgotBtn.frame.origin.y + 40, self.view.frame.size.width/4, 30)
        signUpBtn.frame=CGRectMake(self.view.frame.size.width - self.view.frame.size.width/4-20, signInBtn.frame.origin.y , self.view.frame.size.width/4, 30)
        
    
        //tap to kide keyboard
        let hideTap=UITapGestureRecognizer(target: self, action: "hideKeyBoard:")
        hideTap.numberOfTapsRequired=1
        self.view.userInteractionEnabled=true
        self.view.addGestureRecognizer(hideTap)
        
        //backgroud
        let bg=UIImageView(frame: CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height))
        bg.image=UIImage(named: "bg.jpg")
        bg.layer.zPosition = -1
        self.view.addSubview(bg)
        
    }
    
    func hideKeyBoard(recognizer:UITapGestureRecognizer){
        self.view.endEditing(true)
    }
    
    //clicked sign in button
    @IBAction func signBtn_Click(sender: AnyObject) {
        print("sign in pressed")
        
        //hide keyboard
        self.view.endEditing(true)
        
        //if textfields are empty
        if usernameTxt.text!.isEmpty || passwordTxt.text!.isEmpty{
            let alert=UIAlertController(title: "PLEASE", message: "fill in fields", preferredStyle:UIAlertControllerStyle.Alert)
            let ok=UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler:nil)
            alert.addAction(ok)
            self.presentViewController(alert, animated: true, completion: nil)
            
        }
        
        //lgoin function
        PFUser.logInWithUsernameInBackground(usernameTxt.text!, password: passwordTxt.text!) { (user:PFUser?, error:NSError?) -> Void in
            if error==nil{
                //remember user or save in App Memory did the user login or not
                NSUserDefaults.standardUserDefaults().setObject(user!.username, forKey: "username")
                NSUserDefaults.standardUserDefaults().synchronize()
                
                //call login function from AppDelegate.swift class
                let appDelegate:AppDelegate=UIApplication.sharedApplication().delegate as!AppDelegate
                appDelegate.login()
            }else{
                let alert=UIAlertController(title: "ERROR", message: error!.localizedDescription, preferredStyle:UIAlertControllerStyle.Alert)
                let ok=UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler:nil)
                alert.addAction(ok)
                self.presentViewController(alert, animated: true, completion: nil)
            }
        }
    }
    
}
