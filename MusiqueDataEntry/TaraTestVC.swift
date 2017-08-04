//
//  TaraTestVC.swift
//  MusiqueDataEntry
//
//  Created by Tara Wilson on 8/4/17.
//  Copyright © 2017 twil. All rights reserved.
//

import Foundation
import UIKit

class TaraTestVC: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        
        let menuButton = UIButton(frame: CGRect(x: 20, y: 50, width: 100, height: 50))
        menuButton.setTitle("MENU", for: .normal)
        menuButton.setTitleColor(.black, for: .normal)
        menuButton.addTarget(self, action: #selector(openMenu), for: .touchUpInside)
        view.addSubview(menuButton)
        
        //NetworkController().getAllEmails()
    }
    
    func openMenu() {
        self.slideMenuController()?.openLeft()
    }
}
