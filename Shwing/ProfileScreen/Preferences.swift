//
//  Preferences.swift
//  Shwing
//
//  Created by shy attoun on 18/10/2019.
//  Copyright © 2019 shy attoun. All rights reserved.
//

import Foundation

class Preferences  {
    var age: String
    var agerange: Int
    var gender: String
    var intersetedin: String
    var mysearchstatus: String
    var mystatus: String
    var searchRange: String
    
    init(age: String, agerange: Int , gender: String ,  intersetedin: String , mysearchstatus: String , mystatus: String, searchRange: String){
        
        self.age = age
        self.agerange = agerange
        self.gender = gender
        self.intersetedin = intersetedin
        self.mysearchstatus = mysearchstatus
        self.mystatus = mystatus
        self.searchRange = searchRange
    }
    
    static func transformUser (dict: [String: Any]) -> Preferences? {
        guard let age = dict["age"] as? String,
            let agerange = dict["agerange"] as? Int,
            let gender = dict["gender"] as? String,
            let intersetedin = dict["intersetedin"] as? String,
            let mysearchstatus = dict["mysearchstatus"] as? String,
            let mystatus = dict["mystatus"] as? String,
            let searchRange = dict["searchRange"] as? String
        
        else {
                return nil
        }
        
        let preference = Preferences(age: age, agerange: agerange, gender: gender, intersetedin: intersetedin, mysearchstatus: mysearchstatus, mystatus: mystatus, searchRange: searchRange)
        
        return preference
    }
}
