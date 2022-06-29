//
//  AppDelegate.swift
//  Shwing
//
//  Created by shy attoun on 14/08/2019.
//  Copyright © 2019 shy attoun. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import GoogleSignIn
import FBSDKCoreKit
import FBSDKLoginKit
import FBSDKShareKit
import UserNotifications




@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?

    let userDefault = UserDefaults()
    
    static var isToken: String? = nil
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        UITabBar.appearance().tintColor = UIColor(red: 93/255, green: 79/255, blue: 141/255, alpha: 1)
   
        UINavigationBar.appearance().tintColor = UIColor(red: 93/255, green: 79/255, blue: 141/255, alpha: 1)
        let backImg = UIImage(named: "back")
        UINavigationBar.appearance().backIndicatorImage = backImg
        UINavigationBar.appearance().backIndicatorTransitionMaskImage = backImg
        UIBarButtonItem.appearance().setBackButtonTitlePositionAdjustment(UIOffset.init(horizontal: -1000, vertical: 0),for: UIBarMetrics.default)
        
        FirebaseApp.configure()
        configureInitialViewController()
        
        if #available(iOS 10.0, *) {
            let current = UNUserNotificationCenter.current()
            let options: UNAuthorizationOptions = [.sound, .badge, .alert]
            
            current.requestAuthorization(options: options) { (granted, error) in
                if error != nil {
                    
                } else {
                    Messaging.messaging().delegate = self
                    current.delegate = self
                    
                    DispatchQueue.main.async {
                        application.registerForRemoteNotifications()
                    }
                }
            }
        } else {
            let types: UIUserNotificationType = [.sound, .badge, .alert]
            let settings = UIUserNotificationSettings(types: types, categories: nil)
            
            application.registerUserNotificationSettings(settings)
            application.registerForRemoteNotifications()
        }
        
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        UNUserNotificationCenter.current().delegate = self
        
    
      
        return true
    }
    
   
    
    func configureInitialViewController() {
        var initialVC: UIViewController

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        if UserDefaults.standard.bool(forKey: "buisnessUserSignedinwithemail"){
            
            let buisnessStoryboard = UIStoryboard(name: "BuisnessStoryboard", bundle: nil)
            
            initialVC  = buisnessStoryboard.instantiateViewController(withIdentifier: "BuisnessSetupPage")  
        }
            
       else if Auth.auth().currentUser != nil {
            initialVC = storyboard.instantiateViewController(withIdentifier: "MainViewController")
            
        }
        else {
            initialVC = storyboard.instantiateViewController(withIdentifier: "LoginController")
        }
        window?.rootViewController = initialVC
        window?.makeKeyAndVisible()
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        var handled = false
        
        if url.absoluteString.contains("fb"){
             handled = ApplicationDelegate.shared.application(app ,open: url, options: options)
        } else {
            handled = GIDSignIn.sharedInstance()!.handle(url, sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String, annotation: [:])
        }
        return handled
    }
}

func applicationWillResignActive(_ application: UIApplication) {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    Api.User.isOnline(bool: false)
   

}

func applicationDidEnterBackground(_ application: UIApplication) {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    Api.User.isOnline(bool: false)
    Messaging.messaging().shouldEstablishDirectChannel = false
    

    
}

func applicationWillEnterForeground(_ application: UIApplication) {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    

}

func applicationDidBecomeActive(_ application: UIApplication) {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    Api.User.isOnline(bool: true)
    connectToFirebase()
    
}

func applicationWillTerminate(_ application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
   let gcmMessageIDKey = "gcm.message_id"
    
    if let messageId = userInfo[gcmMessageIDKey] {
        print("messageId: \(messageId)")
    }
    
    print(userInfo)
}

