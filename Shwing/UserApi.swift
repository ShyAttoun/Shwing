//
//  MessageApi.swift
//  Shwing
//
//  Created by shy attoun on 14/10/2019.
//  Copyright © 2019 shy attoun. All rights reserved.
//

import Foundation
import FirebaseAuth
import Firebase
import ProgressHUD
import FirebaseStorage

class UserApi {
    
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
                    USERNAME: username,
                    PROFILE_IMAGE_URL: "",
                    STATUS: "Welcome to JChat"
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
    
    func resetPassword(email: String, onSuccess: @escaping() -> Void, onError: @escaping(_ errorMessage: String) -> Void) {
        Auth.auth().sendPasswordReset(withEmail: email) { (error) in
            if error == nil {
                onSuccess()
            } else {
                onError(error!.localizedDescription)
            }
        }
    }
    
    func logOut() {
        do {
            try Auth.auth().signOut()
        } catch {
            ProgressHUD.showError(error.localizedDescription)
            return
        }
        (UIApplication.shared.delegate as! AppDelegate).configureInitialViewController()
        
    }
    
    func observeUsers(onSuccess: @escaping(UserCompletion)) {
        Ref().databaseUsers.observe(.childAdded) { (snapshot) in
            if let dict = snapshot.value as? Dictionary<String, Any> {
                if let user = User.transformUser(dict: dict) {
                    onSuccess(user)
                }
            }
        }
    }
}

typealias UserCompletion = (User) -> Void

