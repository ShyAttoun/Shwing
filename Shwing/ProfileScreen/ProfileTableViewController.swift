//
//  ProfileTableViewController.swift
//  Shwing
//
//  Created by shy attoun on 03/10/2019.
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




class ProfileTableViewController: UITableViewController {

    let userDefault = UserDefaults.standard

    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var usernameLbl: UITextField!
    @IBOutlet weak var emailLbl: UITextField!
    @IBOutlet weak var statusLbl: UITextField!
    @IBOutlet weak var genderSeg: UISegmentedControl!
    @IBOutlet weak var myStatusSeg: UISegmentedControl!
    @IBOutlet weak var mySearchSeg: UISegmentedControl!
    @IBOutlet weak var ageRangeSlider: RangeSeekSlider!
    @IBOutlet weak var myAgeSlider: UISlider!
    @IBOutlet weak var profileImage1: UIImageView!
    @IBOutlet weak var profileImage2: UIImageView!
    @IBOutlet weak var profileImage3: UIImageView!
    @IBOutlet weak var profileImage4: UIImageView!
    
    
    @IBOutlet weak var userAgeLbl: UILabel!
    

    var flag = 0
    var maxValue = 70
    var minValue = 18
    var genderPick : String? = ""
    var myStatus: String = ""
    var image: UIImage? = nil
    var image1: UIImage? = nil
    var image2: UIImage? = nil
    var image3: UIImage? = nil
    var image4: UIImage? = nil
    var currentUser = Auth.auth().currentUser
    private let userStatuses = UserStatus.allValues
    let btnImage = UIImage(named: "add-image") as UIImage?

    
    override func awakeFromNib() {
        self.view.layoutIfNeeded()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for (index, status) in userStatuses.enumerated() {
            self.myStatusSeg.setTitle(status.rawValue, forSegmentAt: index)
            self.mySearchSeg.setTitle(status.rawValue, forSegmentAt: index)
        }
        self.setupProfileImage ()
        self.observeData()
    }

    func observeData() {
        Api.User.getUserInforSingleEvent(uid: Api.User.currentUserId) { (user) in
            self.avatar.loadImage(user.profileImageurl)
            self.profileImage1.loadImage(user.profileImageurl1)
            self.profileImage2.loadImage(user.profileImageurl2)
            self.profileImage3.loadImage(user.profileImageurl3)
            self.profileImage4.loadImage(user.profileImageurl4)

            self.statusLbl.text = user.status
            self.emailLbl.text = user.email
            self.usernameLbl.text = user.fullname
            self.ageRangeSlider.minValue = 18
            self.ageRangeSlider.maxValue = 70
            self.ageRangeSlider.selectedMinValue = CGFloat(user.minAgeRange!)
            self.ageRangeSlider.selectedMaxValue = CGFloat(user.maxAgeRange!)
            
            print(self.ageRangeSlider.minValue)

            
            if let age = user.age {
                self.userAgeLbl.text = "\(age)"
                self.myAgeSlider.value = Float(age)
            }else{
                self.userAgeLbl.text = ""
            }
            if let isMale = user.isMale {
                self.genderSeg.selectedSegmentIndex = (isMale == true) ? 0 : 1
            }
            
            self.myStatusSeg.selectedSegmentIndex = user.myStatus.myIndex
            self.mySearchSeg.selectedSegmentIndex = user.searchForStatus.myIndex
            
            User.currentUser = user
            
        }
}
    
    
    @IBAction func ageActionSlider(_ sender: UISlider) {
        userAgeLbl.text = String(Int(sender.value))

    }
  
    @IBAction func logoutBtnIsTapped(_ sender: Any) {
        signOutFromApp()
        
    }
    
    @IBAction func backToInterestsBtn(_ sender: Any) {
        let storyboard = UIStoryboard(name: "UserDetailsStoryBoard", bundle: nil)
        if let  wtvc = storyboard.instantiateViewController(withIdentifier: "WTVC") as? UserDetailsViewController {
           present(wtvc, animated: true, completion: nil)
        }
    }
    
    @IBAction func saveSettings(_ sender: Any) {
        ProgressHUD.show("Saving...")
        //         userSetting()
        
        var dict = Dictionary<String, Any>()
        
        if let fullname = usernameLbl.text, !fullname.isEmpty {
            dict["fullname"] = fullname
        }
        if let email = emailLbl.text, !email.isEmpty {
            dict["email"] = email
        }
        if let status = statusLbl.text, !status.isEmpty {
            dict["status"] = status
        }
        if let age = userAgeLbl.text, !age.isEmpty {
            dict["age"] = Int(age)
        }
        if genderSeg.selectedSegmentIndex == 0 {
            dict["isMale"] = true
        }
        if genderSeg.selectedSegmentIndex == 1 {
            dict["isMale"] = false
        }
        if minValue >= 18 && maxValue <= 80 {
            
            minValue = Int(ageRangeSlider.selectedMinValue.rounded())
            maxValue = Int(ageRangeSlider.selectedMaxValue.rounded())
            dict["minimum age range"] = minValue
            dict["maximum age range"] = maxValue
           
        }
        dict["myStatus"] = userStatuses[myStatusSeg.selectedSegmentIndex].rawValue
        dict["searchForStatus"] = userStatuses[mySearchSeg.selectedSegmentIndex].rawValue
        
        
        Api.User.saveUserProfile(dict: dict, onSuccess: {

            print("IM HERE BABAY!")
            if let img = self.image {
                StorageService.savePhotoProfile(image: img, onSuccess: {
                    ProgressHUD.showSuccess()

                }) { (errorMessage) in
                    ProgressHUD.showError(errorMessage)
                }
            }

    
            if let img = self.profileImage1.image {
                StorageService.savePhotoProfile1(image: img, onSuccess: {
                    ProgressHUD.showSuccess()

                }) { (errorMessage) in
                    ProgressHUD.showError(errorMessage)
                }
            } else {
                ProgressHUD.showSuccess()

            }
            if let img = self.profileImage2.image {
                StorageService.savePhotoProfile2(image: img, onSuccess: {
                    ProgressHUD.showSuccess()

                }) { (errorMessage) in
                    ProgressHUD.showError(errorMessage)
                }
            } else {
                ProgressHUD.showSuccess()

            }
            if let img = self.profileImage3.image {
                StorageService.savePhotoProfile3(image: img, onSuccess: {
                    ProgressHUD.showSuccess()

                }) { (errorMessage) in
                    ProgressHUD.showError(errorMessage)
                }
            } else {
                ProgressHUD.showSuccess()

            }
            if let img = self.profileImage4.image {
                StorageService.savePhotoProfile4(image: img, onSuccess: {
                    ProgressHUD.showSuccess()

                }) { (errorMessage) in
                    ProgressHUD.showError(errorMessage)
                }
            } else {
                ProgressHUD.showSuccess()

            }

        }) { (errorMessage) in
            ProgressHUD.showError(errorMessage)
        }
    }



}
