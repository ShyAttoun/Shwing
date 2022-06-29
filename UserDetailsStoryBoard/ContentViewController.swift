//
//  ContentViewController.swift
//  Shwing
//
//  Created by shy attoun on 13/09/2019.
//  Copyright © 2019 shy attoun. All rights reserved.
//

import UIKit
import SpriteKit



class ContentViewController: UIViewController {

    fileprivate var skView: SKView!
    var floatingCollectionScene: BubblesScene!
    
    let  music = ["Rock","Pop","Techno","House","Samba","Reggaton","R&B","Middle-Eastern","New Age","Alternative","60s","50s","70s","80s","90s","Opera","Hip-Hop","Heavy-Metal"]
    
    let food = ["Asian","BBQ","Sea-Food","Vegan","Italian","Japanese","South-American","Indian","Middle-Eastern","French","Israeli","Greek"]
    
    let movie = ["Horror","Comedy","Thriller","Drama","Tv Series", "Netflix" ,"Stand-Up","Documentary","Action","Marvel"]
    
    let interest = ["Working-Out","Sex","Hiking","Comics","Traveling", "Netflix" ,"Stand-Up","Documentaries","Sleeping","Cinema","Cooking","Art","Mueseums","Swimming","Extreme Sport","Gaming"]
    
    
    
    @IBOutlet weak var headingLabel: UILabel!
        {
        didSet{
            headingLabel.numberOfLines = 0
        }
    }
    @IBOutlet weak var questionLabel: UITextView!
    
    var index  = 0
    var heading  = ""
    var subheading = ""

    @IBOutlet var ContentVC: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
       
        
        
        if index == 0 {
           setupViews()
        }
        if index != 0 {
        
        skViewSetup()
        }
        
        if index == 1 {
            setupViews()

            for i in music {
                let newNode = BubbleNode.instantiate()
                newNode.labelNode.text = i
                floatingCollectionScene.addChild(newNode)
            }
        }
            
        else if index == 2 {
            setupViews()

            for i in food {
                let newNode = BubbleNode.instantiate()
                newNode.labelNode.text = i
                floatingCollectionScene.addChild(newNode)
            }
        }
            
        else if index == 3 {
            setupViews()

            for i in movie {
                let newNode = BubbleNode.instantiate()
                newNode.labelNode.text = i
                floatingCollectionScene.addChild(newNode)
            }
        }
        
        else if index == 4 {
            setupViews()
            
            for i in interest {
                let newNode = BubbleNode.instantiate()
                newNode.labelNode.text = i
                floatingCollectionScene.addChild(newNode)
            }
        }
      
    }
    
    fileprivate func setupViews() {
        headingLabel.text = heading
        questionLabel.text = subheading
        
        headingLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        headingLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 10).isActive = true
        headingLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 40).isActive = true
        headingLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 40).isActive = true
        headingLabel.widthAnchor.constraint(equalToConstant: 350).isActive = true
        headingLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true
        headingLabel.textAlignment = NSTextAlignment.center
        headingLabel.numberOfLines = 0
        
        
        
        questionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        questionLabel.topAnchor.constraint(equalTo: view.topAnchor , constant: 30).isActive = true
        questionLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 40).isActive = true
        questionLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 40).isActive = true
        questionLabel.widthAnchor.constraint(equalToConstant: 350).isActive = true
        questionLabel.heightAnchor.constraint(equalToConstant: 80).isActive = true
        questionLabel.textColor = UIColor.black
        questionLabel.font = UIFont.italicSystemFont(ofSize: 20)
        questionLabel.font = UIFont(name: "Futura", size: 20)
        
        questionLabel.textAlignment = NSTextAlignment.center

        view.addSubview(headingLabel)
        view.addSubview(questionLabel)
    }
    
    fileprivate func skViewSetup() {
        skView = SKView(frame: UIScreen.main.bounds)
        skView.backgroundColor = SKColor.white
        
        view.addSubview(skView)
        floatingCollectionScene.size = skView.bounds.size
        let navBarHeight = navigationController?.navigationBar.frame.height
        let statusBarHeight = UIApplication.shared.statusBarFrame.height
        floatingCollectionScene.topOffset = navBarHeight ?? 0 + statusBarHeight
        skView.presentScene(floatingCollectionScene)
    }
    
    
    func addBubble() {
        
    }
    
    func commitSelection() {
        floatingCollectionScene.performCommitSelectionAnimation()
    }


}
