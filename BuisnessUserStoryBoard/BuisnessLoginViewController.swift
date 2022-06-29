//
//  BuisnessLoginViewController.swift
//  Shwing
//
//  Created by shy attoun on 04/11/2019.
//  Copyright © 2019 shy attoun. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import GoogleSignIn
import FBSDKLoginKit
import FBSDKShareKit
import FBSDKCoreKit
import ProgressHUD
import CoreLocation
import GeoFire

class BuisnessLoginViewController: UIViewController {
    
    let userDefault = UserDefaults.standard

    @IBOutlet weak var loginSeg: UISegmentedControl!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var fullnameTF: UITextField!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var topConstraintView: NSLayoutConstraint!
    
    var userLat = ""
    var userLong = ""
    let manager = CLLocationManager ()
    var geoFire : GeoFire!
    var geoFireRef: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupProfileImage ()
       
        
        
    }
    func setupProfileImage () {
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
    }
    
    @objc func dismissKeyboard () {
        view.endEditing(true)
    }

    @IBAction func loginSegAction(_ sender: Any) {
        if loginSeg.selectedSegmentIndex == 0 {
            
            fullnameTF?.isHidden = true
            topConstraintView.constant = 20
            loginBtn.setTitle("LOGIN", for: UIControl.State.normal)
            
        }else if loginSeg.selectedSegmentIndex == 1{
            fullnameTF?.isHidden = false
            topConstraintView.constant = 60
            loginBtn.setTitle("SIGN UP", for: UIControl.State.normal)
        }
    }
    
    @IBAction func loginBtnIsTapped(_ sender: Any) {
        if let userLat = userDefault.value(forKey: "current_location_latitude") as? String, let userLong = userDefault.value(forKey: "current_location_longitude") as? String {
            self.userLat = userLat
            self.userLong = userLong
        }
        
        if loginSeg.selectedSegmentIndex == 0 {
            
            signInUser(email:emailTF.text!,password: passwordTF.text!)
            Api.BuisUser.isBuisUserOnline(bool: true)
          
            
            
        }else if loginSeg.selectedSegmentIndex == 1 {
            createUser(fullname:fullnameTF.text!,email:emailTF.text!,password: passwordTF.text!)
            Api.BuisUser.isBuisUserOnline(bool: true)
          
            
        }
    }
    
    func createUser (fullname:String , email:String , password: String) {
        if self.fullnameTF.text == "" || self.emailTF.text == "" || self.passwordTF.text == "" {
            
            ProgressHUD.showError("please fill all fields")
        }
        else{
            Auth.auth().createUser( withEmail: email, password: password) {(user,error) in
                if error == nil {
                    Api.BuisUser.isBuisUserOnline(bool: true)
                    
                    print("User created")
                    self.signInUser( email:email,password: password)
                    if let authData = user {
                        ProgressHUD.show(authData.user.email)
                        
                        let dic: Dictionary<String,Any> = [
                            "uid" : authData.user.uid ,
                            "email": authData.user.email as Any ,
                            "buisness name": fullname
                      
                        ]
                        
                        Database.database().reference().child(REF_BUISNESSUSER).child(authData.user.uid).updateChildValues(dic,withCompletionBlock: {(error,ref) in
                            if error == nil {
                                print("done")
                            }
                        })
                    }
                }else{
                    ProgressHUD.showError(error!.localizedDescription)
                }
            }
        }
    }
    
    func signInUser ( email:String  , password: String){
        
        if  self.emailTF.text == "" || self.passwordTF.text == "" {
            print("please fill all fields")
        }
        else {
            Auth.auth().signIn(withEmail: self.emailTF.text!, password: self.passwordTF.text!){
                (user,error)in
                
                if error == nil {
                    Api.BuisUser.isBuisUserOnline(bool: true)
                    if !self.userLat.isEmpty && !self.userLong.isEmpty {
                        let location: CLLocation = CLLocation(latitude: CLLocationDegrees(Double(self.userLat)!), longitude: CLLocationDegrees(Double(self.userLong)!))
                        self.geoFireRef = Ref().databaseGeo
                        self.geoFire = GeoFire(firebaseRef: self.geoFireRef)
                        self.geoFire.setLocation(location, forKey: Api.BuisUser.currentUserId)
                    }
                    
                    print("you are succesfully signed in")
                    self.userDefault.set(true, forKey: "buisnessUserSignedinwithemail")
                    self.userDefault.synchronize()
                    
                    
                    (UIApplication.shared.delegate as! AppDelegate).configureInitialViewController()
                    
                    
                    
                }
                else{
                    print(error as Any)
                    print(error?.localizedDescription as Any)
                }
            }
        }
        
    }
    
  

}

