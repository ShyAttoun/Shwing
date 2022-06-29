//
//  UserStatus.swift
//  Shwing
//
//  Created by shy attoun on 04/12/2019.
//  Copyright © 2019 shy attoun. All rights reserved.
//

import Foundation

enum UserStatus:String {
     case local = "Local"
     case tourist = "Tourist"
     case newInTown = "New in town"
     
     static var allValues: [UserStatus] = [.local, .tourist, .newInTown]
    
    var myIndex: Int {
        switch self {
        case .local:
            return 0
        case .tourist:
            return 1
        case .newInTown:
            return 2
        }
    }

     var statusResult: [String]{
         switch self {
         case .local:
             return["Local"]
         case .tourist:
             return["Tourist"]
        case .newInTown:
             return["New in town"]
       
         }
     }
 }