func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
   let gcmMessageIDKey = "gcm.message_id"
    if let messageID = userInfo[gcmMessageIDKey] {
        print("messageID: \(messageID)")
    }
    
    connectToFirebase()
    Messaging.messaging().appDidReceiveMessage(userInfo)
    
    if let dictString = userInfo["gcm.notification.customData"] as? String {
        print("dictString \(dictString)")
        if let dict = convertToDictionary(text: dictString) {
            if let uid = dict["userId"] as? String,
                let fullname = dict["fullname"] as? String,
                let email = dict["email"] as? String,
                let profileImageUrl = dict["profileImageurl"] as? String ,
                let profileImageurl1 = dict["profileImageurl1"] as? String,
                let profileImageurl2 = dict["profileImageurl2"] as? String,
                let profileImageurl3 = dict["profileImageurl3"] as? String,
                let profileImageurl4 = dict["profileImageurl4"] as? String,
                let city = dict["city"] as? String,
                let state = dict["state"] as? String,
                let myStatusStr = dict["myStatus"] as? String,
                let searchForStatusStr = dict["searchForStatus"] as? String,
                let buisnessName = dict["buisness name"] as? String,
                let phone = dict["phone"] as? String,
                let address = dict["address"] as? String,
                let postcode = dict["postcode"] as? String ,
                let status = dict["status"] as? String,
                let logoImageurl = dict["logo image"] as? String,
                let entranceImageurl = dict["entrance image"] as? String,
                let interiorImageurl = dict["interior image"] as? String,
                let conceptImageurl = dict["concept image"] as? String,
                let about = dict ["about"] as? String,
                let myOffer = dict["my offer"] as? String{
               
                let myStatus = UserStatus(rawValue: myStatusStr)!
                let searchForStatus = UserStatus(rawValue: searchForStatusStr)!
                
                let user = User(uid: uid, fullname: fullname, email: email, profileImageurl: profileImageUrl, status: status, myStatus: myStatus, searchForStatus: searchForStatus, profileImageurl1: profileImageurl1, profileImageurl2: profileImageurl2, profileImageurl3: profileImageurl3, profileImageurl4: profileImageurl4)
                
                let buisUser = BuisnessUser(uid: uid, email: email, city: city, state: state, buisnessName: buisnessName, address: address, phone: phone, postcode: postcode, about: about, myOffer: myOffer, buisnessLogoImageUrl:logoImageurl, buisnessInteriorImageUrl: interiorImageurl, buisnessEntranceImageUrl: entranceImageurl, buisnessConceptImageUrl: conceptImageurl)
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let chatVC = storyboard.instantiateViewController(withIdentifier: IDENTIFIER_CHAT) as! ChatViewController
                
                chatVC.partnerUserName = user.fullname
                chatVC.partnerId = user.uid
                chatVC.partnerUser = user
                

                guard let currentVC = UIApplication.topViewController() else {
                    return
                }

                currentVC.navigationController?.pushViewController(chatVC, animated: true)
                
                
            }
        }
    }
    
    
    completionHandler(UIBackgroundFetchResult.newData)
}

func convertToDictionary(text: String) -> [String: Any]? {
    if let data = text.data(using: String.Encoding.utf8) {
        do {
            return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    return nil
}

func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    guard let token = AppDelegate.isToken else {
        return
    }
    print("token: \(token)")
}

func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
    print(error.localizedDescription)
}

func connectToFirebase() {
    Messaging.messaging().shouldEstablishDirectChannel = true
}



extension AppDelegate: UNUserNotificationCenterDelegate, MessagingDelegate {
    @available(iOS 10.0, *)
    // This function will be called when the app receive notification
    // This function will be called when the app receive notification
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        // show the notification alert (banner), and with sound
        completionHandler([.alert, .sound])
    }
    
    // This function will be called right after user tap on the notification
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let application = UIApplication.shared
        
        if(application.applicationState == .active){
            print("user tapped the notification bar when the app is in foreground")
            
        }
        
        if(application.applicationState == .inactive)
        {
            print("user tapped the notification bar when the app is in background")
        }
        // tell the app that we have finished processing the user’s action / response
        completionHandler()
    }// This function will be called when the app receive notification
    

    
//    // This function will be called right after user tap on the notification
//    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
//        let application = UIApplication.shared
//
//        if(application.applicationState == .active){
//            print("user tapped the notification bar when the app is in foreground")
//
//        }
//
//        if(application.applicationState == .inactive)
//        {
//            print("user tapped the notification bar when the app is in background")
//        }
//        // tell the app that we have finished processing the user’s action / response
//        completionHandler()
//    }

    
//    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
//        guard let token = AppDelegate.isToken else {
//            return
//        }
//        print("Token: \(token)")
//        connectToFirebase()
//    }
//
//    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
//        print("remoteMessage: \(remoteMessage.appData)")
//    }
}

