//
//  ChatViewController+Extentions.swift
//  Shwing
//
//  Created by shy attoun on 16/10/2019.
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
import MobileCoreServices
import AVFoundation

extension ChatViewController {
    
    func observeMessages() {
        Api.Message.receiveMessage(from: Api.User.currentUserId, to: partnerId) { (message) in
            self.messages.append(message)
            self.sortMessages()
        }
    
    }
    
    func sortMessages() {
        messages = messages.sorted(by: { $0.date < $1.date })
        lastMessageKey = messages.first!.id
        DispatchQueue.main.async {
            self.chatTableView.reloadData()
            self.scrollToBottom()
        }
    }
    
    func scrollToBottom() {
        if messages.count > 0 {
            let index = IndexPath(row: messages.count - 1, section: 0)
            chatTableView.scrollToRow(at: index, at: UITableView.ScrollPosition.bottom, animated: false)
        }
    }
    
    func sendToFirebase (dict: Dictionary<String, Any>) {
        let date: Double = Date().timeIntervalSince1970
        var value = dict
        value["from"] =  Api.User.currentUserId
        value["to"] = partnerId
        value["date"] = date
        value["read"] =  false
        
        Api.Message.sendMessage(from: Api.User.currentUserId, to: partnerId, value: value)
        
        if let videoUrl = dict["videoUrl"] as? String, !videoUrl.isEmpty {
            // send video notification
            handleNotification(fromUid: Api.User.currentUserId, message: "[VIDEO]")
        } else if let imageUrl = dict["imageUrl"] as? String, !imageUrl.isEmpty {
            // send photo notification
            handleNotification(fromUid: Api.User.currentUserId, message: "[PHOTO]")
            
        } else if let text = dict["text"] as? String, !text.isEmpty {
            // send text notification
            handleNotification(fromUid: Api.User.currentUserId, message: text)
        }
        
        
    }
    
    func handleNotification(fromUid: String, message: String) {
        Api.User.getUserInforSingleEvent(uid: fromUid) { (user) in
            sendRequestNotification(fromUser: user, toUser: self.partnerUser, message: message, badge: 1)
        }
    }
    
    func setupPicker () {
        picker.delegate = self
    }
    
    func setupTableView () {
        chatTableView.separatorStyle = .none
        chatTableView.tableFooterView = UIView ()
        chatTableView.allowsSelection = false
        chatTableView.keyboardDismissMode = .interactive
        chatTableView.delegate = self
        chatTableView.dataSource = self
        
        if #available(iOS 10.0, *) {
            chatTableView.refreshControl = refreshControl
        } else {
            chatTableView.addSubview(refreshControl)
        }
        
        refreshControl.addTarget(self, action: #selector(loadMore), for: .valueChanged)
    }
    
