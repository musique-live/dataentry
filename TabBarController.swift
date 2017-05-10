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
        
        let item3 = VenueEntryVC()
        let icon3 = UITabBarItem(title: "Venue Entry", image: nil, selectedImage: nil)
        item3.tabBarItem = icon3
        
        let item4 = ToDoList()
        let icon4 = UITabBarItem(title: "To Do List", image: nil, selectedImage: nil)
        item4.tabBarItem = icon4
        
        let controllers = [item1, item3, item2, item4]
        self.viewControllers = controllers
    }
}
