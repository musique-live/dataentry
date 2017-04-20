//
//  TabBarController.swift
//  MusiqueDataEntry
//
//  Created by Tara Wilson on 4/20/17.
//  Copyright © 2017 twil. All rights reserved.
//

import Foundation
import UIKit

class TabBarController: UITabBarController, UITabBarControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let item1 = BandEntryVC()
        let icon1 = UITabBarItem(title: "Band Entry", image: nil, selectedImage: nil)
        item1.tabBarItem = icon1
        
        let item2 = EventEntryVC()
        let icon2 = UITabBarItem(title: "Event Entry", image: nil, selectedImage: nil)
        item2.tabBarItem = icon2
        
        let controllers = [item1, item2]
        self.viewControllers = controllers
    }
}
