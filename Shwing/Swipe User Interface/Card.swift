//
//  Card.swift
//  Shwing
//
//  Created by shy attoun on 26/10/2019.
//  Copyright © 2019 shy attoun. All rights reserved.
//

import UIKit
import CoreLocation

class Card: UIView {
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var locationLbl: UILabel!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var infoBtn: UIButton!
    
    @IBOutlet weak var likeView: UIView!
    @IBOutlet weak var likeTitleLbl: UILabel!
    @IBOutlet weak var nopeView: UIView!
    @IBOutlet weak var nopeTitleLbl: UILabel!
    
    var controller : RadarViewController!
    
    var user : User! {
        didSet {
            photo.loadImage(user.profileImageurl) { (image) in
                self.user.profileImage = image
            }
            
            let attributedUserNameText = NSMutableAttributedString(string: "\(user.fullname)  ", attributes:[NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 30) , NSAttributedString.Key.foregroundColor: UIColor.white])
            
            var age = ""
            if let ageValue = user.age{
                
                age = String(ageValue)
            }
            
            let attributedAgeText = NSMutableAttributedString(string: age, attributes:[NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 22) , NSAttributedString.Key.foregroundColor: UIColor.white])
            
        attributedUserNameText.append(attributedAgeText)
            
        usernameLbl.attributedText = attributedUserNameText
        
            if let userLat = UserDefaults.standard.value(forKey: "current_location_latitude") as? String , let userLong = UserDefaults.standard.value(forKey: "current_location_longitude") as? String {
                
                let currentLocation:CLLocation = CLLocation(latitude: CLLocationDegrees(Double(userLat)!), longitude:CLLocationDegrees(Double(userLong)!))
                
                if !user.latidude.isEmpty && !user.longitude.isEmpty {
                    let userLoc = CLLocation(latitude: Double(user.latidude)!, longitude: Double(user.longitude)!)
                    let distanceImKM: CLLocationDistance = userLoc.distance(from: currentLocation) / 1000
                    locationLbl.text = "\(Int (distanceImKM)) km"
                }else {
                    locationLbl.text = ""
                }
            }
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
        let frameGradient = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: bounds.height)
        photo.addBlackGradientLayer(frame: frameGradient, colors: [.clear,.black])
        
        photo.layer.cornerRadius = 10
        photo.clipsToBounds = true
        
        likeView.alpha = 0
        nopeView.alpha = 0
        
        likeView.layer.borderWidth = 3
        likeView.layer.cornerRadius = 5
        likeView.clipsToBounds = true
        likeView.layer.borderColor = UIColor(red: 0.101, green: 0.737, blue: 0.611, alpha: 1).cgColor
    
        nopeView.layer.borderWidth = 3
        nopeView.layer.cornerRadius = 5
        nopeView.clipsToBounds = true
        nopeView.layer.borderColor = UIColor(red: 0.9, green: 0.29, blue: 0.23, alpha: 1).cgColor
        
        likeView.transform = CGAffineTransform(rotationAngle:  -.pi / 8)
        nopeView.transform = CGAffineTransform(rotationAngle:  .pi / 8)

        likeTitleLbl.attributedText = NSAttributedString(string: "LIKE", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 30)])
        likeTitleLbl.textColor = UIColor(red: 0.101, green: 0.737, blue: 0.611, alpha: 1)
        
        nopeTitleLbl.addCharacterSpacing()
        nopeTitleLbl.attributedText = NSAttributedString(string: "NOPE", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 30)])
        nopeTitleLbl.textColor =  UIColor(red: 0.9, green: 0.29, blue: 0.23, alpha: 1)

    }
    
    @IBAction func infoBtnDidTap(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let detailVC = storyboard.instantiateViewController(withIdentifier: "DetailsViewController") as! DetailsViewController
        detailVC.user = user
        
        controller.navigationController?.pushViewController(detailVC, animated: true)
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
