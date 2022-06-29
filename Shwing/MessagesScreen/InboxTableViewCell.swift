//
//  InboxTableViewCell.swift
//  Shwing
//
//  Created by shy attoun on 17/10/2019.
//  Copyright © 2019 shy attoun. All rights reserved.
//

import UIKit
import Firebase

class InboxTableViewCell: UITableViewCell {

    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var fullnameLbl: UILabel!
    @IBOutlet weak var messageLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var onlineStatusIcon: UIView!
    
    var user: User!
    var inboxChangeOnlineHandle : DatabaseHandle!
    var inboxChangedProfileHandle: DatabaseHandle!
    var inboxChangedMessageHandle: DatabaseHandle!

    var controller: MessagesViewController!

    var inbox: Inbox!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        avatar.layer.cornerRadius = 30
        avatar.clipsToBounds = true
        onlineStatusIcon.backgroundColor = UIColor.red
        onlineStatusIcon.layer.borderWidth = 2
        onlineStatusIcon.layer.borderColor = UIColor.white.cgColor
        onlineStatusIcon.layer.cornerRadius = 15/2
        onlineStatusIcon.clipsToBounds = true
    }
    
    func configureCell(uid: String, inbox: Inbox) {
        self.user = inbox.user
        self.inbox = inbox
        avatar.loadImage(inbox.user.profileImageurl)
        fullnameLbl.text = inbox.user.fullname
        let date = Date(timeIntervalSince1970: inbox.date)
        let dateString = timeAgoSinceDate(date, currentDate: Date(), numericDates: true)
        dateLbl.text = dateString
        
        if !inbox.text.isEmpty {
            messageLbl.text = inbox.text
        } else {
            messageLbl.text = "[MEDIA]"
        }
        
        
//        let refInbox = Ref().databaseInboxInFor(from: Api.User.currentUserId, to: inbox.user.uid)
        let channelId = Message.hash(forMembers: [Api.User.currentUserId, inbox.user.uid])
        let refInbox = Database.database().reference().child(REF_INBOX).child(Api.User.currentUserId).child(channelId)
        if inboxChangedMessageHandle != nil {
            refInbox.removeObserver(withHandle: inboxChangedMessageHandle)
        }
        
        inboxChangedMessageHandle = refInbox.observe(.childChanged, with: { (snapshot) in
        
            if let snap = snapshot.value {
             self.inbox.updateData(key: snapshot.key, value: snap)
                self.controller.sortedInbox()
            }
        })
        
   
        let refOnline = Ref().databaseIsOnline(uid: inbox.user.uid)
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
                        
                        self.onlineStatusIcon.backgroundColor = (snap as! Bool) == true ? .green : .red                    }
                }
            }
        
        
        let refUser = Ref().databaseSpecificUser(uid: user.uid)
        
        if inboxChangedProfileHandle != nil {
            refUser.removeObserver(withHandle: inboxChangedProfileHandle)
        }
        
        inboxChangedProfileHandle = refUser.observe(.childChanged, with: { (snapshot) in
            if let snap = snapshot.value as? String {
                self.user.updateData(key: snapshot.key, value: snap)
                self.controller.sortedInbox()
            }
        })
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
       
        let refOnline = Ref().databaseIsOnline(uid: self.inbox.user.uid)
        if inboxChangeOnlineHandle != nil {
            refOnline.removeObserver(withHandle: inboxChangeOnlineHandle)
        }
        
        let refUser = Ref().databaseSpecificUser(uid: user.uid)
        if inboxChangedProfileHandle != nil {
            refUser.removeObserver(withHandle: inboxChangedProfileHandle)
        }
        
        let channelId = Message.hash(forMembers: [Api.User.currentUserId, inbox.user.uid])
        let refInbox = Database.database().reference().child(REF_INBOX).child(Api.User.currentUserId).child(channelId)
        if inboxChangedMessageHandle != nil {
            refInbox.removeObserver(withHandle: inboxChangedMessageHandle)
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
