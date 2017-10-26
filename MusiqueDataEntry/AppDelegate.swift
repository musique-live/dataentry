//
//  AppDelegate.swift
//  MusiqueDataEntry
//
//  Created by Tara Wilson on 4/19/17.
//  Copyright © 2017 twil. All rights reserved.
//

import UIKit
import Firebase
import FBSDKCoreKit
import FBSDKLoginKit
import SlideMenuControllerSwift
import Google
import GoogleSignIn

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        FIRApp.configure()
        
        let win = UIWindow()
        win.frame = UIScreen.main.bounds
        win.makeKeyAndVisible()
        window = win
        UIApplication.shared.statusBarStyle = .lightContent
        
        let tabBar = TabBarController()
        tabBar.tabBar.isHidden = true
        
        let container = ContainerViewController()
        container.tab = tabBar
        
        let slideMenuController = SlideMenuController(mainViewController: tabBar, leftMenuViewController: container)
        self.window?.rootViewController = slideMenuController
        self.window?.makeKeyAndVisible()
        
        var configureError: NSError?
        GGLContext.sharedInstance().configureWithError(&configureError)
        assert(configureError == nil, "Error configuring Google services: \(configureError)")
        
        return true

    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        print(url.absoluteString)
//        if url.absoluteString == "facebook" {
            return FBSDKApplicationDelegate.sharedInstance().application(app, open: url, options: options)
//        } else {
//            //com.googleusercontent.apps.403612539176-t1i4e0vjmrnvhgqa2vmi27ubkaiqut7m:/oauth2callback?code=4/yC2wmwqk65hqyXEAlh7f1gphJEhua3QIvqMz0U5QfF0#
//            if #available(iOS 9.0, *) {
//                let sourceApplication = options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String
//                let annotation = options[UIApplicationOpenURLOptionsKey.annotation]
//                return GIDSignIn.sharedInstance().handle(url,
//                                                         sourceApplication: sourceApplication,
//                                                         annotation: annotation)
//            } else {
//                return false
//            }
//            
//        }
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        print(sourceApplication)
        //tara fix this
//        if sourceApplication == "facebook" {
            return FBSDKApplicationDelegate.sharedInstance().application(application, open: url, options: nil)
//        } else {
//            return GIDSignIn.sharedInstance().handle(url,
//                                                     sourceApplication: sourceApplication,
//                                                     annotation: annotation)
//        }
    }

}