    @objc func loadMore() {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
            Api.Message.loadMore(lastMessageKey: self.lastMessageKey, from: Api.User.currentUserId, to: self.partnerId, onSuccess: { (messagesArray, lastMessageKey) in
                if messagesArray.isEmpty {
                    self.refreshControl.endRefreshing()
                    return
                }
                self.messages.append(contentsOf: messagesArray)
                self.messages = self.messages.sorted(by: { $0.date < $1.date })
                self.lastMessageKey = lastMessageKey
                self.chatTableView.reloadData()
                self.refreshControl.endRefreshing()
            })
        }
    }
    
    func  setupInputContainer () {
        let mediaImg = UIImage(named: "attach")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        mediaBtn.setImage(mediaImg, for: UIControl.State.normal)
        mediaBtn.tintColor = .lightGray
        
        let micImg = UIImage(named: "mic")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        micBtn.setImage(micImg, for: UIControl.State.normal)
        micBtn.tintColor = .lightGray
        
        setupInputTextView()
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    @objc func adjustForKeyboard (notification : Notification) {
        let userInfo = notification.userInfo!
        let keyboardScreenEndFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, to: view.window)
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            chatViewBottomConst.constant = 0
        } else {
            if #available(iOS 11.0, *){
                chatViewBottomConst.constant = -keyboardViewEndFrame.height + view.safeAreaInsets.bottom
            }else{
              chatViewBottomConst.constant = -keyboardViewEndFrame.height
            }
        }
        view.layoutIfNeeded()
    }
    
    func setupInputTextView() {
        
        chatBoxTF.delegate = self
        placeHolder.isHidden = false
        
        sendBtn.isEnabled = false
        sendBtn.setTitleColor(.lightGray, for: UIControl.State.normal)
        
        let placeHolderX:  CGFloat = self.view.frame.size.width / 75
        let placeHolderY: CGFloat = 0
        let placeHolderWidth: CGFloat = chatBoxTF.bounds.width - placeHolderX
        
        let placeHolderHeight: CGFloat = chatBoxTF.bounds.height
        
        let placeHolderFontSize = self.view.frame.size.width / 25
        
        placeHolder.frame = CGRect(x: placeHolderX, y: placeHolderY, width: placeHolderWidth, height: placeHolderHeight)
        placeHolder.text = "Write a message..."
        placeHolder.font = UIFont(name: "HelveticaNeue" , size: placeHolderFontSize)
        placeHolder.textColor = .lightGray
        placeHolder.textAlignment = .left
        
        chatBoxTF.addSubview(placeHolder)
    }
    
    func  setupNativationBar () {
        navigationItem.largeTitleDisplayMode = .never
        let containView = UIView(frame: CGRect(x: 0, y: 0, width: 36, height: 36))
//        avatarImageView.image = imagePartner
        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.layer.cornerRadius = 18
        avatarImageView.clipsToBounds = true
        containView.addSubview(avatarImageView)
        
        if imagePartner != nil {
            avatarImageView.image = imagePartner
            self.observeActivity()
            self.observeMessages()
        } else {
            avatarImageView.loadImage(partnerUser.profileImageurl) { (image) in
                self.observeActivity()
                self.imagePartner = image
                self.observeMessages()
                
            }
        }
        
        let rightBarButton = UIBarButtonItem(customView: containView)
        self.navigationItem.rightBarButtonItem = rightBarButton
        
        topLbl.textAlignment = .center
        topLbl.numberOfLines = 0
        
        let attributed =  NSMutableAttributedString(string: partnerUserName + "\n", attributes: [.font: UIFont.systemFont(ofSize: 17), .foregroundColor: UIColor.black])
        
        attributed.append(NSAttributedString(string: "Active", attributes: [.font : UIFont.systemFont(ofSize: 13),.foregroundColor: UIColor.green ]))
        topLbl.attributedText = attributed
        
        self.navigationItem.titleView = topLbl
    }
    
    func updateTopLabel(bool: Bool) {
        var status = ""
        var color = UIColor()
        if bool {
            status = "Active"
            color = UIColor.green
            if isTyping {
                status = "Typing..."
                color = UIColor.gray
            }
        } else {
            status = "Last Active " + self.lastTimeOnline
            color = UIColor.red
        }
        
        topLbl.textAlignment = .center
        topLbl.numberOfLines = 0
        
        let attributed = NSMutableAttributedString(string: partnerUserName + "\n" , attributes: [.font : UIFont.systemFont(ofSize: 17), .foregroundColor: UIColor.black])
        
        attributed.append(NSAttributedString(string: status, attributes: [.font : UIFont.systemFont(ofSize: 13), .foregroundColor: color]))
        topLbl.attributedText = attributed
    }
    
    func observeActivity() {
        let ref = Ref().databaseIsOnline(uid: partnerUser.uid)
        ref.observeSingleEvent(of: .value) { (snapshot) in
            if let snap = snapshot.value as? Dictionary<String, Any> {
                if let active = snap["online"] as? Bool {
                    self.isActive = active
                }
                
                if let latest = snap["latest"] as? Double {
                    self.lastTimeOnline = latest.convertDate()
                }
              
            
            }
            
            self.updateTopLabel(bool: self.isActive)
        }
        ref.observe(.childChanged) { (snapshot) in
            if let snap = snapshot.value {
                if snapshot.key == "online" {
                    self.isActive = snap as! Bool
                }
                if snapshot.key == "latest" {
                    let latest = snap as! Double
                    self.lastTimeOnline = latest.convertDate()
                }
                if snapshot.key == "typing"{
                    let typing = snap as! String
                    self.isTyping = typing == Api.User.currentUserId ?  true : false
                }
                
                self.updateTopLabel(bool: self.isActive)
            }
        }
    }
    
}
extension ChatViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        let spacing = CharacterSet.whitespacesAndNewlines
        if !textView.text.trimmingCharacters(in: spacing).isEmpty{
            let text = textView.text.trimmingCharacters(in: spacing)
            sendBtn.isEnabled = true
            sendBtn.setTitleColor(.black , for: UIControl.State.normal)
            placeHolder.isHidden = true
        } else {
            sendBtn.isEnabled = false
            sendBtn.setTitleColor(.lightGray, for: UIControl.State.normal)
            placeHolder.isHidden = false
        }
        if !isTyping {
            Api.User.typing(from: Api.User.currentUserId, to: partnerUser.uid)
            isTyping = true
        } else {
            timer.invalidate()
        }
        
        timerTyping ()
        
    }
    
    func timerTyping () {
        timer = Timer.scheduledTimer(withTimeInterval: 3, repeats: false, block: { (t) in
            Api.User.typing(from: Api.User.currentUserId, to: "")
            self.isTyping = false
        })
    }
    
}
extension ChatViewController: UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let videoUrl = info[UIImagePickerController.InfoKey.mediaURL] as? URL {
            handleVideoSelectedForUrl(videoUrl)
        }else{
            handleImageSelectedForInfo (info)
        }
        
    }
    
    func handleVideoSelectedForUrl (_ url: URL) {
        //save video data
        let videoName = NSUUID().uuidString
        StorageService.saveVideoMessage(url: url, id: videoName, onSuccess:{(anyValue) in
            if let dict  =  anyValue as? [String: Any]{
                self.sendToFirebase(dict: dict)
            }
        }) {(errorMessage) in
        }
        self.picker.dismiss(animated: true, completion: nil)
    }
    
    
    func handleImageSelectedForInfo (_ info: [UIImagePickerController.InfoKey : Any]) {
        var selectedImageFromPicker: UIImage?
        
        if let imageSelected = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            selectedImageFromPicker = imageSelected
        }
        
        if let imageOriginal = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            selectedImageFromPicker = imageOriginal
        }
        
        //save photo data
        let imageName = NSUUID().uuidString
        StorageService.savePhotoMessage(image: selectedImageFromPicker, id: imageName, onSuccess: {(anyValue) in
            if let dict  =  anyValue as? [String: Any]{
                self.sendToFirebase(dict: dict)
            }
        }) {(errorMessage) in
        }
        self.picker.dismiss(animated: true, completion: nil)
    }
}

extension ChatViewController: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageTableViewCell") as! MessageTableViewCell
        cell.playBtn.isHidden = messages[indexPath.row].videoUrl == ""
        cell.timeStampChatLbl.isHidden = indexPath.row % 3 == 0 ? false : true
        cell.configureCell(uid: Auth.auth().currentUser!.uid, message: messages[indexPath.row], image: imagePartner)
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var height: CGFloat = 0
        let message = messages[indexPath.row]
        let text = message.text
        if !text.isEmpty {
            height = text.estimateFrameForText(text).height + 60
        }
        
        let heightMessage = message.height
        let widthMessage = message.width
        if heightMessage != 0, widthMessage != 0 {
            height = CGFloat(heightMessage / widthMessage * 250)
        }
        return height
    }
}

