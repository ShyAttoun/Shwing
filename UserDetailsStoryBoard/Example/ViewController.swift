//
//  ViewController.swift
//  Example
//
//  Created by Neverland on 15.08.15.
//  Copyright (c) 2015 ProudOfZiggy. All rights reserved.
//

import UIKit
import SpriteKit

class ViewController: UIViewController {
    fileprivate var skView: SKView!
    fileprivate var floatingCollectionScene: BubblesScene!
    let  music = ["Rock","Pop","Techno","House","Samba","Reggaton","R&B","Middle-Eastern","New Age","Alternative","60s","50s","70s","80s","90s","Opera","Hip-Hop","Heavy-Metal"]
    
    let food = ["Asian","BBQ","Sea-Food","Vegan","Italian","Japanese","South-American","Indian","Middle-Eastern","French","Israeli","Greek"]
    
    let movie = ["Horror","Comedy","Thriller","Drama","Tv Series", "Netflix" ,"Stand-Up","Documentary","Action","Marvel"]
    
  
    override func viewDidLoad() {
        super.viewDidLoad()
      
        skView = SKView(frame: UIScreen.main.bounds)
        skView.backgroundColor = SKColor.white
        view.addSubview(skView)
        
        floatingCollectionScene = BubblesScene(size: skView.bounds.size)
        let navBarHeight = navigationController!.navigationBar.frame.height
        let statusBarHeight = UIApplication.shared.statusBarFrame.height
        floatingCollectionScene.topOffset = navBarHeight + statusBarHeight
        skView.presentScene(floatingCollectionScene)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(commitSelection)
        )
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addBubble)
        )
        
        for i in music {
            let newNode = BubbleNode.instantiate()
            newNode.labelNode.text = i
            floatingCollectionScene.addChild(newNode)
        }
    }
    
    @objc func addBubble() {
      
    }
    
    @objc func commitSelection() {
        floatingCollectionScene.performCommitSelectionAnimation()
    }
}

