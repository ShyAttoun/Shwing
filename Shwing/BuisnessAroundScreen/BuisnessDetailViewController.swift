//
//  BuisnessDetailViewController.swift
//  Shwing
//
//  Created by shy attoun on 17/11/2019.
//  Copyright © 2019 shy attoun. All rights reserved.
//

import UIKit
import CoreLocation

class BuisnessDetailViewController: UIViewController {


        @IBOutlet weak var tableView: UITableView!
        @IBOutlet weak var backBtn: UIButton!
        @IBOutlet weak var avatar: UIImageView!
        @IBOutlet weak var usernameLnl: UILabel!

        var selectedIndex : NSInteger! = -1
        var buisUser: BuisnessUser!
        var textview = UITextView ()
    
        override func viewDidLoad() {
            super.viewDidLoad()
            tableView.contentInsetAdjustmentBehavior = .never
            
            
            
            let backImg = UIImage(named: "close")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
            backBtn.setImage(backImg, for: UIControl.State.normal)
            backBtn.tintColor = .white
            backBtn.layer.cornerRadius = 35/2
            backBtn.clipsToBounds = true
            
            avatar.image = buisUser.logoImage
            let frameGradient = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 350)
            avatar.addBlackGradientLayer(frame: frameGradient, colors: [.clear,.black])
            
            usernameLnl.text = buisUser.buisnessName

            tableView.dataSource = self
            tableView.delegate = self
            
        }
        
        @IBAction func backBtnIsTapped(_ sender: Any) {
            navigationController?.popViewController(animated: true)
            
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
    
    extension BuisnessDetailViewController: UITableViewDataSource ,UITableViewDelegate{
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return 5
        }
        
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
                 self.tableView.beginUpdates()
                 self.tableView.endUpdates()
            if indexPath.row == selectedIndex{
                  selectedIndex = -1
              }else{
                  selectedIndex = indexPath.row
              }
              tableView.reloadData()
             }
        
        func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
        }
        
        func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            
            if indexPath.row == 4 {
                return 300
                }
                

          return 45
            
      
        }
     
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            switch indexPath.row {
            case 0 :
                let cell = tableView.dequeueReusableCell(withIdentifier: "DefaultBuisCell" , for: indexPath)
                cell.imageView?.image = UIImage(named: "phone")
                cell.textLabel?.text = buisUser.phone
                cell.selectionStyle = .none
                
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "DefaultBuisCell" , for: indexPath)
                cell.imageView?.image = UIImage(named: "map")
                
                if !buisUser.address.isEmpty {
                cell.textLabel?.text = buisUser.address.description
                }
                    
              else if !buisUser.latidude.isEmpty,!buisUser.longitude.isEmpty {
                    let location =  CLLocation(latitude: CLLocationDegrees(Double(buisUser.latidude)!), longitude: CLLocationDegrees(Double(buisUser.longitude)!))

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
                let cell = tableView.dequeueReusableCell(withIdentifier: "DefaultBuisCell" , for: indexPath)
                cell.imageView?.image = UIImage(named: "gift")
                cell.textLabel?.numberOfLines = 0
                cell.textLabel?.text = "Our special offer is: \(buisUser.myOffer)"
                cell.selectionStyle = .none
                
                return cell
                
                case 3:
                    
            let cell = tableView.dequeueReusableCell(withIdentifier: "AboutBuisCell" , for: indexPath)
            cell.translatesAutoresizingMaskIntoConstraints = true
            
            cell.imageView?.image = UIImage(named: "about")
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.text = "Something about us, We Are an \(buisUser.about)"

            
            cell.selectionStyle = .none

                return cell
            case 4:
                let cell = tableView.dequeueReusableCell(withIdentifier: "BuissnessMapCell" , for: indexPath) as! BuisnessMapTableViewCell
                cell.controller = self
                if !buisUser.latidude.isEmpty,!buisUser.longitude.isEmpty {
                    let location =  CLLocation(latitude: CLLocationDegrees(Double(buisUser.latidude)!), longitude: CLLocationDegrees(Double(buisUser.longitude)!))
                    cell.configure(location: location)
                }
                cell.selectionStyle = .none
           
            default:
                break
            }
            return UITableViewCell()
        }
}
