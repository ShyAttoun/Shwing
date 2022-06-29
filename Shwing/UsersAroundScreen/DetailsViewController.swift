//
//  UserDetailsViewController.swift
//  Shwing
//
//  Created by shy attoun on 25/10/2019.
//  Copyright © 2019 shy attoun. All rights reserved.
//

import UIKit
import CoreLocation
import ImageSlideshow

class DetailsViewController: UIViewController,UIScrollViewDelegate {

    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var ageLbl: UILabel!
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var usernameLnl: UILabel!
    @IBOutlet weak var genderImage: UIImageView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var scrollView: UIScrollView!

    
    var currentImage: Int = 0
    var frame = CGRect(x: 0, y: 0, width: 0, height: 0)
    var user: User!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pageControl.numberOfPages = 5


        for index in 0..<5{
            frame.origin.x = scrollView.frame.size.width * CGFloat(index)
            frame.size = scrollView.frame.size
            let imgview = UIImageView(frame: frame)
           
            if index == 0 {
                imgview.loadImage(user.profileImageurl)
            }
            else if index == 1 {
                imgview.loadImage(user.profileImageurl1)
            }
            else if index == 2 {
                imgview.loadImage(user.profileImageurl2)
            }
            else if index == 3 {
                imgview.loadImage(user.profileImageurl3)
            }
            else {
                imgview.loadImage(user.profileImageurl4)
            }
            

            let frameGradient = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 350)
            imgview.addBlackGradientLayer(frame: frameGradient, colors: [.clear,.black])
            self.scrollView.addSubview(imgview)
            
        }
        scrollView.contentSize = CGSize(width: (scrollView.frame.size.width  * CGFloat(5)), height: scrollView.frame.size.height)
        scrollView.delegate = self

        tableView.contentInsetAdjustmentBehavior = .never
        sendBtn.layer.cornerRadius = 5
        sendBtn.clipsToBounds = true
        
        let backImg = UIImage(named: "close")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        backBtn.setImage(backImg, for: UIControl.State.normal)
        backBtn.tintColor = .white
        backBtn.layer.cornerRadius = 35/2
        backBtn.clipsToBounds = true

        usernameLnl.text = user.fullname
        if user.age !=  nil {
            ageLbl.text = "\(user.age!)"
        } else {
            ageLbl.text = ""
        }
        
        if let isMale = user.isMale {
            let genderImgName = (isMale == true) ? "male" : "female"
            genderImage.image = UIImage (named: genderImgName)?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        }else{
            genderImage.image = UIImage (named: "genders")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
            
        }
        
        genderImage.tintColor = .white
        tableView.dataSource = self
        tableView.delegate = self
        
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        var pageNumber = scrollView.contentOffset.x / scrollView.frame.size.width
        pageControl.currentPage = Int(pageNumber)
    }

    @IBAction func backBtnIsTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)

    }
    
    @IBAction func sendMessageBtnIsTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let chatVC = storyboard.instantiateViewController(withIdentifier: IDENTIFIER_CHAT) as! ChatViewController
        
        chatVC.imagePartner = avatar.image
        chatVC.partnerUserName = usernameLnl.text
        chatVC.partnerId = user.uid
        chatVC.partnerUser = user
        
        navigationController?.pushViewController(chatVC, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.isHidden = false
        
    }
}

