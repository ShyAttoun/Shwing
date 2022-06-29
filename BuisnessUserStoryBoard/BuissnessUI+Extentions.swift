//
//  BuissnessUI+Extentions.swift
//  Shwing
//
//  Created by shy attoun on 26/12/2019.
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
import CoreLocation
import GeoFire
import DKImagePickerController


extension BuisnessProfileTableViewController {
    
    func setupProfileImages () {
        
    
        logoImage.image = logoImageBG
        logoImage.layer.cornerRadius = 40
        logoImage.clipsToBounds = true
        logoImage.isUserInteractionEnabled = true
        let pi1Ges = UITapGestureRecognizer(target: self, action: #selector(pi1Action))
        logoImage.addGestureRecognizer(pi1Ges)
        
        interiorImage.image = interiorImageBG
        interiorImage.layer.cornerRadius = 40
        interiorImage.clipsToBounds = true
        interiorImage.isUserInteractionEnabled = true
        let pi2Ges = UITapGestureRecognizer(target: self, action: #selector(pi2Action))
        interiorImage.addGestureRecognizer(pi2Ges)
        
        entranceImage.image = entranceImageBG
        entranceImage.layer.cornerRadius = 40
        entranceImage.clipsToBounds = true
        entranceImage.isUserInteractionEnabled = true
        let pi3Ges = UITapGestureRecognizer(target: self, action: #selector(pi3Action))
        entranceImage.addGestureRecognizer(pi3Ges)
        
        conceptImage.layer.cornerRadius = 40
        conceptImage.clipsToBounds = true
        conceptImage.isUserInteractionEnabled = true
        conceptImage.image = conceptImageBG
        let pi4Ges = UITapGestureRecognizer(target: self, action: #selector(pi4Action))
        conceptImage.addGestureRecognizer(pi4Ges)
        
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
                       self.logoImage.image = fixOrientationImage
                  
                  case 1:
                   let fixOrientationImage = image
                       print(fixOrientationImage as Any)
                       self.interiorImage.image = fixOrientationImage

                   
                   case 2:
                       let fixOrientationImage = image
                       self.entranceImage.image = fixOrientationImage

                   
                   case 3:
                       let fixOrientationImage = image
                       print(fixOrientationImage as Any)
                       self.conceptImage.image = fixOrientationImage

                   
                   default:
                       break
                   
                   }
               })
           }
       }
       self.present(pickerController, animated: true) {}
      
       }
    
    
    
}

extension BuisnessProfileTableViewController: UIPickerViewDelegate,UIPickerViewDataSource{
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        //typeOfBuisPicker
        if pickerView.tag == 0 {
            return typesOfBuisnesses.count
        } else {
            return typesOfBuisnesses[typeOfBuisPicker.selectedRow(inComponent: component)].myArray.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        //typeOfBuisPicker
        if pickerView.tag == 0 {
            return typesOfBuisnesses[row].description
        } else {
            return ganeresOfBuisnesses[row]
            
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == 0 {
            
            ganeresOfBuisnesses = typesOfBuisnesses[row].myArray
            ganereBuisPicker.reloadComponent(0)
            ganereBuisPicker.selectRow(0, inComponent: 0, animated: false)
            if row != 0 && typesOfBuisnesses.first! == .chooseYourType {
                typesOfBuisnesses.remove(at: 0)
                pickerView.reloadComponent(0)
                pickerView.selectRow(row - 1, inComponent: 0, animated: false)

            }
            
        }
    }
}


extension BuisnessProfileTableViewController: UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    func configureLocationManager () {
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = kCLDistanceFilterNone
        manager.pausesLocationUpdatesAutomatically = true
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            manager.startUpdatingLocation()
        }
        self.geoFireRef = Ref().databaseGeo
               self.geoFire = GeoFire(firebaseRef: self.geoFireRef)
    }
    
    func userSetting () {
        guard let imageSelected = self.image else {
            print(" image is empty")
            return}
        
        guard let imageData = imageSelected.jpegData(compressionQuality: 0.4) else {return}
        if let authData = currentUser {
            ProgressHUD.show(currentUser?.email)
            var dic: Dictionary<String,Any> = [
                "uid" : authData.uid ,
                "email": authData.email,
                "buisness name": buisnessNameTF.text,
                "buisness logo image": conceptImage
            ]
            
            let storageRef = Storage.storage().reference(forURL: "gs://shwing-8a339.appspot.com")
            let storageProfileRef = storageRef.child(STORAGE_BUISNESS_PROFILE).child(Api.BuisUser.currentUserId).child(authData.uid)
            
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpg"
            storageProfileRef.putData(imageData, metadata: metadata, completion: {
                
                (StorageMetadata,error) in
                
                if error != nil {
                    
                    print(error?.localizedDescription)
                    return
                }
                storageProfileRef.downloadURL(completion:{ (url,error) in
                    if let metaImageUrl =  url?.absoluteString {
                        dic["buisness logo image"] = metaImageUrl
                        Database.database().reference().child(REF_BUISNESSUSER).child(authData.uid).updateChildValues(dic,withCompletionBlock: {(error,ref) in
                            if error == nil {
                                print("done")
                                ProgressHUD.dismiss()
                            }
                        })
                    }
                })
            })
            
        }
    }
}

extension BuisnessProfileTableViewController : CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if (status == .authorizedAlways) || (status == .authorizedWhenInUse) {
            manager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        ProgressHUD.showError("\(error.localizedDescription)")
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let updatedLocation: CLLocation = locations.first!
        let newCoordinate:CLLocationCoordinate2D = updatedLocation.coordinate
        print(newCoordinate.latitude)
        print(newCoordinate.longitude)
        
        userDefault.set("\(newCoordinate.latitude)", forKey: "current_location_latitude")
        userDefault.set("\(newCoordinate.longitude)", forKey: "current_location_longitude")
        userDefault.synchronize()
        
                if let userLat = userDefault.value(forKey: "current_location_latitude") as? String, let userLong = userDefault.value(forKey: "current_location_longitude") as? String {
                    let location: CLLocation = CLLocation(latitude: CLLocationDegrees(Double(userLat)!), longitude: CLLocationDegrees(Double(userLong)!))
                    Ref().databaseSpecificBuisUser(uid: Api.BuisUser.currentUserId).updateChildValues([LAT:userLat , LONG: userLong])
                    
                    self.geoFire.setLocation(location, forKey: Api.BuisUser.currentUserId) {(error) in
                        if error == nil {
                            //find users
                            //                    self.findUsers()
                        }
                        
                    }
                    
                }
            }
    
}
