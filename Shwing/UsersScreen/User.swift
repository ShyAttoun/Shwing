//
//  User.swift
//  Shwing
//
//  Created by shy attoun on 22/09/2019.
//  Copyright © 2019 shy attoun. All rights reserved.
//

import Foundation
import UIKit


class User  {
    
    static var currentUser: User?
    
    var uid: String
    var fullname: String
    var email: String
    var profileImageurl: String
    var profileImageurl1: String
    var profileImageurl2: String
    var profileImageurl3: String
    var profileImageurl4: String
    var profileImage = UIImage ()
    var status: String
    var age: Int?
    var isMale: Bool?
    var longitude = ""
    var latidude = ""
    var myStatus: UserStatus
    var searchForStatus: UserStatus
    var minAgeRange: Int?
    var maxAgeRange: Int?

    init(uid: String, fullname: String , email: String ,  profileImageurl: String , status: String, myStatus: UserStatus, searchForStatus: UserStatus ,profileImageurl1: String , profileImageurl2: String,profileImageurl3: String,profileImageurl4: String){
        
        self.uid = uid
        self.fullname = fullname
        self.email = email
        self.profileImageurl = profileImageurl
        self.status = status
        self.myStatus = myStatus
        self.searchForStatus = searchForStatus
        self.profileImageurl1 = profileImageurl1
        self.profileImageurl2 = profileImageurl2
        self.profileImageurl3 = profileImageurl3
        self.profileImageurl4 = profileImageurl4
      
    }

    static func transformUser (dict: [String: Any]) -> User? {
        guard let email = dict["email"] as? String,
        let fullname = dict["fullname"] as? String,
        let uid = dict["uid"] as? String,
        let profileImageurl = dict["profileImageurl"] as? String,
        let status = dict["status"] as? String,
        let myStatusStr = dict["myStatus"] as? String,
        let searchForStatusStr = dict["searchForStatus"] as? String,
        let profileImageurl1 = dict["profileImageurl1"] as? String,
        let profileImageurl2 = dict["profileImageurl2"] as? String,
        let profileImageurl3 = dict["profileImageurl3"] as? String,
        let profileImageurl4 = dict["profileImageurl4"] as? String
        else{
                return nil
        
        }
        
        let myStatus = UserStatus(rawValue: myStatusStr)!
        let searchForStatus = UserStatus(rawValue: searchForStatusStr)!
        
        let user = User(uid: uid, fullname: fullname, email: email, profileImageurl: profileImageurl, status: status, myStatus: myStatus, searchForStatus: searchForStatus, profileImageurl1: profileImageurl1, profileImageurl2: profileImageurl2, profileImageurl3: profileImageurl3, profileImageurl4: profileImageurl4)
        
        if let isMale = dict["isMale"] as? Bool {
            user.isMale = isMale
        }
        if let age = dict["age"] as? Int {
            user.age = age
        }
        
        if let latitude = dict ["current_latitude"] as? String {
            user.latidude = latitude
        }
        
        if let longitude = dict ["current_longitude"] as? String {
            user.longitude = longitude
        }
        if let minAgeRange = dict["minimum age range"] as? Int {
            user.minAgeRange = minAgeRange
        }
        
        if let maxAgeRange = dict["maximum age range"] as? Int {
            user.maxAgeRange = maxAgeRange
        }
        
        
        return user
    }
    
    func toDict() -> [String: Any] {
        var dict = [String: Any]()
        dict["uid"] = uid
        dict["fullname"] = fullname
        dict["email"] = email
        dict["profileImageurl"] = profileImageurl
        dict["profileImageurl1"] = profileImageurl1
        dict["profileImageurl2"] = profileImageurl2
        dict["profileImageurl3"] = profileImageurl3
        dict["profileImageurl4"] = profileImageurl4
        dict["profileImage"] = profileImage
        dict["status"] = status
        dict["age"] = age
        dict["isMale"] = isMale
        dict["current_longitude"] = longitude
        dict["current_latidude"] = latidude
        dict["myStatus"] = myStatus
        dict["searchForStatus"] = searchForStatus
        dict["minimum age range"] = minAgeRange
        dict["maximum age range"] = maxAgeRange
        return dict
    }

        
    func updateData(key: String, value: Any) {
        switch key {
        case "fullname": self.fullname  = value as! String
        case "email": self.email = value as! String
        case "profileImageurl": self.profileImageurl = value as! String
        case "profileImageurl1": self.profileImageurl1 = value as! String
        case "profileImageurl2": self.profileImageurl2 = value as! String
        case "profileImageurl3": self.profileImageurl3 = value as! String
        case "profileImageurl4": self.profileImageurl4 = value as! String
        case "status": self.status = value as! String
        case "myStatus": self.myStatus = UserStatus(rawValue: value as! String)!
        case "searchForStatus": self.searchForStatus = UserStatus(rawValue: value as! String)!
        default: break
        }
    }
}