extension DetailsViewController: UITableViewDataSource ,UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 3 {
            return 300
        }
        return 44
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0 :
            let cell = tableView.dequeueReusableCell(withIdentifier: "DefaultCell" , for: indexPath)
            cell.imageView?.image = UIImage(named: "phone")
            cell.textLabel?.text = "2113242414"
            cell.selectionStyle = .none

            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "DefaultCell" , for: indexPath)
            cell.imageView?.image = UIImage(named: "map")
            if !user.latidude.isEmpty,!user.longitude.isEmpty {
                let location =  CLLocation(latitude: CLLocationDegrees(Double(user.latidude)!), longitude: CLLocationDegrees(Double(user.longitude)!))
                
                let geocoder = CLGeocoder ()
                
                geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
                    if error == nil ,let placemarksArray = placemarks ,placemarksArray.count > 0 {
                        if let placeMark = placemarksArray.last {
                            var text = ""
                            if let thoroughFare = placeMark.thoroughfare{
                                text = "\(thoroughFare)"
                                cell.textLabel?.text = text
                            }
                            if let postalCode = placeMark.postalCode{
                                text = text + " " + postalCode
                                cell.textLabel?.text = text
                            }
                            if let locality = placeMark.thoroughfare{
                                text = text + " " + locality
                                cell.textLabel?.text = text
                            }
                            if let country = placeMark.thoroughfare{
                                text = text + " " + country
                                cell.textLabel?.text = text
                            }
                        }
                    }
                }
            }
            cell.selectionStyle = .none
            
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "DefaultCell" , for: indexPath)
            cell.textLabel?.text = user.status
            cell.selectionStyle = .none

            return cell
            
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "MapCell" , for: indexPath) as! MapTableViewCell
            cell.controller = self
            if !user.latidude.isEmpty,!user.longitude.isEmpty {
                let location =  CLLocation(latitude: CLLocationDegrees(Double(user.latidude)!), longitude: CLLocationDegrees(Double(user.longitude)!))
                cell.configure(location: location)
            }
            cell.selectionStyle = .none
            
        default:
            break
        }
        return UITableViewCell()
    }
}


//        var swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture) )
//        swipeRight.direction = UISwipeGestureRecognizer.Direction.right
//          self.view.addGestureRecognizer(swipeRight)
//
//          var swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture))
//        swipeLeft.direction = UISwipeGestureRecognizer.Direction.left
//          self.view.addGestureRecognizer(swipeLeft)


//    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {
//
//        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
//
//
//            switch swipeGesture.direction {
//            case UISwipeGestureRecognizer.Direction.left:
//                if currentImage == images.count  {
//
//                    pageControl?.currentPage = images.count
//
//                }else{
//                    currentImage += 1
//                    pageControl?.currentPage += 1
//                }
//                avatar.image = UIImage(named: images[currentImage])
//
//            case UISwipeGestureRecognizer.Direction.right:
//                if currentImage == 0 {
//                    pageControl?.currentPage = 0
//                }else{
//                    currentImage -= 1
//                    pageControl?.currentPage -= 1
//                }
//                avatar.image = UIImage(named: images[currentImage])
//            default:
//                break
//            }
//        }
//    }
//
//    @IBAction func previousImageBtn(_ sender: Any) {
////        if let index = pageControl?.currentPage {
////            switch index {
////            case 0:
////
////                avatar.image = user.profileImage
////            case 1:
////
////                avatar.loadImage(user.profileImageurl1)
////                pageControl?.currentPage -= 1
////            case 2:
////
////                avatar.loadImage(user.profileImageurl2)
////                pageControl?.currentPage -= 1
////            case 3:
////
////                avatar.loadImage(user.profileImageurl3)
////                pageControl?.currentPage -= 1
////            case 4:
////
////                avatar.loadImage(user.profileImageurl4)
////                pageControl?.currentPage -= 1
////            default:
////                         break
////                     }
////                 }
//    }
    
//    @IBAction func nextImageBtn(_ sender: Any) {
//        if let index = pageControl?.currentPage {
//            switch index {
//            case 0:
//                avatar.image = user.profileImage
//                pageControl?.currentPage += 1
//
//            case 1:
//                avatar.loadImage(user.profileImageurl1)
//                pageControl?.currentPage += 1
//
//            case 2:
//                avatar.loadImage(user.profileImageurl2)
//                pageControl?.currentPage += 1
//
//            case 3:
//                avatar.loadImage(user.profileImageurl3)
//                pageControl?.currentPage += 1
//
//
//            case 4:
//                avatar.loadImage(user.profileImageurl4)
//
//            default:
//                break
//            }
//        }
//        updateUI ()
//    }
//    func updateUI (){
//        if let index = pageControl?.currentPage {
//            switch index {
//            case 0:
//
//                leftSkipImageBtn.isHidden = true
//
//            case 1, 2 ,3:
//                leftSkipImageBtn.isHidden = false
//                rightSkipImageBtn.isHidden = false
//
//
//
//            case 4:
//
//                rightSkipImageBtn.isHidden = true
//
//            default:break
//            }
//            pageControl.currentPage = index
//        }
//    }
    
       func didUpdatePageIndex(currentIndex: Int) {
//           updateUI()

       }
