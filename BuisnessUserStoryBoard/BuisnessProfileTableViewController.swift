//
//  BuisnessProfileTableViewController.swift
//  Shwing
//
//  Created by shy attoun on 03/11/2019.
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



class BuisnessProfileTableViewController: UITableViewController {
    var flag = 0
    var userLat = ""
    var userLong = ""
    let manager = CLLocationManager ()
    var geoFire : GeoFire!
    var geoFireRef: DatabaseReference!
    
    enum TypeBuis: CustomStringConvertible {
        case chooseYourType
        case restaurant
        case nightLife
        case live
        case fun
        
        static var allValues: [TypeBuis] = [.chooseYourType, .restaurant, .nightLife , .live, .fun]
        
        var myArray: [String] {
            switch self {
            case .chooseYourType:
                return []
            case .restaurant:
                return ["Asian","Sushi","Israeli","BBQ","Italian","Japanese","Greek","American","Health Bar","Burgers","French","South American","Other"]
            case .nightLife:
                return ["Irish","Sport-Pub","Intimic","Local","Rock","Other","Techno","UnderGround","HipHop","Karaoke","House","Exclusive",]
            case .fun:
                return ["Fashion","Shopping","Daily Trip","Hiking","Tour","Cooking","Handyman","Esacpe Room","Yoga/Thai Chi","Workout","Other","Art Gallery", "Maddame Toussu","Music Art","Urban Art","Painting","History","Other"]
           
            case .live:
                return ["Movies","Live Shows","Stand up Comedy","Play"]
           
        
            }
        }
        
        var description: String {
            switch self {
            case .chooseYourType:
                return "Choose Your Type:"
            case .restaurant:
                return "Restaurant"
            case .nightLife:
                return "Night Life"
            case .live:
                return "Live"
                
            case .fun :
                return "Fun"
            }
        }
    }
    var currentUser = Auth.auth().currentUser
    var image: UIImage? = nil
    let userDefault = UserDefaults.standard
   
    var typesOfBuisnesses = TypeBuis.allValues
    var ganeresOfBuisnesses: [String] = [String]()
    let logoImageBG = UIImage(named: "billboard") as UIImage?
    let interiorImageBG = UIImage(named: "interior") as UIImage?
    let entranceImageBG = UIImage(named: "place") as UIImage?
    let conceptImageBG = UIImage(named: "idea") as UIImage?
   
    @IBOutlet weak var addressTF: UITextField!
    @IBOutlet weak var cityTF: UITextField!
    @IBOutlet weak var countryStateTF: UITextField!
    @IBOutlet weak var buisnessNameTF: UITextField!
    @IBOutlet weak var phoneNumberTF: UITextField!
    @IBOutlet weak var postCodeTF: UITextField!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var saveBtn: UIBarButtonItem!
   
    @IBOutlet weak var aboutTF: UITextView!
    @IBOutlet weak var myOfferTF: UITextView!
    
    @IBOutlet weak var logoImage: UIImageView!
    @IBOutlet weak var entranceImage: UIImageView!
    @IBOutlet weak var interiorImage: UIImageView!
    @IBOutlet weak var conceptImage: UIImageView!
    
    @IBOutlet weak var typeOfBuisPicker: UIPickerView!
    @IBOutlet weak var ganereBuisPicker: UIPickerView!
   
    @IBOutlet weak var typeBuisLbl: UILabel!
    @IBOutlet weak var ganereBuisLbl: UILabel!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        observeData()
        setupProfileImages ()
        configureLocationManager()
        
        typeOfBuisPicker.layer.cornerRadius = 34
        typeOfBuisPicker.delegate = self
        ganereBuisPicker.delegate = self
        typeOfBuisPicker.dataSource = self
        ganereBuisPicker.dataSource = self
        
