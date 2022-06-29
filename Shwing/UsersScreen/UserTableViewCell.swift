//
//  UserTableViewCell.swift
//  Shwing
//
//  Created by shy attoun on 21/09/2019.
//  Copyright © 2019 shy attoun. All rights reserved.
//

import UIKit
import Firebase

protocol UpdateTableProtocol {
    func reloadData()
}
class UserTableViewCell: UITableViewCell {

    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var fullnameLbl: UILabel!
    @IBOutlet weak var statusLbl: UILabel!
    @IBOutlet weak var onlineStatusIcon: UIView!
    
    var user: User!
    var inboxChangeOnlineHandle : DatabaseHandle!
    var inboxChangedProfileHandle: DatabaseHandle!
    var delegate: UpdateTableProtocol!

    var inbox: Inbox!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        avatar.layer.cornerRadius = 30
        avatar.clipsToBounds = true
        onlineStatusIcon.backgroundColor = UIColor.red
        onlineStatusIcon.layer.borderWidth = 2
        onlineStatusIcon.layer.borderColor = UIColor.white.cgColor
        onlineStatusIcon.layer.cornerRadius = 15/2
        onlineStatusIcon.clipsToBounds = true
    }
    
    func loadData(_ user: User) {
        self.user = user
        self.fullnameLbl.text = user.fullname
        self.statusLbl.text = user.status
        self.avatar.loadImage(user.profileImageurl)
       
        
    
        
        let refOnline = Ref().databaseIsOnline(uid: user.uid)
        refOnline.observeSingleEvent(of: .value) { (snapshot) in
            if let snap = snapshot.value as? Dictionary<String, Any> {
                if let active = snap["online"] as? Bool {
                    self.onlineStatusIcon.backgroundColor = active == true ? .green : .red
                }
            }
        }
        if inboxChangeOnlineHandle != nil {
            refOnline.removeObserver(withHandle: inboxChangeOnlineHandle)
        }
        
        inboxChangeOnlineHandle = refOnline.observe(.childChanged) { (snapshot) in
            if let snap = snapshot.value {
                if snapshot.key == "online" {
                    self.onlineStatusIcon.backgroundColor = (snap as! Bool) == true ? .green : .red
                }
            }
        }
        
        let refUser = Ref().databaseSpecificBuisUser(uid: user.uid)
        
        if inboxChangedProfileHandle != nil {
            refUser.removeObserver(withHandle: inboxChangedProfileHandle)
        }
        
        inboxChangedProfileHandle = refUser.observe(.childChanged, with: { (snapshot) in
            if let snap = snapshot.value as? String {
                self.user.updateData(key: snapshot.key, value: snap)
                self.delegate.reloadData()
            }
        })
        
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
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
