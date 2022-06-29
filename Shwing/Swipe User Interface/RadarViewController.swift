//
//  RadarViewController.swift
//  Shwing
//
//  Created by shy attoun on 26/10/2019.
//  Copyright © 2019 shy attoun. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import ProgressHUD
import CoreLocation
import GeoFire

class RadarViewController: UIViewController {

    @IBOutlet weak var boostImg: UIImageView!
    @IBOutlet weak var likeImg: UIImageView!
    @IBOutlet weak var superLikeImg: UIImageView!
    @IBOutlet weak var passImg: UIImageView!
    @IBOutlet weak var refreshImg: UIImageView!
    @IBOutlet weak var cardStack: UIView!
    @IBOutlet weak var matchBlurBackroundScreen: UIVisualEffectView!
    
    @IBOutlet var newMatchPopUpBoxView: UIView!
    @IBOutlet weak var myUserImageMatchBox: UIImageView!
    @IBOutlet weak var myUserNameMatchBoxLbl: UILabel!
    @IBOutlet weak var otherUserImageMatchBox: UIImageView!
    @IBOutlet weak var otherUserNameMatchBoxLbl: UILabel!
    @IBOutlet weak var congratsMatchBoxLbl: UILabel!
    

    let userDefault = UserDefaults.standard
    var userLat = ""
    var userLong = ""
    let manager = CLLocationManager ()
    var geoFire : GeoFire!
    var geoFireRef: DatabaseReference!
    var myQuery: GFQuery!
    var queryHandle: DatabaseHandle?
    var distance: Double = 500
    var users =  [User] ()
    var cards = [Card] ()
    var cardInitialLocationCenter: CGPoint!
    var panInitialLocation: CGPoint!
    var controller: DetailsViewController!
    var effect: UIVisualEffect!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        matchBlurBackroundScreen.isHidden = true
        title = "Shwing"
        configureLocationManager ()
        passImg.isUserInteractionEnabled = true
        likeImg.isUserInteractionEnabled = true
        let tapPassImg = UITapGestureRecognizer(target: self, action: #selector(passImgDidTap))
        passImg.addGestureRecognizer(tapPassImg)
        
        let tapLikeImg = UITapGestureRecognizer(target: self, action: #selector(likeImgDidTap))
        likeImg.addGestureRecognizer(tapLikeImg)
        
                let newMatchItem = UIBarButtonItem(image: UIImage(named: "icon-chat"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(newMatchItemDidTap))
                self.navigationItem.rightBarButtonItem = newMatchItem
    }
    
        @objc func newMatchItemDidTap() {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let newMtachVC = storyboard.instantiateViewController(withIdentifier: IDENTIFIER_NEW_MATCH) as! NewMatchTableViewController
    
            self.navigationController?.pushViewController(newMtachVC, animated: true)
        }
    
    @objc func passImgDidTap () {
        guard let firstCard = cards.first else {
            return
        }
        saveToFirebase (like: false , card: firstCard)
        swipeAnimation(translation: -750 , angle: -15)
        self.setupTransforms()
        
    }
    
    @objc func likeImgDidTap () {
        guard let firstCard = cards.first else {
            return
        }
        saveToFirebase (like: true , card: firstCard)
        swipeAnimation(translation: 750 , angle: 15)
        self.setupTransforms()

    }
    
  
    
    func saveToFirebase (like: Bool , card: Card){
        Ref().databaseActionForUser(uid: Api.User.currentUserId).updateChildValues([card.user.uid: like]) { (error, ref) in
            if error == nil, like == true {
                // check if there is a match {send push notifcation}
                self.checkIfMatchFor(card: card)
            }
        }
    }
    func checkIfMatchFor(card: Card) {
        Ref().databaseActionForUser(uid: card.user.uid).observeSingleEvent(of: .value) { (snapshot) in
            guard let dict = snapshot.value as? [String: Bool] else  {return}
            if dict.keys.contains(Api.User.currentUserId) , dict[Api.User.currentUserId] == true {
                Ref().databaseRoot.child("newMatch").child(Api.User.currentUserId).updateChildValues([card.user.uid: true])
                Ref().databaseRoot.child("newMatch").child(card.user.uid).updateChildValues([Api.User.currentUserId: true])
                
                Api.User.getUserInforSingleEvent(uid: Api.User.currentUserId, onSuccess: { (user) in
                    sendRequestNotification(isMatch: true , fromUser: user, toUser: card.user, message: "Tap to chat with \(user.fullname)", badge: 1)
                    sendRequestNotification(isMatch: true, fromUser: card.user, toUser: user, message: "Tap to chat with \(user.fullname)", badge: 1)
                    
                    
                   
                    self.imageSlideIn()
                    self.newMatchUsersDetails ()
                    self.myUserNameMatchBoxLbl.text = user.fullname
                    self.myUserImageMatchBox.loadImage(user.profileImageurl)
                    self.otherUserImageMatchBox.image = card.user.profileImage
                    self.otherUserNameMatchBoxLbl.text = card.user.fullname
                    self.congratsMatchBoxLbl.text = "You and \(card.user.fullname) liked each other"
                })
            }
        }
    }
    
    func imageSlideIn () {
        view.addSubview(matchBlurBackroundScreen)
        view.addSubview(newMatchPopUpBoxView)
        
        newMatchPopUpBoxView.center = view.center
        newMatchPopUpBoxView.transform = CGAffineTransform(scaleX: 1.5, y: 1.5).translatedBy(x: 0, y: 0)
        
        matchBlurBackroundScreen.transform = CGAffineTransform(scaleX: 1.5, y: 1.5).translatedBy(x: 0, y: 0)
        
        
        UIView.animate(withDuration: 2, delay: 0.5,usingSpringWithDamping: 20, initialSpringVelocity: 0.5, options:[], animations: {
            self.blurEffect()
           self.matchBlurBackroundScreen.effect = self.effect
            self.newMatchPopUpBoxView.transform = CGAffineTransform.identity
            
        })
        
        UIView.animate(withDuration: 4, delay: 0.5, animations: {
            self.matchBlurBackroundScreen.effect = nil
            self.newMatchPopUpBoxView.alpha = 0
        }) {(isComplete) in
       self.newMatchPopUpBoxView.removeFromSuperview()


        }
    }
    
    func newMatchUsersDetails () {
        self.myUserImageMatchBox.layer.cornerRadius = 30
        self.myUserImageMatchBox.clipsToBounds = true
        self.otherUserImageMatchBox.layer.cornerRadius = 30
        self.otherUserImageMatchBox.clipsToBounds = true
        self.matchBlurBackroundScreen.isHidden = false
        
    }
  func  blurEffect () {
         effect = matchBlurBackroundScreen.effect
   
     }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.matchBlurBackroundScreen.isHidden = true
    }
    
    func swipeAnimation(translation : CGFloat , angle: CGFloat){
        let duration = 0.5
        let translationAnimation = CABasicAnimation(keyPath: "position.x")
        translationAnimation.toValue = translation
        translationAnimation.duration = duration
        translationAnimation.fillMode = .forwards
        translationAnimation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        translationAnimation.isRemovedOnCompletion = false
        
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.toValue = angle * CGFloat.pi / 180
        rotationAnimation.duration = duration
        
        guard  let firstCard = cards.first else {
            return
        }
        
        for (index, c) in self.cards.enumerated() {
            if c.user.uid == firstCard.user.uid {
                self.cards.remove(at: index)
                self.users.remove(at: index)
            }
        }
        self.setupGestures()
        CATransaction.setCompletionBlock {
            firstCard.removeFromSuperview()
        }
        firstCard.layer.add(translationAnimation, forKey: "translation")
        firstCard.layer.add(rotationAnimation,forKey: "rotation")
        
        CATransaction.commit()
    }
    
    func configureLocationManager () {
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = kCLDistanceFilterNone
        manager.pausesLocationUpdatesAutomatically = true
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            manager.startUpdatingLocation()
        }
        self.geoFireRef = Ref().databaseGeo
        self.geoFire = GeoFire(firebaseRef: self.geoFireRef)
    }
    
