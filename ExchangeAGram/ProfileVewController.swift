//
//  ProfileVewController.swift
//  ExchangeAGram
//
//  Created by Isaiah Belle on 12/2/15.
//  Copyright © 2015 Isaiah Belle. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

class ProfileVewController: UIViewController, FBSDKLoginButtonDelegate {

    @IBOutlet weak var fbLoginView: FBSDKLoginButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()

        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: "fbProfileChanged:",
            name: FBSDKProfileDidChangeNotification,
            object: nil)
        FBSDKProfile.enableUpdatesOnAccessTokenChange(true)

        
        // Do any additional setup after loading the view.
        if (FBSDKAccessToken.currentAccessToken() != nil)
        {
            // User is already logged in, do work such as go to next view controller.
            print("LOGGED IN !!!")
            self.fbProfileChanged(self)

        }
        else
        {
           
            fbLoginView.readPermissions = ["public_profile", "email", "user_friends"]
            fbLoginView.publishPermissions = ["publish_actions"]
            fbLoginView.delegate = self
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!){
        print("User Logged In")
        
        if ((error) != nil)
        {
            // Process error
            print("Error: \(error.localizedDescription)")
        }
        else if result.isCancelled {
            // Handle cancellations
            print("LOGIN CANCELLED!")
        }
        else {
            // If you ask for multiple permissions at once, you
            // should check if specific permissions missing
            if result.grantedPermissions.contains("email") ||
            result.grantedPermissions.contains("public_profile") ||
            result.grantedPermissions.contains("user_friends") ||
            result.grantedPermissions.contains("public_actions")
            {
                print("LOGGED IN WITH PERMISSIONS!")
                
            }
        }
    }
    
    
    /*!
    @abstract Sent to the delegate when the button was used to logout.
    @param loginButton The button that was clicked.
    */
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!)
    {
       print("LOGGED OUT")
    }
    
    
    func fbProfileChanged(sender: AnyObject!) {
        
        let fbProfile = FBSDKProfile.currentProfile()
        if (fbProfile != nil)
        {
            let fbToken = FBSDKAccessToken.currentAccessToken()
            // If you ask for multiple permissions at once, you
            // should check if specific permissions missing
            if fbToken.hasGranted("email") ||
                fbToken.hasGranted("public_profile") ||
                fbToken.hasGranted("user_friends") ||
               fbToken.hasGranted("public_actions")
            {
              // Fetch & format the profile picture
            let strProfilePicURL = fbProfile.imageURLForPictureMode(FBSDKProfilePictureMode.Square, size: self.profileImageView.frame.size)
            //let url = NSURL(string: strProfilePicURL, relativeToURL: NSURL(string: "http://graph.facebook.com/"))
            let imageData = NSData(contentsOfURL: strProfilePicURL!)
            let image = UIImage(data: imageData!)
            
            self.nameLabel.text = fbProfile.name
            self.profileImageView.image = image
            
            self.profileImageView.hidden = false
            self.nameLabel.hidden = false   
                
            }
           
        }
        else
        {
            self.nameLabel.text = ""
            self.profileImageView.image = UIImage(named: "")
            
            self.profileImageView.hidden = false
            self.nameLabel.hidden = false
        }
    }

}
