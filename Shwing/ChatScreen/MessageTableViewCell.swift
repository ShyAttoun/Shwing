//
//  MessageTableViewCell.swift
//  Shwing
//
//  Created by shy attoun on 15/10/2019.
//  Copyright © 2019 shy attoun. All rights reserved.
//

import UIKit
import AVFoundation

class MessageTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var textMessageLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var bubbleView: UIView!
    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var photoMessage: UIImageView!
    
    @IBOutlet weak var bubbleLeftConst: NSLayoutConstraint!
    @IBOutlet weak var widthConst: NSLayoutConstraint!
    
    @IBOutlet weak var bubbleRightConst: NSLayoutConstraint!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    @IBOutlet weak var timeStampChatLbl: UILabel!
    
    var playerLayer: AVPlayerLayer?
    var player: AVPlayer?
    var message: Message!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        bubbleView.layer.cornerRadius = 15
        bubbleView.clipsToBounds = true
        bubbleView.layer.borderWidth = 0.4
        textMessageLbl.numberOfLines = 0
        photoMessage.layer.cornerRadius = 15
        photoMessage.clipsToBounds = true
        profileImage.layer.cornerRadius = 16
        profileImage.clipsToBounds = true
        
        photoMessage.isHidden = true
        profileImage.isHidden = true
        textMessageLbl.isHidden = true
        
        activityIndicatorView.isHidden = true
        activityIndicatorView.stopAnimating()
        activityIndicatorView.style = .whiteLarge
    }
    
    
    @IBAction func playVideoBtn(_ sender: Any) {
        handlePlayBtn()
    }
    
    var observation: Any? = nil
    
    func handlePlayBtn (){
    let videoUrl = message.videoUrl
        if videoUrl.isEmpty {
            return
        }
        
        if let url = URL(string: videoUrl){
            activityIndicatorView.isHidden = false
            activityIndicatorView.startAnimating()
            
            player = AVPlayer(url: url)
            playerLayer = AVPlayerLayer(player: player)
            playerLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
            playerLayer?.frame = photoMessage.frame
            observation = player?.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions.new, context: nil)
           bubbleView.layer.addSublayer(playerLayer!)
            player?.play()
            playBtn.isHidden = true
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "status" {
            let status: AVPlayer.Status = player!.status
            switch (status){
            case AVPlayer.Status.readyToPlay:
                activityIndicatorView.isHidden = true
                activityIndicatorView.stopAnimating()
                break
            case AVPlayer.Status.unknown, AVPlayer.Status.failed:
                break
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        photoMessage.isHidden = true
        profileImage.isHidden = true
        textMessageLbl.isHidden = true
        
        if observation != nil {
            stopObservation()
        }
        playerLayer?.removeFromSuperlayer()
        player?.pause()
        playBtn.isHidden = true
        activityIndicatorView.isHidden = true
        activityIndicatorView.stopAnimating()
    }
    
    func stopObservation() {
        player?.removeObserver(self, forKeyPath: "status")
        observation = nil
    }
    
    func configureCell (uid: String , message: Message , image: UIImage) {
        self.message = message
        let text = message.text
        if !text.isEmpty {
        textMessageLbl.isHidden = false
        textMessageLbl.text = message.text
            
            let widthValue = text.estimateFrameForText(text).width + 40
            
            if widthValue < 100 {
                widthConst.constant = 100
            } else {
                widthConst.constant = widthValue
            }
            dateLbl.textColor = .lightGray
            
        } else {
            photoMessage.isHidden = false
            photoMessage.loadImage(message.imageUrl)
            bubbleView.layer.borderColor = UIColor.clear.cgColor
            widthConst.constant = 250
            dateLbl.textColor = .white
            
        }
        
        if uid == message.from {
            bubbleView.backgroundColor = UIColor.groupTableViewBackground
            bubbleView.layer.borderColor = UIColor.clear.cgColor
            bubbleRightConst.constant = 8
            bubbleLeftConst.constant = UIScreen.main.bounds.width - widthConst.constant - bubbleRightConst.constant
        } else {
            profileImage.isHidden = false
            bubbleView.backgroundColor = UIColor.white
            profileImage.image = image
            bubbleView.layer.borderColor = UIColor.lightGray.cgColor
            bubbleLeftConst.constant = 55
            bubbleRightConst.constant = UIScreen.main.bounds.width - widthConst.constant - bubbleLeftConst.constant
            
        }
        
        let date = Date(timeIntervalSince1970: message.date)
        let dateString = timeAgoSinceDate(date, currentDate: Date(), numericDates: true)
        dateLbl.text = dateString
        self.formatTimeStampInChat(time: date) { (text) in
            self.timeStampChatLbl.text = text
        }
    }
    func formatTimeStampInChat (time: Date ,completion : @escaping (String) -> () ) {
        var text = ""
        let currentDate = Date ()
        let currentDateString = currentDate.toString(dateForamt: "yyyyMMdd")
        let pastDateString = time.toString(dateForamt: "yyyyMMdd")
        print(currentDateString)
        print(pastDateString)
        if pastDateString.elementsEqual(currentDateString) == true {
            text = time.toString(dateForamt: "HH:mm a") + ", Today"
        }else{
            text = time.toString(dateForamt:  "dd/MM/yyyy")
        }
        completion(text)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
