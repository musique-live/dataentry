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
        
        return true

    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(app, open: url, options: options)
    }

}

