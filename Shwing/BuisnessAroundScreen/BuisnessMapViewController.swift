//
//  BuisnessMapViewController.swift
//  Shwing
//
//  Created by shy attoun on 17/11/2019.
//  Copyright © 2019 shy attoun. All rights reserved.
//

import UIKit
import MapKit

class BuisnessMapViewController: UIViewController ,MKMapViewDelegate {
    
    @IBOutlet weak var mapSeg: UISegmentedControl!
    @IBOutlet weak var backMapBtn: UIButton!
    
    
    var buisUsers = [BuisnessUser] ()
    var currentTransportType = MKDirectionsTransportType.automobile
    var currentRoute: MKRoute?
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        
        addAnnotation ()
    }
    @IBAction func mapBackBtnIsTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = false
        self.tabBarController?.tabBar.isHidden = false
    }
    
    fileprivate func setupViews() {
        //gps
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapSeg.isHidden = true
        mapSeg.addTarget(self, action: #selector(showDirection(coordinate:)), for: UIControl.Event.valueChanged)
        
        let backImg = UIImage(named: "back")?.withRenderingMode(.alwaysTemplate)
        backMapBtn.setImage(backImg, for: UIControl.State.normal)
        backMapBtn.tintColor = UIColor(red: 93/255, green: 79/255, blue: 141/255, alpha: 1)
    }
    
    //gps
    @objc func showDirection (coordinate: CLLocationCoordinate2D) {
        switch  mapSeg.selectedSegmentIndex {
        case 0: self.currentTransportType = .automobile
        case 1: self.currentTransportType = .walking
        default:
            break
        }
        print(coordinate)
        mapSeg.isHidden = false
        let directionReq = MKDirections.Request()
        directionReq.source = MKMapItem.forCurrentLocation()
        let destinationPlaceMark = MKPlacemark(coordinate: coordinate)
        directionReq.destination = MKMapItem(placemark: destinationPlaceMark)
        directionReq.transportType = currentTransportType
        
        let directions = MKDirections(request: directionReq)
        
        directions.calculate { (routeResponse, error) in
            guard let routeResponse = routeResponse else {
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                }
                return
            }
            let route = routeResponse.routes[0]
            self.currentRoute = route
            self.mapView.removeOverlays(self.mapView.overlays)
            self.mapView.addOverlay(route.polyline , level: MKOverlayLevel.aboveRoads)
            let rect = route.polyline.boundingMapRect
            self.mapView.setRegion(MKCoordinateRegion.init(rect), animated: true)
        }
    }
    //gps
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay ) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = (currentTransportType == .automobile) ? UIColor(red: 93/255, green: 79/255, blue: 141/255, alpha: 1) : UIColor.orange
        renderer.lineWidth = 3.0
        return renderer
    }
    
    //gps
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if let coordinate = view.annotation?.coordinate {
            showDirection(coordinate: coordinate)
        }
    }
    
    func addAnnotation () {
        var nearByAnnotations: [MKAnnotation] = []
        
        for user  in buisUsers {
            let location =  CLLocation(latitude: Double(user.latidude)!, longitude: Double(user.longitude)!)
            
            let annotation =  BuisnessUserAnnotation ()
            annotation.title = user.buisnessName
            annotation.coordinate = location.coordinate
            annotation.profileImage = user.logoImage
            nearByAnnotations.append(annotation)
            
        }
        self.mapView.showAnnotations(nearByAnnotations, animated: true)
    }
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "MyPin"
        var annotationView: MKAnnotationView?
        
        
        if annotation.isKind(of: MKUserLocation.self) {
            annotationView = MKAnnotationView (annotation: annotation, reuseIdentifier: "User")
            annotationView?.image = UIImage  (named: "me")
        } else if let deqAno = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) {
            annotationView = deqAno
            annotationView?.annotation = annotation
        } else {
            let annoView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annoView.rightCalloutAccessoryView = UIButton (type: UIButton.ButtonType.detailDisclosure)
            annotationView = annoView
        }
        if let annotationView = annotationView, let anno = annotation as? BuisnessUserAnnotation {
            annotationView.canShowCallout = true
            
            let image = anno.profileImage
            let resizeRenderImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            resizeRenderImageView.layer.cornerRadius = 25
            resizeRenderImageView.clipsToBounds = true
            resizeRenderImageView.contentMode = .scaleToFill
            resizeRenderImageView.image = image
            
            UIGraphicsBeginImageContextWithOptions(resizeRenderImageView.frame.size, false, 0.0)
            resizeRenderImageView.layer.render(in: UIGraphicsGetCurrentContext()!)
            let thumbnail = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            annotationView.image = thumbnail
            
            let btn = UIButton ()
            btn.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
            btn.setImage(UIImage(named: "direction"), for: UIControl.State.normal)
            annotationView.rightCalloutAccessoryView =  btn
            
            let leftIconView = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
            if let isRest = anno.isRest {
                leftIconView.image = (isRest == true) ?  UIImage(named: "restaurant") : UIImage(named: "live")
            }
            else {
                leftIconView.image = UIImage(named: "genders")
            }
            annotationView.leftCalloutAccessoryView = leftIconView
        }
        return annotationView
    }
    
}