    func setupCard(user: User) {
        let card: Card = UIView.fromNib()
        card.frame = CGRect(x: 0, y: 0, width: cardStack.bounds.width, height: cardStack.bounds.height)
        card.controller = self
        card.user = user
        cards.append(card)
        cardStack.addSubview(card)
        cardStack.sendSubviewToBack(card)
        
        setupTransforms()
        if cards.count == 1 {
            cardInitialLocationCenter = card.center
            card.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(pan(gesture:))))
            
        }
    }
    @objc func pan (gesture: UIPanGestureRecognizer){
        let card = gesture.view as! Card
        let translation = gesture.translation(in: cardStack)
        
        switch  gesture.state {
        case .began:
            panInitialLocation = gesture.location(in: cardStack)
            print("began")
            print("paninitialLocation")
            print(panInitialLocation)
            
        case .changed:
            print("changed")
            print(translation.x)
            print(translation.y)
            
            card.center.x = cardInitialLocationCenter.x + translation.x
            card.center.y = cardInitialLocationCenter.y + translation.y
            
            if translation.x > 0 {
                card.likeView.alpha = abs(translation.x * 2) / cardStack.bounds.midX
                card.nopeView.alpha = 0
            } else {
                card.nopeView.alpha = abs(translation.x * 2) / cardStack.bounds.midX
                card.likeView.alpha = 0
            }
            
            card.transform = self.transform(view: card , for: translation)

        case .ended:
            print("ended")
            
            if translation.x > 75 {
                UIView.animate(withDuration: 0.3, animations: {
                    card.center = CGPoint(x: self.cardInitialLocationCenter.x + 1000, y: self.cardInitialLocationCenter.y + 1000)
                }) { (bool) in
                    card.removeFromSuperview()
                }
                saveToFirebase(like: true, card: card)
                self.updateCards(card: card)
                return
            } else if translation.x < -75 {
                UIView.animate(withDuration: 0.3, animations: {
                    card.center = CGPoint(x: self.cardInitialLocationCenter.x - 1000, y: self.cardInitialLocationCenter.y + 1000)
                }) { (bool) in
                    card.removeFromSuperview()
                    
                }
                saveToFirebase(like: false, card: card)
                self.updateCards(card: card)
                return
            }
            UIView.animate(withDuration: 0.3) {
                card.center = self.cardInitialLocationCenter
                card.likeView.alpha = 0
                card.nopeView.alpha = 0
                card.transform = CGAffineTransform.identity
            }
            
        default:
            break
        }
    }
    func updateCards (card: Card) {
        for (index , c) in self.cards.enumerated() {
            if c.user.uid == card.user.uid {
                self.cards.remove(at: index)
                self.users.remove(at: index)
            }
        }
        setupGestures()
        setupTransforms()
    }
    
    func setupGestures() {
        for card in cards {
            let gestures = card.gestureRecognizers ?? []
            for g  in gestures {
                card.removeGestureRecognizer(g)
            }
        }
        
        if let firstCard = cards.first {
            firstCard.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(pan(gesture:))))
        }
    }
    
    func transform(view: UIView,for translation: CGPoint) -> CGAffineTransform {
        let moveBy = CGAffineTransform(translationX: translation.x , y: translation.y)
        let rotation = -translation.x / (view.frame.width / 2)
        return moveBy.rotated(by: rotation)
    }
    
    func setupTransforms () {
        for (i , card) in  cards.enumerated() {
            if i == 0 {continue;}
            if i > 3 {return}
            
            var transform = CGAffineTransform.identity
            if i % 2 == 0 {
                transform = transform.translatedBy(x: CGFloat(i)*4, y: 0)
                transform = transform.rotated(by: CGFloat(Double.pi)/150*CGFloat(i))
            }else{
                transform = transform.translatedBy(x: -CGFloat(i)*4, y: 0)
                transform = transform.rotated(by: -CGFloat(Double.pi)/150*CGFloat(i))
                
            }
            card.transform = transform
            
        }
    }
    
    func findUsers () {
        if queryHandle != nil , myQuery !=  nil {
            myQuery.removeObserver(withFirebaseHandle: queryHandle!)
            myQuery = nil
            queryHandle = nil
        }
        guard let userLat = userDefault.value(forKey: "current_location_latitude") as? String, let userLong = userDefault.value(forKey: "current_location_longitude") as? String else {return}
        
        let location: CLLocation = CLLocation(latitude: CLLocationDegrees(Double(userLat)!), longitude: CLLocationDegrees(Double(userLong)!))
        self.users.removeAll()
        
        myQuery = geoFire.query(at: location, withRadius: distance)
        
        
        queryHandle = myQuery.observe(GFEventType.keyEntered, with:{  (key, location) in
            
            
            if key != Api.User.currentUserId {
                Api.User.getUserInforSingleEvent(uid: key , onSuccess:  { (user) in
                    if self.users.contains(user) {
                        return
                    }
                    if user.isMale == nil {
                        return
                    }

                    self.users.append(user)
                    self.setupCard(user: user)
                    print(user.fullname)
                })
            }
        })
    }


}

