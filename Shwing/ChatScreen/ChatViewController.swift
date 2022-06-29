//
//  ChatViewController.swift
//  Shwing
//
//  Created by shy attoun on 14/10/2019.
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

class ChatViewController: UIViewController {
    
    var imagePartner: UIImage!
    var avatarImageView: UIImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 36, height: 36))
    var topLbl: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200 , height: 50))
    
    var partnerUserName : String!
    var partnerUser: User!
    var buisnessPartner: BuisnessUser!
    var partnerId: String!
    var placeHolder = UILabel ()
    var picker = UIImagePickerController ()
    var messages = [Message]()
    var isActive = false
    var lastTimeOnline = ""
    var isTyping =  false
    var timer = Timer ()
    var refreshControl = UIRefreshControl()
    var lastMessageKey: String?
   
    @IBOutlet weak var mediaBtn: UIButton!
    @IBOutlet weak var micBtn: UIButton!
    @IBOutlet weak var chatBoxTF: UITextView!
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var chatTableView: UITableView!
    
    @IBOutlet weak var chatViewBottomConst: NSLayoutConstraint!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPicker ()
        setupNativationBar ()
        setupInputContainer ()
        setupTableView ()
        setupView()

    }
    func setupView() {
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func sendBtnDidTapped(_ sender: Any) {
        if let text = chatBoxTF.text,text != "" {
            chatBoxTF.text = ""
            self.textViewDidChange(chatBoxTF)
            sendToFirebase(dict: ["text": text as Any])
        }
    }
    
    @IBAction func mediaBtnDidTapped(_ sender: Any) {
        let alert = UIAlertController(title: "Shwing", message: "Select Source", preferredStyle: UIAlertController.Style.actionSheet)
        let camera = UIAlertAction(title: "Take a picture", style: UIAlertAction.Style.default){(_) in
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera){
                self.picker.sourceType = .camera
                self.present(self.picker, animated: true, completion: nil)
            } else{
                print("Unavailble")
            
            }
     }
        
        let library = UIAlertAction(title: "Choose an Image or Video", style: UIAlertAction.Style.default){(_) in
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary){
            self.picker.sourceType = .photoLibrary
            self.picker.mediaTypes = [String(kUTTypeImage),String(kUTTypeMovie)]
            self.present(self.picker, animated: true, completion: nil)
            }
            else{
                print("Unavailble")
    
            }
            }
        
        let videoCamera = UIAlertAction(title: "Take a video", style: UIAlertAction.Style.default){(_) in
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera){
                self.picker.sourceType = .photoLibrary
                self.picker.mediaTypes = [String(kUTTypeMovie)]
                self.picker.videoExportPreset = AVAssetExportPresetPassthrough
                self.picker.videoMaximumDuration = 30
                self.present(self.picker, animated: true, completion: nil)
            }
            else{
                print("Unavailble")
                
            }
        }
        
        
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel)
        
        alert.addAction(camera)
        alert.addAction(library)
        alert.addAction(cancel)
        alert.addAction(videoCamera)
        
        present(alert, animated: true, completion: nil)
    }
   
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }

    

}

