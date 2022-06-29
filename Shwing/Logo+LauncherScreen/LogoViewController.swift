//
//  LogoViewController.swift
//  Shwing
//
//  Created by shy attoun on 09/09/2019.
//  Copyright © 2019 shy attoun. All rights reserved.
//

import UIKit
import AVFoundation
import FirebaseCore
import Firebase
import FirebaseAuth
import GoogleSignIn
import FBSDKLoginKit
import FBSDKShareKit
import FBSDKCoreKit

class LogoViewController: UIViewController {
    
 
    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        print("user LOGGED OUT")
        Api.User.isOnline(bool: false)
    }
    
    let userDefault = UserDefaults.standard

    override func viewDidLoad() {
        super.viewDidLoad()
        logoAnimate()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }
    
    func logoAnimate () {
        UIView.animate(withDuration: 3, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 2, options:[], animations: {
            self.view.layoutIfNeeded()}) {(isComplete) in
           
    func didSignIn()  {
                    
        (UIApplication.shared.delegate as! AppDelegate).configureInitialViewController()
     
        }
    }
    
}

}
