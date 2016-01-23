//
//  resetPasswordVC.swift
//  Instragram
//
//  Created by Leonardo Testa on 1/12/16.
//  Copyright © 2016 LosKbres. All rights reserved.
//

import UIKit
import Parse

class resetPasswordVC: UIViewController {

    //textfield
    @IBOutlet weak var emailTxt: UITextField!
    
    //buttons
    @IBOutlet weak var resetBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //aligment
        emailTxt.frame=CGRectMake(10, 120, self.view.frame.size.width - 20, 30)
        resetBtn.frame=CGRectMake(20, emailTxt.frame.origin.y + 50, self.view.frame.size.width / 4, 30)
        cancelBtn.frame=CGRectMake(self.view.frame.size.width - self.view.frame.size.width / 4 - 20, resetBtn.frame.origin.y, self.view.frame.size.width / 4, 30)
        
        //backgroud
        let bg=UIImageView(frame: CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height))
        bg.image=UIImage(named: "bg.jpg")
        bg.layer.zPosition = -1
        self.view.addSubview(bg)
    }
    
    //clicked reset button
    @IBAction func resetBtn_click(sender: AnyObject) {
        //hide keyboard
        self.view.endEditing(true)
        
        //email textfield is empty
        if emailTxt.text!.isEmpty{
            
            //show alert message
            let alert=UIAlertController(title: "EMAIL FIELD", message: "is empty", preferredStyle: UIAlertControllerStyle.Alert)
            let ok = UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil)
            alert.addAction(ok)
            self.presentViewController(alert, animated: true, completion: nil)
        }else{
            
            //request for reseting password
            PFUser.requestPasswordResetForEmailInBackground(emailTxt.text!) { (success:Bool, error:NSError?) -> Void in
                if success{
                    //show alert message
                    let alert=UIAlertController(title: "EMAIL FOR RESETING PASSWORD", message: "has been sent to texted email", preferredStyle: UIAlertControllerStyle.Alert)
                    
                    //if pressed OK call self.dismiss function
                    let ok = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler:{(UIAlertAction)-> Void in
                        self.dismissViewControllerAnimated(true, completion: nil)
                    })
                    
                    alert.addAction(ok)
                    self.presentViewController(alert, animated: true, completion: nil)
                }
                else{
                    print(error?.localizedDescription)
                }
            }
        }
    }
    
    //clicked cancel button
    @IBAction func cancelBtn_click(sender: AnyObject) {
        //hide keyboard when pressed cancel
        self.view.endEditing(true)
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}
