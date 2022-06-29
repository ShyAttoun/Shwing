//
//  UserAroundCollectionViewCell.swift
//  Shwing
//
//  Created by shy attoun on 21/10/2019.
//  Copyright © 2019 shy attoun. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation

class UserAroundCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var ageLbl: UILabel!
    @IBOutlet weak var distanceLbl: UILabel!
    @IBOutlet weak var onlineView: UIImageView!
    @IBOutlet weak var avatar: UIImageView!
    
    var user: User!
    var inboxChangeOnlineHandle : DatabaseHandle!
    var inboxChangedProfileHandle: DatabaseHandle!
    var controller: UsersAroundViewController!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        onlineView.backgroundColor = UIColor.red
        onlineView.layer.cornerRadius = 10/2
        onlineView.clipsToBounds = true
    }
    
    func loadData(_ user: User , currentLocation: CLLocation? ) {
        self.user = user
        self.avatar.loadImage(user.profileImageurl)
        self.avatar.loadImage(user.profileImageurl) { (image) in
            user.profileImage = image
        }
        if let age = user.age {
            self.ageLbl.text = "\(age)"
        } else {
            self.ageLbl.text = ""
        }
        
        
        let refOnline = Ref().databaseIsOnline(uid: user.uid)
        refOnline.observeSingleEvent(of: .value) { (snapshot) in
            if let snap = snapshot.value as? Dictionary<String, Any> {
                if let active = snap["online"] as? Bool {
                    self.onlineView.backgroundColor = active == true ? .green : .red
                }
            }
        }
        if inboxChangeOnlineHandle != nil {
            refOnline.removeObserver(withHandle: inboxChangeOnlineHandle)
        }
        
        inboxChangeOnlineHandle = refOnline.observe(.childChanged) { (snapshot) in
            if let snap = snapshot.value {
                if snapshot.key == "online" {
                    self.onlineView.backgroundColor = (snap as! Bool) == true ? .green : .red
                }
            }
        }
        
        let refUser = Ref().databaseSpecificUser(uid: user.uid)
        
        if inboxChangedProfileHandle != nil {
            refUser.removeObserver(withHandle: inboxChangedProfileHandle)
        }
        
        inboxChangedProfileHandle = refUser.observe(.childChanged, with: { (snapshot) in
            if let snap = snapshot.value as? String {
                self.user.updateData(key: snapshot.key, value: snap)
                self.controller.collectionView.reloadData()
            }
        })
        
        guard let _ = currentLocation else{
            return
        }
        
        if !user.latidude.isEmpty && !user.longitude.isEmpty {
           let userLocation = CLLocation(latitude: Double(user.latidude)!, longitude: Double(user.longitude)!)
            let distanceinKM: CLLocationDistance = userLocation.distance(from: currentLocation!) / 1000
            distanceLbl.text = String(format: "%.2f Km", distanceinKM)
        } else {
            distanceLbl.text = ""
        }
        
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        let refOnline = Ref().databaseIsOnline(uid: self.user.uid)
        if inboxChangeOnlineHandle != nil {
            refOnline.removeObserver(withHandle: inboxChangeOnlineHandle)
        }
        let refUser = Ref().databaseSpecificUser(uid: self.user.uid)
        if inboxChangedProfileHandle != nil {
            refUser.removeObserver(withHandle: inboxChangedProfileHandle)
        }
        
    }
}
