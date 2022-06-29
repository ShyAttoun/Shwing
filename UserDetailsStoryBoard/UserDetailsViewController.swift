//
//  UserDetailsViewController.swift
//  Shwing
//
//  Created by shy attoun on 13/09/2019.
//  Copyright © 2019 shy attoun. All rights reserved.
//

import UIKit
import SpriteKit
import FirebaseAuth
import FirebaseCore
import Firebase
import GoogleSignIn
import FBSDKLoginKit
import FBSDKShareKit
import FBSDKCoreKit
import MessageUI
import Lottie
import FirebaseStorage
import RangeSeekSlider
import ProgressHUD


class UserDetailsViewController: UIViewController,WTPVCDelegate {
  
    fileprivate var skView: SKView!
    fileprivate var floatingCollectionScene = BubblesScene()
    var bubble = BubblesScene ()
    var wtpvc: PageViewController?
   
    @IBOutlet weak var alertLabel: UILabel!
    @IBOutlet weak var pageControl: UIPageControl!
    
    @IBOutlet weak var doneBtn: UIButton!{
        didSet {
            doneBtn.layer.cornerRadius = 25.0
            doneBtn.layer.masksToBounds = true
          
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        


    }
    

    @IBAction func doneBtnTapped(_ sender: Any) {
        if let index  = wtpvc?.currentIndex {
            switch index {
            case 0:
                
                wtpvc?.forwardPage()
            case 1:
                print(floatingCollectionScene.names.description)
                if floatingCollectionScene.names.count > 2 {
                    floatingCollectionScene.performCommitSelectionAnimation()
                    var dict = Dictionary<String, Any>()
                    dict["music"] = floatingCollectionScene.names.description
                
                    Api.User.saveUserInterests(dict: dict, onSuccess: {
                        
                        ProgressHUD.showSuccess()
                    }) { (error) in
                        ProgressHUD.showError(error)
                    }
                    wtpvc?.forwardPage()
                    alertLabel.text = ""
                }else{
                    alertLabel.text = "Choose 3 types [min]"
                }
            case 2:
                print(floatingCollectionScene.names.description)
                if floatingCollectionScene.names.count > 2 {
                    floatingCollectionScene.performCommitSelectionAnimation()
                    var dict = Dictionary<String, Any>()
                    dict["food"] = floatingCollectionScene.names.description
                    
                    Api.User.saveUserInterests(dict: dict, onSuccess: {
                        
                        ProgressHUD.showSuccess()
                    }) { (error) in
                        ProgressHUD.showError(error)
                    }
                    wtpvc?.forwardPage()
                    alertLabel.text = ""
                }else{
                    alertLabel.text = "Choose 3 types [min]"
                }
            case 3:
                print(floatingCollectionScene.names.description)
                if floatingCollectionScene.names.count > 2 {
                    floatingCollectionScene.performCommitSelectionAnimation()
                    var dict = Dictionary<String, Any>()
                    dict["movies"] = floatingCollectionScene.names.description
                    
                    Api.User.saveUserInterests(dict: dict, onSuccess: {
                        
                        ProgressHUD.showSuccess()
                    }) { (error) in
                        ProgressHUD.showError(error)
                    }
                    wtpvc?.forwardPage()
                    alertLabel.text = ""
                }else{
                    alertLabel.text = "Choose 3 types [min]"
                }
            case 4:
                print(floatingCollectionScene.names.description)
                if floatingCollectionScene.names.count > 2 {
                    floatingCollectionScene.performCommitSelectionAnimation()
                    var dict = Dictionary<String, Any>()
                    dict["hobbies"] = floatingCollectionScene.names.description
                    
                    Api.User.saveUserInterests(dict: dict, onSuccess: {
                        
                        ProgressHUD.showSuccess()
                    }) { (error) in
                        ProgressHUD.showError(error)
                    }
                    alertLabel.text = ""
                    UserDefaults.standard.set(true, forKey: "hasViewedWalkthrough")
                    dismiss(animated: true, completion: nil)
                }else{
                    alertLabel.text = "Choose 3 types [min]"
                }
               
                
            default: break
            }
        }
        updateUI()
    }
    
    func updateUI (){
        if let index = wtpvc?.currentIndex {
            switch index {
            case 0:
              
                doneBtn.setTitle("LETS START!", for: .normal)
    
            case 1, 2 ,3:
                
                doneBtn.setTitle("Done", for: .normal)
            
            case 4:

                doneBtn.setTitle("Finish", for: .normal)
                
            default:break
            }
            pageControl.currentPage = index
        }
    }
    
    func didUpdatePageIndex(currentIndex: Int) {
        updateUI()

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination
        if let pageViewController = destination as? PageViewController {
            pageViewController.floatingCollectionScene = self.floatingCollectionScene
            wtpvc =  pageViewController
            wtpvc?.WTDelegate = self
        }
    }
}
