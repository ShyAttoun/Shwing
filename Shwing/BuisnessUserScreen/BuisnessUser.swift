//
//  BuisnessUser.swift
//  Shwing
//
//  Created by shy attoun on 12/11/2019.
//  Copyright © 2019 shy attoun. All rights reserved.
//

import Foundation
import UIKit

class BuisnessUser: CustomStringConvertible  {
    var uid: String
    var email: String
    var city: String
    var state: String
    var buisnessName: String
    var address: String
    var phone: String
    var myOffer: String
    var about: String
    var postcode: String
    var buisnessLogoImageUrl: String
    var buisnessInteriorImageUrl: String
    var buisnessEntranceImageUrl: String
    var buisnessConceptImageUrl: String
    var isRest: Bool?
    var isNightLife: Bool?
    var isLive: Bool?
    var isFun: Bool?
    var logoImage = UIImage ()
    var interiorProfileImage = UIImage ()
    var entranceProfileImage = UIImage ()
    var conceptProfileImage = UIImage ()
   
    var longitude = ""
    var latidude = ""
    
    init(uid: String, email: String , city: String, state: String, buisnessName: String, address:String , phone: String, postcode: String, about: String , myOffer: String , buisnessLogoImageUrl: String , buisnessInteriorImageUrl: String , buisnessEntranceImageUrl: String , buisnessConceptImageUrl: String){
        
        self.uid = uid
        self.email = email
        self.city = city
        self.state = state
        self.buisnessName = buisnessName
        self.address = address
        self.phone = phone
        self.postcode = postcode
        self.myOffer = myOffer
        self.about = about
        self.buisnessLogoImageUrl = buisnessLogoImageUrl
        self.buisnessConceptImageUrl = buisnessConceptImageUrl
        self.buisnessInteriorImageUrl = buisnessInteriorImageUrl
        self.buisnessEntranceImageUrl = buisnessEntranceImageUrl
    }

    var description: String {
        return "BuisUser: uid: \(uid)\nemail: \(email)\ncity: \(city)\nstate \(state)\nbuisnessName: \(buisnessName)\naddress: \(address)\nphone \(phone)\nmyoffer \(myOffer)\nabout: \(about)\npostcode: \(postcode)"
    }
        

    static func transformBuissUser (dict: [String: Any]) -> BuisnessUser? {
        
        guard let email = dict["email"] as? String,
        let uid = dict["uid"] as? String,
        let city = dict["city"] as? String,
        let state = dict["state"] as? String,
        let buisnessName = dict["buisness name"] as? String,
        let address = dict["address"] as? String,
        let about = dict ["about"] as? String,
        let myOffer = dict["my offer"] as? String,
        let phone = dict["phone"] as? String,
        let postcode = dict["postcode"] as? String,
        let buisnessLogoImageUrl = dict["logo image"] as? String ,
        let buisnessInteriorImageUrl = dict["interior image"] as? String ,
        let buisnessEntranceImageUrl = dict["entrance image"] as? String,
        let buisnessConceptImageUrl = dict["concept image"] as? String
        else {
                return nil
        }
        //Thats it, i cant hear you :(
        let buissUser = BuisnessUser(uid: uid , email: email , city: city , state: state ,buisnessName: buisnessName , address: address , phone: phone, postcode: postcode, about: about, myOffer: myOffer , buisnessLogoImageUrl:buisnessLogoImageUrl , buisnessInteriorImageUrl:buisnessEntranceImageUrl , buisnessEntranceImageUrl:buisnessInteriorImageUrl , buisnessConceptImageUrl:buisnessConceptImageUrl )
        
        if let isRest = dict["is Restaurant"] as? Bool {
            buissUser.isRest = isRest
        }
        if let isFun  = dict["is Fun"] as? Bool {
            buissUser.isFun = isFun
        }
        if let isLive = dict["is Live"] as? Bool {
            buissUser.isLive = isLive
        }
        if let isNightLife = dict["is Night life"] as? Bool {
            buissUser.isNightLife = isNightLife
        }
        
        if let latitude = dict ["current_latitude"] as? String {
            buissUser.latidude = latitude
        }
        
        if let longitude = dict ["current_longitude"] as? String {
            buissUser.longitude = longitude
        }
        
        return buissUser
        
    }
    
    func updateData(key: String, value: Any) {
        switch key {
        case "buisness name": self.buisnessName  = value as! String
        case "email": self.email = value as! String
        case "logo image": self.buisnessLogoImageUrl = value as! String
        case "interior image": self.buisnessInteriorImageUrl = value as! String
        case "entrance image": self.buisnessEntranceImageUrl = value as! String
        case "concept image": self.buisnessConceptImageUrl = value as! String
        default: break
        }
    }
    

}
