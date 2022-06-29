//
//  PageViewController.swift
//  Shwing
//
//  Created by shy attoun on 13/09/2019.
//  Copyright © 2019 shy attoun. All rights reserved.
//

import UIKit
import SpriteKit


protocol WTPVCDelegate: class {
    func didUpdatePageIndex(currentIndex: Int)
}

class PageViewController: UIPageViewController ,UIPageViewControllerDataSource,UIPageViewControllerDelegate {
    
    fileprivate var skView: SKView!
    var floatingCollectionScene: BubblesScene!
    weak var WTDelegate: WTPVCDelegate?
    
    var pageHeadings = ["Welcome to Shwing App!","Music Taste","Food Taste","Movies Taste","Your Hobbies"]
    
    var pageSubHeadings = ["We want to get to know you better,Please share your Interests with us,shall we start?","Tell us more about your Music taste","Talking about Taste,let us know what is your favorite Food is","There is nothing better than having a good meal with a good Movie,What do you like to watch?","Come on,tell us more about the things you like to do"]

    
    
    var currentIndex = 0
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        var index = (viewController as! ContentViewController).index
        index -= 1
        
        return contentViewController(at: index)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        var index = (viewController as! ContentViewController).index
        index += 1
        
        return contentViewController(at: index)
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

        dataSource = self
        delegate = self
        
        self.isPagingEnabled = false

        
        if let startingViewController = contentViewController(at: 0){
            setViewControllers([startingViewController], direction: .forward, animated: true, completion: nil)
        }
    }
    
    func contentViewController (at index: Int) -> ContentViewController? {
        if index < 0 || index >= pageHeadings.count{
            return nil
        }
     
        let storyboard = UIStoryboard(name: "UserDetailsStoryBoard", bundle: nil)
        
        if let pageContentViewController = storyboard.instantiateViewController(withIdentifier: "WTCVC") as? ContentViewController {
            
            pageContentViewController.floatingCollectionScene = floatingCollectionScene
            pageContentViewController.heading = pageHeadings [index]
            pageContentViewController.subheading = pageSubHeadings [index]
            pageContentViewController.index = index
            
            return pageContentViewController
            
        }
        return nil
    }
    
    func forwardPage () {
        currentIndex += 1
        if let nextViewController = contentViewController(at: currentIndex){
            setViewControllers([nextViewController], direction: .forward, animated: true, completion: nil)
        }
    }
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed{
            if let contentViewController = pageViewController.viewControllers?.first as? ContentViewController{
                currentIndex = contentViewController.index
                
                WTDelegate?.didUpdatePageIndex(currentIndex: currentIndex)
            }
        }
    }

   

}


extension UIPageViewController {
    var isPagingEnabled: Bool {
        get {
            var isEnabled: Bool = true
            for view in view.subviews {
                if let subView = view as? UIScrollView {
                    isEnabled = subView.isScrollEnabled
                }
            }
            return isEnabled
        }
        set {
            for view in view.subviews {
                if let subView = view as? UIScrollView {
                    subView.isScrollEnabled = newValue
                }
            }
        }
    }
}
