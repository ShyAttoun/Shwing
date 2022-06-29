//
//  BuisnessLocationCollectionViewController.swift
//  Shwing
//
//  Created by shy attoun on 16/11/2019.
//  Copyright © 2019 shy attoun. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import GoogleSignIn
import FBSDKLoginKit
import FBSDKShareKit
import FBSDKCoreKit
import ProgressHUD
import CoreLocation
import GeoFire



class BuisnessLocationViewController: UIViewController {
    
    
   
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var activitySeg: UISegmentedControl!
    @IBOutlet weak var mapBtn: UIButton!
    
    let userDefault = UserDefaults.standard
    let mySlider = UISlider()
    let distanceLabel = UILabel()
    var userLat = ""
    var userLong = ""
    let manager = CLLocationManager ()
    var geoFire : GeoFire!
    var geoFireRef: DatabaseReference!
    var myQuery: GFQuery!
    var queryHandle: DatabaseHandle?
    var distance: Double = 10
    var users =  [BuisnessUser] ()
    var currentLocation: CLLocation?
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        setupNavigationBar()
      configureLocationManager ()
        
        
    }
   
    
    @IBAction func mapBtnIsTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mapVC = storyboard.instantiateViewController(withIdentifier: "BuisnessMapViewController") as! BuisnessMapViewController
        mapVC.buisUsers = self.users
        self.navigationController?.pushViewController(mapVC, animated: true)
          }
    
    
    @IBAction func activitySegIsTapped(_ sender: Any) {
        findUsers()
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
    
    func findUsers () {
        if queryHandle != nil , myQuery !=  nil {
            myQuery.removeObserver(withFirebaseHandle: queryHandle!)
            myQuery = nil
            queryHandle = nil
        }
        guard let userLat = userDefault.value(forKey: "current_location_latituder") as? String, let userLong = userDefault.value(forKey: "current_location_longituder") as? String else {return}
        
        let location: CLLocation = CLLocation(latitude: CLLocationDegrees(Double(userLat)!), longitude: CLLocationDegrees(Double(userLong)!))
        self.users.removeAll()
        
        myQuery = geoFire.query(at: location, withRadius: distance)
        
        
        queryHandle = myQuery.observe(GFEventType.keyEntered, with:{  (key, location) in
            
            //            print(key)
            //            print(location)
            
            if key != Api.BuisUser.currentUserId {
                Api.BuisUser.getBuisUserInforSingleEvent(uid: key , onSuccess:  { (user) in
                    if self.users.contains(user) {
                        return
                    }
                    
                    if user.isRest == nil {
                        return
                    }

                    switch self.activitySeg.selectedSegmentIndex {
                        
                    case 0:
                        if user.isRest! {
                           
                            self.users.append(user)
                            print(user.buisnessName)

                            
                        }
                    case 1:
                        if user.isNightLife! {
                            self.users.append(user)
                             print(user.buisnessName)


                        }
                    case 2:
                        if user.isLive! {
                            self.users.append(user)
                         print(user.buisnessName)


                        }

                    case 3:
                        if user.isFun! {
                            self.users.append(user)
                          print(user.buisnessName)


                        }

                    default:
                        break


                    }
                    self.collectionView.reloadData()
                    
                })
            }
        })
    }
    
    func setupNavigationBar() {
        title = "Find Places"
        let refresh = UIBarButtonItem(image: UIImage(named: "icon-refresh"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(refreshTapped))
        distanceLabel.frame = CGRect(x: 0, y: 0, width: 50, height: 20)
        distanceLabel.font = UIFont.systemFont(ofSize: 13)
        distanceLabel.text = "\(Int(distance)) km"
        distanceLabel.textColor = UIColor(red: 93/255, green: 79/255, blue: 141/255, alpha: 1)
        let distanceItem = UIBarButtonItem(customView: distanceLabel)
        
        mySlider.frame = CGRect(x: 0, y: 0, width: 200, height: 20)
        mySlider.minimumValue = 1
        mySlider.maximumValue = 20
        mySlider.isContinuous = true
        mySlider.value = Float(distance)
        mySlider.tintColor = UIColor(red: 93/255, green: 79/255, blue: 141/255, alpha: 1)
        mySlider.addTarget(self, action: #selector(sliderValueChanged(slider:event:)), for: UIControl.Event.valueChanged)
        
        navigationItem.rightBarButtonItems = [refresh, distanceItem]
        navigationItem.titleView = mySlider
    }
    
    @objc func refreshTapped() {
        findUsers()
    }
    
    @objc func sliderValueChanged(slider: UISlider, event: UIEvent) {
        print(Double(slider.value))
        if let touchEvent = event.allTouches?.first {
            distance = Double(slider.value)
            distanceLabel.text = "\( Int(slider.value)) km"
            
            switch touchEvent.phase {
            case .began:
                print("began")
            case .moved:
                print("moved")
            case .ended:
                findUsers()
            default:
                break
                
            }
        }
    }
    
    
    
}
extension BuisnessLocationViewController:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.users.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BuisnessCollectionCell", for: indexPath) as! BuisnessCollectionViewCell
        let user = users[indexPath.item]
        cell.controller = self
        cell.loadData(user, currentLocation: self.currentLocation)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell  = collectionView.cellForItem(at: indexPath) as? BuisnessCollectionViewCell {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let detailVC = storyboard.instantiateViewController(withIdentifier: "BuisnessDetailViewController") as! BuisnessDetailViewController
            detailVC.buisUser = cell.user
            
            self.navigationController?.pushViewController(detailVC, animated: true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.size.width/3-2, height: view.frame.size.width/3)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
}

extension BuisnessLocationViewController : CLLocationManagerDelegate {
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
        
        self.currentLocation = updatedLocation
        userDefault.set("\(newCoordinate.latitude)", forKey: "current_location_latituder")
        userDefault.set("\(newCoordinate.longitude)", forKey: "current_location_longituder")
        userDefault.synchronize()
        
        if let userLat = userDefault.value(forKey: "current_location_latituder") as? String, let userLong = userDefault.value(forKey: "current_location_longituder") as? String {
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
extension BuisnessUser: Equatable {
    static func == (lhs: BuisnessUser,rhs: BuisnessUser ) -> Bool {
        return lhs.uid == rhs.uid
    }
}
