//
//  ProfileVc+UI+Extentions.swift
//  Shwing
//
//  Created by shy attoun on 17/10/2019.
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
import ProgressHUD
import MobileCoreServices
import AVFoundation
import DKImagePickerController

extension ProfileTableViewController {
    
    func setupProfileImage () {
      
        avatar.image = btnImage
        avatar.layer.cornerRadius = 40
        avatar.clipsToBounds = true
        avatar.isUserInteractionEnabled = true
        let pi0Ges = UITapGestureRecognizer(target: self, action: #selector(pi0Action))
        avatar.addGestureRecognizer(pi0Ges)
        
       
        profileImage1.image = btnImage
        profileImage1.layer.cornerRadius = 40
        profileImage1.clipsToBounds = true
        profileImage1.isUserInteractionEnabled = true
        let pi1Ges = UITapGestureRecognizer(target: self, action: #selector(pi1Action))
        profileImage1.addGestureRecognizer(pi1Ges)
        
        profileImage2.image = btnImage
        profileImage2.layer.cornerRadius = 40
        profileImage2.clipsToBounds = true
        profileImage2.isUserInteractionEnabled = true
        let pi2Ges = UITapGestureRecognizer(target: self, action: #selector(pi2Action))
        profileImage2.addGestureRecognizer(pi2Ges)
        
  
        
        profileImage3.layer.cornerRadius = 40
        profileImage3.clipsToBounds = true
        profileImage3.isUserInteractionEnabled = true
        profileImage3.image = btnImage
        let pi3Ges = UITapGestureRecognizer(target: self, action: #selector(pi3Action))
        profileImage3.addGestureRecognizer(pi3Ges)
        
        
        
        profileImage4.layer.cornerRadius = 40
        profileImage4.clipsToBounds = true
        profileImage4.isUserInteractionEnabled = true
        profileImage4.image = btnImage
       let pi4Ges = UITapGestureRecognizer(target: self, action: #selector(pi4Action))
       profileImage4.addGestureRecognizer(pi4Ges)
        
    }
    @objc private func pi0Action() {
        
        presentPicker()
    }
    
    @objc private func pi1Action() {
        self.flag = 0
        presentBSIPicker ()
    }
    
    @objc private func pi2Action() {
        self.flag = 1
        presentBSIPicker ()
    }
    
    @objc private func pi3Action() {
        self.flag = 2
        presentBSIPicker ()
    }
    
    @objc private func pi4Action() {
        self.flag = 3
        presentBSIPicker ()
    }
    @objc func dismissKeyboard () {
        view.endEditing(true)
    }
    
    @objc func presentPicker () {
        view.endEditing(true)
        //TODO: Implement logic when there is no permission
        
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        picker.delegate = self
        self.present(picker,animated: true)
    }
    
    @objc func presentBSIPicker () {
    let pickerController = DKImagePickerController()
        pickerController.assetType = DKImagePickerControllerAssetType.allAssets
        pickerController.allowsLandscape = false
        pickerController.allowMultipleTypes = true
        pickerController.sourceType = DKImagePickerControllerSourceType.both
        pickerController.singleSelect = true

    pickerController.didSelectAssets = { (assets: [DKAsset]) in
        print("didSelectAssets")
        print(assets)
        for asset in assets {
            asset.fetchOriginalImage(options: .none, completeBlock: { image, info in
                
                switch self.flag {
                case 0:
                    let fixOrientationImage = image
                    print(fixOrientationImage as Any)
                    self.profileImage1.image = fixOrientationImage
               
               case 1:
                let fixOrientationImage = image
                    print(fixOrientationImage as Any)
                    self.profileImage2.image = fixOrientationImage

                
                case 2:
                    let fixOrientationImage = image
                    self.profileImage3.image = fixOrientationImage

                
                case 3:
                    let fixOrientationImage = image
                    print(fixOrientationImage as Any)
                    self.profileImage4.image = fixOrientationImage

                
                default:
                    break
                
                }
            })
        }
    }
    self.present(pickerController, animated: true) {}
   
    }

    override func viewDidAppear(_ animated: Bool) {
        if UserDefaults.standard.bool(forKey: "hasViewedWalkthrough"){
            print("view has been viewed before")
            return
        }
        
        let storyboard = UIStoryboard(name: "UserDetailsStoryBoard", bundle: nil)
        if let  wtvc = storyboard.instantiateViewController(withIdentifier: "WTVC") as? UserDetailsViewController {
            present(wtvc, animated: true, completion: nil)
            print("UserDetailsStoryBoard storyboard is on")
        }
    }
    
    @objc func signOutFromApp () {
        let uid = Api.User.currentUserId
        do{
            Api.User.isOnline(bool: false)

            if let providerData = Auth.auth().currentUser?.providerData {
                let userInfo = providerData[0]
                
                switch userInfo.providerID {
                case "google.com":
                    GIDSignIn.sharedInstance()?.signOut()
                default:
                    break
                }
            }
            
            try Auth.auth().signOut()
            Messaging.messaging().unsubscribe(fromTopic: uid)
            
       
        }catch {
            ProgressHUD.showError(error.localizedDescription)
        return
        }
          (UIApplication.shared.delegate as! AppDelegate).configureInitialViewController()
    }
}
extension ProfileTableViewController: UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let imageSelected = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {

                image = imageSelected
                avatar.image = imageSelected
            }
        
        if let imageOriginal = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {

                 image = imageOriginal
                avatar.image = imageOriginal

        }
        
        picker.dismiss(animated: true, completion: nil )
    }
    
    

}