extension RadarViewController : CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if (status == .authorizedAlways) || (status == .authorizedWhenInUse) {
            manager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        ProgressHUD.showError("\(error.localizedDescription)")
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        manager.stopUpdatingLocation()
        manager.delegate = nil
        print ("didUpdateLocations")
        
        let updatedLocation: CLLocation = locations.first!
        let newCoordinate:CLLocationCoordinate2D = updatedLocation.coordinate
        
        userDefault.set("\(newCoordinate.latitude)", forKey: "current_location_latitude")
        userDefault.set("\(newCoordinate.longitude)", forKey: "current_location_longitude")
        userDefault.synchronize()
        
        if let userLat = userDefault.value(forKey: "current_location_latitude") as? String, let userLong = userDefault.value(forKey: "current_location_longitude") as? String {
            let location: CLLocation = CLLocation(latitude: CLLocationDegrees(Double(userLat)!), longitude: CLLocationDegrees(Double(userLong)!))
            Ref().databaseSpecificUser(uid: Api.User.currentUserId).updateChildValues([LAT:userLat , LONG: userLong])
            
            self.geoFire.setLocation(location, forKey: Api.User.currentUserId) {(error) in
                if error == nil {
                    //find users
                    self.findUsers()
                }
                
            }
            
        }
    }
}

