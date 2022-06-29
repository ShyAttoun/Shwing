//
//  BuisnessMapTableViewCell.swift
//  Shwing
//
//  Created by shy attoun on 17/11/2019.
//  Copyright © 2019 shy attoun. All rights reserved.
//

import UIKit
import MapKit

class BuisnessMapTableViewCell: UITableViewCell {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mapicon: UIView!
    
    var controller: BuisnessDetailViewController!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        mapicon.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(showMap))
        mapicon.addGestureRecognizer(tapGesture)
    }
    
    @objc func showMap () {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mapVC = storyboard.instantiateViewController(withIdentifier: IDENTIFIER_BUISNESS_MAP) as! BuisnessMapViewController
        mapVC.buisUsers = [controller.buisUser]
        controller.navigationController?.pushViewController(mapVC,animated: true)
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func configure (location: CLLocation) {
        let annotation = MKPointAnnotation ()
        annotation.coordinate = location.coordinate
        self.mapView.addAnnotation(annotation)
        let region = MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: 250, longitudinalMeters: 250)
        self.mapView.setRegion(region, animated: true)
        
    }
    
}
