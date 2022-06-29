//
//  PreferenceApi.swift
//  Shwing
//
//  Created by shy attoun on 18/10/2019.
//  Copyright © 2019 shy attoun. All rights reserved.
//

import Foundation
import FirebaseAuth
import Firebase
import ProgressHUD
import FirebaseStorage

class PreferncesApi {
    
    var currentUserId: String {
        return Auth.auth().currentUser != nil ? Auth.auth().currentUser!.uid : ""
    }
    func observeUsers(onSuccess: @escaping(PrefCompletion)) {
        Ref().databaseUsers.observe(.childAdded) { (snapshot) in
            if let dict = snapshot.value as? Dictionary<String, Any> {
                if let preference = Preferences.transformUser(dict: dict) {
                    onSuccess(preference)
                }
            }
        }
    }
    
//    func getUserInforSingleEventer(uid: String, onSuccess: @escaping(PrefCompletion)) {
////        let ref = Ref().databaseSpecificUserandPref(uid: uid)
//        ref.observeSingleEvent(of: .value) { (snapshot) in
//            if let dict = snapshot.value as? Dictionary<String, Any> {
//                if let preference = Preferences.transformUser(dict: dict){
//                    
//                    onSuccess(preference)
//                }
//            }
//        }
//    }
    
    
}
typealias PrefCompletion = (Preferences) -> Void