        typeOfBuisPicker.tag = 0
        ganereBuisPicker.tag = 10
    }
    

    
    func observeData() {
        Api.BuisUser.getBuisUserInforSingleEvent(uid: Api.BuisUser.currentUserId) { (user) in
            self.logoImage.loadImage(user.buisnessLogoImageUrl)
            self.interiorImage.loadImage(user.buisnessInteriorImageUrl)
            self.entranceImage.loadImage(user.buisnessEntranceImageUrl)
            self.conceptImage.loadImage(user.buisnessConceptImageUrl)
            self.buisnessNameTF.text = user.buisnessName
            self.aboutTF.text = user.about
            self.myOfferTF.text = user.myOffer
            self.cityTF.text = user.city
            self.countryStateTF.text = user.state
            self.addressTF.text = user.address
            self.phoneNumberTF.text = user.phone
            self.postCodeTF.text = user.postcode
            self.emailTF.text = user.email
            

            print(user)
        }
    }
    

    @IBAction func saveBtnIsTapped(_ sender: Any) {
        ProgressHUD.show("Saving...")
//                userSetting()
        
        var dict = Dictionary<String, Any>()
        
        if let buisnessName = buisnessNameTF.text, !buisnessName.isEmpty {
            dict["buisness name"] = buisnessName
        }
        if let email = emailTF.text, !email.isEmpty {
            dict["email"] = email
        }
        if let city = cityTF.text, !city.isEmpty {
            dict["city"] = city
        }
        if let state = countryStateTF.text, !state.isEmpty {
            dict["state"] = state
        }
        
        if let address = addressTF.text, !address.isEmpty {
            dict["address"] = address
        }
        
        if let phone = phoneNumberTF.text, !phone.isEmpty {
            dict["phone"] = phone
        }
        
        if let postCode = postCodeTF.text, !postCode.isEmpty {
            dict["postcode"] = postCode
        }
        
        if let aboutMe = aboutTF.text, !aboutMe.isEmpty {
            dict["about"] = aboutMe
        }
        
        if let myOffer = myOfferTF.text, !myOffer.isEmpty {
            dict["my offer"] = myOffer
        }
        
        // TODO
        // if user picked Restaurant = his firebase status will be IsRest = true [like we did for male/female]
        
        if typesOfBuisnesses[typeOfBuisPicker.selectedRow(inComponent: 0)] == .chooseYourType {
            ProgressHUD.showError("Please select a Buisness type")
            
        return
        }
        
      
            dict["buisness type"] = typesOfBuisnesses[ typeOfBuisPicker.selectedRow(inComponent: 0)].description
            dict["buisness ganere"] = ganeresOfBuisnesses[ganereBuisPicker.selectedRow(inComponent: 0)]
        
        
        
        if typesOfBuisnesses[ typeOfBuisPicker.selectedRow(inComponent: 0)].description == "Restaurant" {
            dict["is Restaurant"] = true
             dict["is Night life"] = false
            dict["is Live"] = false
            dict["is Fun"] = false
            print(typesOfBuisnesses[ typeOfBuisPicker.selectedRow(inComponent: 0)].description)
        }
        else if  typesOfBuisnesses[ typeOfBuisPicker.selectedRow(inComponent: 0)].description == "Night Life" {
            dict["is Restaurant"] = false
            dict["is Night life"] = true
            dict["is Live"] = false
            dict["is Fun"] = false
            print(typesOfBuisnesses[ typeOfBuisPicker.selectedRow(inComponent: 0)].description)
        }
        
        else if  typesOfBuisnesses[ typeOfBuisPicker.selectedRow(inComponent: 0)].description == "Live" {
            dict["is Restaurant"] = false
            dict["is Night life"] = false
            dict["is Live"] = true
            dict["is Fun"] = false
            print(typesOfBuisnesses[ typeOfBuisPicker.selectedRow(inComponent: 0)].description)
        }
        
        else if  typesOfBuisnesses[ typeOfBuisPicker.selectedRow(inComponent: 0)].description == "Fun" {
            dict["is Restaurant"] = false
            dict["is Night life"] = false
            dict["is Live"] = false
            dict["is Fun"] = true
            print(typesOfBuisnesses[ typeOfBuisPicker.selectedRow(inComponent: 0)].description)
        }
        
        
        
        Api.BuisUser.saveBuisUserProfile(dict: dict, onSuccess: {
           if let img = self.logoImage.image {
                         StorageService.saveLogoImageProfile(image: img, onSuccess: {
                             ProgressHUD.showSuccess()

                         }) { (errorMessage) in
                             ProgressHUD.showError(errorMessage)
                         }
                     }
            if let img = self.interiorImage.image {
                           StorageService.saveInteriorImageProfile(image: img, onSuccess: {
                               ProgressHUD.showSuccess()

                           }) { (errorMessage) in
                               ProgressHUD.showError(errorMessage)
                           }
                       }
            if let img = self.entranceImage.image {
                           StorageService.saveEntranceImageProfile(image: img, onSuccess: {
                               ProgressHUD.showSuccess()

                           }) { (errorMessage) in
                               ProgressHUD.showError(errorMessage)
                           }
                       }
            if let img = self.conceptImage.image {
                           StorageService.saveConceptImageProfile(image: img, onSuccess: {
                               ProgressHUD.showSuccess()

                           }) { (errorMessage) in
                               ProgressHUD.showError(errorMessage)
                           }
                       }
        }) { (errorMessage) in
            ProgressHUD.showError(errorMessage)
        }
    }
    
  

    
    @IBAction func logoutBtnIsTapped(_ sender: Any) {
        signOutFromApp ()
    }
    
    func signOutFromApp () {
//          let uid = Api.BuisUser.currentUserId
        do{
            Api.BuisUser.isBuisUserOnline(bool: false)
            
         
            userDefault.removeObject(forKey: "buisnessUserSignedinwithemail")
            userDefault.synchronize()
            
            try Auth.auth().signOut()
            //            Messaging.messaging().unsubscribe(fromTopic: uid)
            
            
        }catch {
            ProgressHUD.showError(error.localizedDescription)
            return
        }
        (UIApplication.shared.delegate as! AppDelegate).configureInitialViewController()
    }

}


