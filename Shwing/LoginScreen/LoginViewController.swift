//
//  LoginViewController.swift
//  Shwing
//
//  Created by shy attoun on 08/09/2019.
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


class LoginViewController : UIViewController ,LoginButtonDelegate,GIDSignInUIDelegate,GIDSignInDelegate{

    let userDefault = UserDefaults.standard
  
    
    @IBOutlet weak var viewStackTopConst: NSLayoutConstraint!
    @IBOutlet weak var loginBtnView: UIButton!
    @IBOutlet weak var googleBtnview: UIButton!
    @IBOutlet weak var fbBtnView: UIButton!
    @IBOutlet weak var buisnessBtn: UIButton!
    
    @IBOutlet var loginVC: UIView!
    @IBOutlet weak var seg: UISegmentedControl!
    
    @IBOutlet weak var fullnameTF: UITextField!
    @IBOutlet weak var userEmail: UITextField!
    @IBOutlet weak var userPassword: UITextField!
    

    var userLat = ""
    var userLong = ""
    let manager = CLLocationManager ()
    var geoFire : GeoFire!
    var geoFireRef: DatabaseReference!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureLocationManager ()
        outletsSetup()
        
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
         googleBtnview.addTarget(self, action: #selector(googleButtonDidTap), for: UIControl.Event.touchUpInside)
        
        setupProfileImage ()
         NotificationCenter.default.addObserver(self, selector: #selector (didSignIn), name: NSNotification.Name("SuccessfulSignInNotification"), object: nil)
        
    }
    
   
    
    @IBAction func segAction(_ sender: Any) {
        if seg.selectedSegmentIndex == 0 {
            
            fullnameTF?.isHidden = true
            viewStackTopConst.constant = 20
            loginBtnView.setTitle("LOGIN", for: UIControl.State.normal)
            
        }else if seg.selectedSegmentIndex == 1{
            fullnameTF?.isHidden = false
            viewStackTopConst.constant = 60
            loginBtnView.setTitle("SIGN UP", for: UIControl.State.normal)
        }
    }
    
    @IBAction func buisnessSignUpBtnTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "BuisnessStoryboard", bundle: nil)
        if let  wtvc = storyboard.instantiateViewController(withIdentifier: "BuisnessLoginController") as? BuisnessLoginViewController {
            present(wtvc, animated: true, completion: nil)
        }
        
    }
    
    @IBAction func loginBtnAction(_ sender: Any) {
        
        if let userLat = userDefault.value(forKey: "current_location_latitude") as? String, let userLong = userDefault.value(forKey: "current_location_longitude") as? String {
            self.userLat = userLat
            self.userLong = userLong
        }
        
        if seg.selectedSegmentIndex == 0 {
            
            signInUser(email:userEmail.text!,password: userPassword.text!)
            Api.User.isOnline(bool: true)
           
            
        }else if seg.selectedSegmentIndex == 1 {
            createUser(fullname:fullnameTF.text!,email:userEmail.text!,password: userPassword.text!)
            Api.User.isOnline(bool: true)

        }
    }
    
    
    @objc func googleButtonDidTap () {
        GIDSignIn.sharedInstance().signIn()
    }
    
  
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if error != nil {
            return
        }
        guard let authentication = user.authentication else {
            return
        }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
        
        Auth.auth().signInAndRetrieveData(with: credential) { (result, error) in
            if let error = error {
                ProgressHUD.showError(error.localizedDescription)
                return
            }
            if let authData = result {
                self.handleFbGoogleLogic(authData: authData)
            }
        }
    }
    
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        ProgressHUD.showError(error.localizedDescription)

    }
    
    func handleFbGoogleLogic(authData: AuthDataResult) {
        let dict: Dictionary <String, Any > = [
            "uid": authData.user.uid ,
            "email": authData.user.email,
            "fullname": authData.user.displayName,
            "profileImageurl" : (authData.user.photoURL == nil ) ? "" :
                authData.user.photoURL?.absoluteString,
            "status": "hey"
        ]
        
        Ref().databaseSpecificUser(uid: authData.user.uid).updateChildValues(dict, withCompletionBlock: { (error, ref) in
            if error == nil {
                Api.User.isOnline(bool: true)
                (UIApplication.shared.delegate as! AppDelegate).configureInitialViewController()
                
                
            } else {
                ProgressHUD.showError(error!.localizedDescription)
       
            }
        })
    }
    
    
    @IBAction func signInWithFBBtn(_ sender: Any) {
        FBsignInBtn()
    }
    
    @objc func didSignIn()  {
        (UIApplication.shared.delegate as! AppDelegate).configureInitialViewController()
    }

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        if error != nil {
            print(error?.localizedDescription as Any)
        }else if (result?.isCancelled)! {
            print("User cancelled log in")
        }else{
            print("user LOGGED IN succesfully")
      
           (UIApplication.shared.delegate as! AppDelegate).configureInitialViewController()
         
        }
        if (result?.grantedPermissions.contains("email"))! {
            
        }
    }
    
    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        print("user LOGGED OUT")
        Api.User.isOnline(bool: false)

    }

    func createUser (fullname:String , email:String , password: String) {
        if self.fullnameTF.text == "" || self.userEmail.text == "" || self.userPassword.text == "" {
         
            ProgressHUD.showError("please fill all fields")
        }
        else{
            Auth.auth().createUser( withEmail: email, password: password) {(user,error) in
                if error == nil {
                    Api.User.isOnline(bool: true)

                    print("User created")
                    self.signInUser( email:email,password: password)
                    if let authData = user {
                        ProgressHUD.show(authData.user.email)
                        
                        let dic: Dictionary<String,Any> = [
                            "uid" : authData.user.uid ,
                            "email": authData.user.email as Any ,
                            "fullname": fullname,
                            "profileImageurl": "" ,
                            "status" : ""
                        
                        ]
                        
                        Database.database().reference().child(REF_USER).child(authData.user.uid).updateChildValues(dic,withCompletionBlock: {(error,ref) in
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
        
        if  self.userEmail.text == "" || self.userPassword.text == "" {
            print("please fill all fields")
        }
        else {
            Auth.auth().signIn(withEmail: self.userEmail.text!, password: self.userPassword.text!){
                (user,error)in
                
                if error == nil {
                    Api.User.isOnline(bool: true)
                    if !self.userLat.isEmpty && !self.userLong.isEmpty {
                        let location: CLLocation = CLLocation(latitude: CLLocationDegrees(Double(self.userLat)!), longitude: CLLocationDegrees(Double(self.userLong)!))
                        self.geoFireRef = Ref().databaseGeo
                        self.geoFire = GeoFire(firebaseRef: self.geoFireRef)
                        self.geoFire.setLocation(location, forKey: Api.User.currentUserId)
                    }
                    
                    print("you are succesfully signed in")
                    self.userDefault.set(true, forKey: "usersignedinwithemail")
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



//        let homePage = self.storyboard?.instantiateViewController(withIdentifier: "HomeViewController")
//
//        let homePageNav = UINavigationController (rootViewController: homePage!)
//
//        let appDelegate = UIApplication.shared.delegate as! AppDelegate
//
//        appDelegate.window?.rootViewController = homePageNav





