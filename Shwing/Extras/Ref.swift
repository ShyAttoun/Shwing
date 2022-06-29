//
//  MessageApi.swift
//  Shwing
//
//  Created by shy attoun on 14/10/2019.
//  Copyright © 2019 shy attoun. All rights reserved.
//
import Foundation
import Firebase

let REF_USER = "users"
let REF_MESSAGE = "messages"
let REF_INBOX = "inbox"
let REF_GEO = "Geolocs"
let REF_ACTION = "action"
let REF_BUISNESSUSER = "buisnessuser"

let URL_STORAGE_ROOT = "gs://shwing-8a339.appspot.com"
let STORAGE_PROFILE = "profile"
let STORAGE_BUISNESS_PROFILE = "buisProfile"
let PROFILE_IMAGE_URL = "profileImageurl"
let PROFILE_FIRST_IMAGE_URL = "profileImageurl1"
let PROFILE_SECOND_IMAGE_URL = "profileImageurl2"
let PROFILE_THIRD_IMAGE_URL = "profileImageurl3"
let PROFILE_FOURTH_IMAGE_URL = "profileImageurl4"
let LOGO_IMAGE_URL = "logo image"
let INTERIOR_IMAGE_URL = "interior image"
let ENTRANCE_IMAGE_URL = "entrance image"
let CONCEPT_IMAGE_URL = "concept image"
let UID = "uid"
let EMAIL = "email"
let USERNAME = "username"
let STATUS = "status"
let IS_ONLINE = "isOnline"
let LAT = "current_latitude"
let LONG = "current_longitude"

let ERROR_EMPTY_PHOTO = "Please choose your profile image"
let ERROR_EMPTY_EMAIL = "Please enter an email address"
let ERROR_EMPTY_USERNAME = "Please enter an username"
let ERROR_EMPTY_PASSWORD = "Please enter a password"
let ERROR_EMPTY_EMAIL_RESET = "Please enter an email address for password reset"

let SUCCESS_EMAIL_RESET = "We have just sent you a password reset email. Please check your inbox and follow the instructions to reset your password"

let IDENTIFIER_TABBAR = "TabBarVC"
let IDENTIFIER_WELCOME = "WelcomeVC"
let IDENTIFIER_CHAT = "ChatVC"
let IDENTIFIER_USER_AROUND = "UsersAroundViewController"
let IDENTIFIER_BUISNESS_AROUND = "BuisnessLocationCollectionViewController"
let IDENTIFIER_MAP = "MapViewController"
let IDENTIFIER_BUISNESS_MAP = "BuisnessMapViewController"
let IDENTIFIER_DETAIL = "DetailViewController"
let IDENTIFIER_RADAR = "RadarViewController"
let IDENTIFIER_NEW_MATCH = "NewMatchTableViewController"


let IDENTIFIER_CELL_USERS = "UserTableViewCell"


class Ref {
    var databaseAction: DatabaseReference {
        return databaseRoot.child(REF_ACTION)
    }
    
    func databaseActionForUser(uid: String) -> DatabaseReference {
        return databaseAction.child(uid)
    }
    let databaseRoot: DatabaseReference = Database.database().reference()
    
    var databaseUsers: DatabaseReference {
        return databaseRoot.child(REF_USER)
    }
    func databaseSpecificUser(uid: String) -> DatabaseReference {
        return databaseUsers.child(uid)
    }
    var databaseBuisnessUsers: DatabaseReference {
        return databaseRoot.child(REF_BUISNESSUSER)
    }
    func databaseSpecificBuisUser(uid: String) -> DatabaseReference {
        return databaseBuisnessUsers.child(uid)
    }
   
    
    func databaseOfBUIsOnline(uid: String) -> DatabaseReference {
        return databaseBuisnessUsers.child(uid).child(IS_ONLINE)
    }
    func databaseIsOnline(uid: String) -> DatabaseReference {
        return databaseUsers.child(uid).child(IS_ONLINE)
    }
    
    var databaseMessage: DatabaseReference {
        return databaseRoot.child(REF_MESSAGE)
    }
    
    func databaseMessageSendTo(from: String, to: String) -> DatabaseReference {
        return databaseMessage.child(from).child(to)
    }
    var databaseInbox: DatabaseReference {
        return databaseRoot.child(REF_INBOX)
    }
    
    func databaseInboxInFor (from: String, to: String) -> DatabaseReference {
        return databaseInbox.child(from).child(to)
    }
    
    func databaseInboxInForUser (uid: String) -> DatabaseReference {
        return databaseInbox.child(uid)
    }
    
    var databaseInterests: DatabaseReference {
        return databaseRoot.child(REF_USER)
    }
    
    func databaseSpecificUserandInterests(uid: String) -> DatabaseReference {
         return databaseUsers.child(uid).child("interests")
    }
    
    var databaseGeo: DatabaseReference {
        return databaseRoot.child(REF_GEO)
    }
    
    // Storage Ref
    
    
    let storageRoot = Storage.storage().reference(forURL: URL_STORAGE_ROOT)
    
    var storageProfile: StorageReference {
        return storageRoot.child(STORAGE_PROFILE)
    }
    var storageBuissProfile: StorageReference {
        return storageRoot.child(STORAGE_BUISNESS_PROFILE)
    }
    var storageMessage: StorageReference {
        return storageRoot.child(REF_MESSAGE)
    }
    func storageSpecificProfile(uid: String) -> StorageReference {
        return storageProfile.child(Api.User.currentUserId).child(uid)
    }
    func storageSpecificBuissProfile(uid: String) -> StorageReference {
        return storageBuissProfile.child(Api.BuisUser.currentUserId).child(uid)
       }
    
    func storageSpecificImageMessage (id: String) -> StorageReference {
        return storageMessage.child("photo").child(id)
    }
    
    func storageSpecificVideoMessage(id: String) -> StorageReference {
        return storageMessage.child("video").child(id)
    }
}
