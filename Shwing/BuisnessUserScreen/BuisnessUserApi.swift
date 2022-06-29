//
//  BuisnessUserApi.swift
//  Shwing
//
//  Created by shy attoun on 12/11/2019.
//  Copyright © 2019 shy attoun. All rights reserved.
//

import Foundation
import FirebaseAuth
import Firebase
import ProgressHUD
import FirebaseStorage

class BuisnessUserApi {
    
    var currentUserId: String {
        return Auth.auth().currentUser != nil ? Auth.auth().currentUser!.uid : ""
    }
    
    func signIn(email: String, password: String, onSuccess: @escaping() -> Void, onError: @escaping(_ errorMessage: String) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { (authData, error) in
            if error != nil {
                onError(error!.localizedDescription)
                return
            }
            
            onSuccess()
        }
    }
    
    func signUp (withUsername username: String, email: String, password: String, image: UIImage?, onSuccess: @escaping() -> Void, onError: @escaping(_ errorMessage: String) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { (authDataResult, error) in
            if error != nil {
                ProgressHUD.showError(error!.localizedDescription)
                
                return
            }
            if let authData = authDataResult {
                print(authData.user.email)
                let dict: Dictionary<String, Any> =  [
                    UID: authData.user.uid,
                    EMAIL: authData.user.email!,
                    USERNAME: username
                ]
                
                guard let imageSelected = image else {
                    ProgressHUD.showError(ERROR_EMPTY_PHOTO)
                    
                    return
                }
                
                guard let imageData = imageSelected.jpegData(compressionQuality: 0.4) else {
                    return
                }
                
                let storageProfile = Ref().storageSpecificProfile(uid: authData.user.uid)
                
                let metadata = StorageMetadata()
                metadata.contentType = "image/jpg"
                
                StorageService.savePhoto(username: username, uid: authData.user.uid, data: imageData, metadata: metadata, storageProfileRef: storageProfile, dict: dict, onSuccess: {
                    onSuccess()
                }, onError: { (errorMessage) in
                    onError(errorMessage)
                })
                
            }
        }
    }
    
    func saveBuisUserProfile(dict: Dictionary<String, Any>,  onSuccess: @escaping() -> Void, onError: @escaping(_ errorMessage: String) -> Void) {
        Ref().databaseSpecificBuisUser(uid: Api.BuisUser.currentUserId).updateChildValues(dict) { (error, dataRef) in
            if error != nil {
                onError(error!.localizedDescription)
                return
            }
            onSuccess()
        }
    }
    

    func resetPassword(email: String, onSuccess: @escaping() -> Void, onError: @escaping(_ errorMessage: String) -> Void) {
        Auth.auth().sendPasswordReset(withEmail: email) { (error) in
            if error == nil {
                onSuccess()
            } else {
                onError(error!.localizedDescription)
            }
        }
    }
    

    func observeUsers(onSuccess: @escaping(BuisUserCompletion)) {
        Ref().databaseBuisnessUsers.observe(.childAdded) { (snapshot) in
            if let dict = snapshot.value as? Dictionary<String, Any> {
                if let user = BuisnessUser.transformBuissUser(dict: dict) {
                    onSuccess(user)
                }
            }
        }
    }
    func getUserInfor(uid: String, onSuccess: @escaping(BuisUserCompletion)) {
        let ref = Ref().databaseSpecificBuisUser(uid: uid)
        ref.observe(.value) { (snapshot) in
            if let dict = snapshot.value as? Dictionary<String, Any> {
                if let user = BuisnessUser.transformBuissUser(dict: dict) {
                    onSuccess(user)
                }
            }
        }
    }
 
    
    func getBuisUserInforSingleEvent(uid: String, onSuccess: @escaping(BuisUserCompletion)) {
        let ref = Ref().databaseSpecificBuisUser(uid: uid)
        ref.observeSingleEvent(of: .value) { (snapshot) in
            if let dict = snapshot.value as? Dictionary<String, Any> {
                if let user = BuisnessUser.transformBuissUser(dict: dict) {
                    onSuccess(user)
                }
            }
        }
    }
    

    
    func isBuisUserOnline(bool: Bool) {
        if !Api.BuisUser.currentUserId.isEmpty {
            let ref = Ref().databaseOfBUIsOnline(uid: Api.BuisUser.currentUserId)
            let dict: Dictionary<String, Any> = [
                "online": bool as Any,
                "latest": Date().timeIntervalSince1970 as Any
            ]
            ref.updateChildValues(dict)
        }
    }
    
    func isOnline(bool: Bool) {
        if !Api.BuisUser.currentUserId.isEmpty {
            let ref = Ref().databaseIsOnline(uid: Api.BuisUser.currentUserId)
            let dict: Dictionary<String, Any> = [
                "online": bool as Any,
                "latest": Date().timeIntervalSince1970 as Any
            ]
            ref.updateChildValues(dict)
        }
    }
    
    func typing(from: String, to: String) {
        let ref = Ref().databaseIsOnline(uid: from)
        let dict: Dictionary<String, Any> = [
            "typing": to
        ]
        ref.updateChildValues(dict)
    }
}



typealias BuisUserCompletion = (BuisnessUser) -> Void
