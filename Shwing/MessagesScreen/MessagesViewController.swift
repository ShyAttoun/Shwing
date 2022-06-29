//
//  MessagesViewController.swift
//  Shwing
//
//  Created by shy attoun on 20/09/2019.
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
import ProgressHUD
import FirebaseStorage
import FirebaseMessaging



class MessagesViewController: UITableViewController {
    
    let userDefault = UserDefaults.standard
    var inboxArray = [Inbox]()
    var avatarImageView: UIImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 36, height: 36))
    var lastInboxDate: Double?
    
  
    
//    var currentUserId: String {
//        return Auth.auth().currentUser != nil ? Auth.auth().currentUser!.uid : ""
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView ()
        observeInbox()
        setupNavigationBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if !Api.User.currentUserId.isEmpty {
            Messaging.messaging().subscribe(toTopic: Api.User.currentUserId)
        }
        
//        if UserDefaults.standard.bool(forKey: "hasViewedWalkthrough"){
//            print("view has been viewed before")
//            
//            return
//            
//        }
//        
//        let storyboard = UIStoryboard(name: "UserDetailsStoryBoard", bundle: nil)
//        if let  wtvc = storyboard.instantiateViewController(withIdentifier: "WTVC") as? UserDetailsViewController {
//            present(wtvc, animated: true, completion: nil)
//            print("UserDetailsStoryBoard storyboard is on")
//        }
        
    }
    
    func  setupNavigationBar() {
        
        navigationItem.title = "Messages"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        
        let iconView = UIImageView(image: UIImage(named: "icon_top"))
        iconView.contentMode = .scaleAspectFit
        navigationItem.titleView = iconView
        
        let containView = UIView(frame: CGRect(x: 0, y: 0, width: 36, height: 36))
        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.layer.cornerRadius = 18
        avatarImageView.clipsToBounds = true
        containView.addSubview(avatarImageView)
        Api.User.getUserInforSingleEvent(uid: Api.User.currentUserId) { (user) in
        let leftBarButton = UIBarButtonItem(customView: containView)
        self.navigationItem.leftBarButtonItem = leftBarButton
        
        if Auth.auth().currentUser != nil {
            self.avatarImageView.loadImage(user.profileImageurl)
           
            }
        }
        
//        let radarItem = UIBarButtonItem(image: UIImage(named: "radar"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(radarItemDidTap))
//        self.navigationItem.rightBarButtonItem = radarItem
        
         NotificationCenter.default.addObserver(self, selector: #selector(updateProfile), name: NSNotification.Name("updateProfileImage"), object: nil)
       
    }
    
//    @objc func radarItemDidTap() {
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let radarVC = storyboard.instantiateViewController(withIdentifier: "RadarViewController") as! RadarViewController
//        
//        self.navigationController?.pushViewController(radarVC, animated: true)
//    }
    
    @objc func updateProfile () {
        Api.User.getUserInforSingleEvent(uid: Api.User.currentUserId) { (user) in
            
            self.avatarImageView.loadImage(user.profileImageurl)
        
        }
    }
    
   func observeInbox() {
    Api.Inbox.lastMessages(uid: Auth.auth().currentUser!.uid){ (inbox) in
        if !self.inboxArray.contains(where: { $0.user.uid == inbox.user.uid }) {
            self.inboxArray.append(inbox)
            self.sortedInbox()
        }
    }
    }
    func sortedInbox() {
        inboxArray = inboxArray.sorted(by: { $0.date > $1.date })
        lastInboxDate = inboxArray.last!.date
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func setupTableView () {
        tableView.tableFooterView = UIView ()

    }
    
    func loadMore() {
        Api.Inbox.loadMore(start: lastInboxDate, controller: self, from: Api.User.currentUserId) { (inbox) in
            self.tableView.tableFooterView = UIView()
            if self.inboxArray.contains(where: {$0.channel == inbox.channel}) {
                return
            }
            self.inboxArray.append(inbox)
            self.tableView.reloadData()
            self.lastInboxDate = self.inboxArray.last!.date
        }
    }
  
    override func numberOfSections(in tableView: UITableView) -> Int {
     
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
       return inboxArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "InboxTableViewCell", for: indexPath) as! InboxTableViewCell
        let inbox = self.inboxArray[indexPath.row]
        cell.controller = self
        cell.configureCell(uid: Auth.auth().currentUser!.uid, inbox: inbox)
        
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 94
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? InboxTableViewCell {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let chatVC = storyboard.instantiateViewController(withIdentifier: IDENTIFIER_CHAT) as! ChatViewController
            chatVC.imagePartner = cell.avatar.image
            chatVC.partnerUserName = cell.fullnameLbl.text
            chatVC.partnerId = cell.user.uid
            chatVC.partnerUser = cell.user
            self.navigationController?.pushViewController(chatVC, animated: true)
            
        }
    }
    override func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        if let lastIndex = self.tableView.indexPathsForVisibleRows?.last {
            if lastIndex.row >= self.inboxArray.count - 2 {
                let spinner = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.gray)
                spinner.startAnimating()
                spinner.frame = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 44)
                
                self.tableView.tableFooterView = spinner
                self.tableView.tableFooterView?.isHidden = false
                
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
                    self.loadMore()
                }
            }
        }
    }
   
  


}


//var image: UIImage = UIImage(named: "shyattoun")!
//
//
//let leftBarButton = UIBarButtonItem(image: image, style: .done, target: nil, action: nil)
//self.navigationItem.leftBarButtonItem = leftBarButton
