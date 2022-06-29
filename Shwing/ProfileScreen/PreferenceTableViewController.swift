//
//  PreferenceTableViewController.swift
//  Shwing
//
//  Created by shy attoun on 18/10/2019.
//  Copyright © 2019 shy attoun. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseCore
import Firebase
import GoogleSignIn
import FBSDKLoginKit
import FBSDKShareKit
import FBSDKCoreKit
import MessageUI
import Lottie
import FirebaseStorage
import RangeSeekSlider
import ProgressHUD

class PreferenceTableViewController: UITableViewController {

    var myStatus: String = ""
    var mySearchStatus: String = ""
    var searchingstatus : String = ""
    var interstsStatus : String = ""
    var image: UIImage? = nil
    var currentUser = Auth.auth().currentUser


    
    @IBOutlet weak var myStatusSeg: UISegmentedControl!
    @IBOutlet weak var interestedSeg: UISegmentedControl!
    @IBOutlet weak var searchStatusSeg: UISegmentedControl!
    
    @IBOutlet weak var distanceSlider: UISlider!
    @IBOutlet weak var distanceLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//         observeData()

    }
  
    
//    @IBAction func SearchRadiusSlider(_ sender: UISlider) {
//        distanceLbl.text = String(Int(sender.value))
//        print(distanceLbl.text)
//
//    }

    @IBAction func interestedActionSeg(_ sender: Any) {
        if interestedSeg.selectedSegmentIndex == 0 {
            interstsStatus = "Men"
            print(interstsStatus)
        }
        else if interestedSeg.selectedSegmentIndex == 1 {
            interstsStatus = "Women"
            print(interstsStatus)
        }
        else if interestedSeg.selectedSegmentIndex == 2 {
            interstsStatus = "Both"
            print(interstsStatus)
        }
    }
    
    @IBAction func myStatusSeg(_ sender: Any) {
        if myStatusSeg.selectedSegmentIndex == 0 {
            myStatus = "Local"
            print(myStatus)
        }
        else if myStatusSeg.selectedSegmentIndex == 1 {
            myStatus = "Tourist"
            print(myStatus)
        }
        else if myStatusSeg.selectedSegmentIndex == 2 {
            myStatus = "New in town"
            print(myStatus)
        }
    }
    
    @IBAction func SearchingStatusSeg(_ sender: Any) {
        if searchStatusSeg.selectedSegmentIndex == 0 {
            mySearchStatus = "Local"
            print(mySearchStatus)
        }
        else if searchStatusSeg.selectedSegmentIndex == 1 {
            mySearchStatus = "Tourist"
            print(mySearchStatus)
        }
        else if searchStatusSeg.selectedSegmentIndex == 2 {
            mySearchStatus = "New in town"
            print(mySearchStatus)
        }
    }
    
    
   
    @IBAction func SaveBtnIsTapped(_ sender: Any) {
        ProgressHUD.show("Saving...")
        userPreferences()
    }
    
//    func observeData() {
//        Api.Preference.getUserInforSingleEventer(uid: Api.User.currentUserId) { (preference) in
//            self.myStatus = preference.mystatus
//            self.mySearchStatus = preference.mysearchstatus
////            self.userAgeLbl.text = preference.age
////            self.genderPick = preference.gender
//            self.distanceLbl.text = preference.searchRange
//            self.interstsStatus = preference.intersetedin
//
//
//            print(preference)
//        }
//
//    }
    
    func userPreferences() {
    
        if let authData = currentUser {
           
            var dic: Dictionary<String,Any> = [
                "mystatus" : myStatus,
                "mysearchstatus": mySearchStatus,
                "searchrange": distanceLbl.text as Any ,
                "agerange" : "" ,
                "intersetedin" : interstsStatus
            ]
            
          
            
            Database.database().reference().child(REF_USER).child(currentUser!.uid).child("preferences").updateChildValues(dic,withCompletionBlock: {(error,ref) in
                if error == nil {
                    ProgressHUD.dismiss()
                    print("done")
                }
    
            
        }
    )}
    

    }

}
