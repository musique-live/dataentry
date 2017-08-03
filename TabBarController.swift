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
        
        let item2 = EventEntryVC()
        
        let item3 = VenueEntryVC()
        
        let item4 = ToDoList()
        
        let item5 = EditBandVC()
        
        let item6 = ResultsVC()
        
        let item7 = UINavigationController(rootViewController: TicketflyVC())
        
        let controllers = [item4, item1, item3, item2, item5, item6, item7]
        self.viewControllers = controllers
    }
}
