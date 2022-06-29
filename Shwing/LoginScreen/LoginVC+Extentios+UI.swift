//
//  LoginVC+Extentios+UI.swift
//  Shwing
//
//  Created by shy attoun on 16/10/2019.
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

extension LoginViewController {
    
    func setupProfileImage () {
  
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
    }
    
    @objc func dismissKeyboard () {
        view.endEditing(true)
    }
    
  func outletsSetup() {
        userEmail.layer.cornerRadius = 20
        userPassword.layer.cornerRadius = 20
        loginBtnView.layer.cornerRadius = 20
        fbBtnView.layer.cornerRadius = 20
        googleBtnview.layer.cornerRadius = 20
    }
    func FBsignInBtn() {
        
        let fbLoginManager = LoginManager ()
        fbLoginManager.logIn(permissions: ["public_profile","email"], from: self) { (result, error) in
            if let error = error {
                ProgressHUD.showError(error.localizedDescription)
                return
            }
            guard let accessToken = AccessToken.current else {
                ProgressHUD.showError("Failed to get access token")
                return
            }
             let credemtial  = FacebookAuthProvider.credential(withAccessToken: accessToken.tokenString)
            Auth.auth().signInAndRetrieveData(with: credemtial, completion: { (result, error) in
                if let error = error {
                    ProgressHUD.showError(error.localizedDescription)
                    return
                }
                if let authData = result {
                   self.handleFbGoogleLogic(authData: authData)
                }
            })
        }
        

    }
    
    func configureLocationManager () {
    manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = kCLDistanceFilterNone
        manager.pausesLocationUpdatesAutomatically = true
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            manager.startUpdatingLocation()
        }
    }
}

extension LoginViewController : CLLocationManagerDelegate {
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
    }
}
