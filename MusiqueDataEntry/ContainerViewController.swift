//
//  ContainerViewController.swift
//  musique
//
//  Created by Tara Wilson on 3/7/17.
//  Copyright © 2017 twil. All rights reserved.
//

import Foundation
import SlideMenuControllerSwift
import Firebase

class ContainerViewController: UIViewController {
    
    var tab: UITabBarController?
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        FIRAnalytics.logEvent(withName: kFIREventLogin, parameters: nil)
    }
    
    override func viewDidLoad() {
        view.backgroundColor = UIColor.blue
        
        let width = view.frame.width * 1/3
        
        let image = UIImageView(frame: CGRect(x: 10, y: 10, width: width - 20, height: 60))
        image.image = UIImage(named: "logowhite")
        image.contentMode = .scaleAspectFit
        view.addSubview(image)
        
        let buttonOne = UIButton(frame: CGRect(x: 10, y: 80, width: width - 20, height: 60))
        buttonOne.setTitle("To Do", for: .normal)
        buttonOne.addTarget(self, action: #selector(ContainerViewController.openToDo), for: .touchUpInside)
        buttonOne.setTitleColor(UIColor.white, for: .normal)
        view.addSubview(buttonOne)
        
        let buttonTwo = UIButton(frame: CGRect(x: 10, y: 160, width: width - 20, height: 60))
        buttonTwo.setTitle("Band Entry", for: .normal)
        buttonTwo.addTarget(self, action: #selector(ContainerViewController.openBand), for: .touchUpInside)
        buttonTwo.setTitleColor(UIColor.white, for: .normal)
        view.addSubview(buttonTwo)
        
        let buttonThree = UIButton(frame: CGRect(x: 10, y: 240, width: width - 20, height: 60))
        buttonThree.setTitle("Venue Entry", for: .normal)
        buttonThree.addTarget(self, action: #selector(ContainerViewController.openVenue), for: .touchUpInside)
        buttonThree.setTitleColor(UIColor.white, for: .normal)
        view.addSubview(buttonThree)
        
        let buttonFour = UIButton(frame: CGRect(x: 10, y: 320, width: width - 20, height: 60))
        buttonFour.setTitle("Event Entry", for: .normal)
        buttonFour.addTarget(self, action: #selector(ContainerViewController.openEvent), for: .touchUpInside)
        buttonFour.setTitleColor(UIColor.white, for: .normal)
        view.addSubview(buttonFour)
        
        let buttonFive = UIButton(frame: CGRect(x: 10, y: 400, width: width - 20, height: 60))
        buttonFive.setTitle("Band Edit", for: .normal)
        buttonFive.addTarget(self, action: #selector(ContainerViewController.openEdit), for: .touchUpInside)
        buttonFive.setTitleColor(UIColor.white, for: .normal)
        view.addSubview(buttonFive)
        
        let buttonSix = UIButton(frame: CGRect(x: 10, y: 480, width: width - 20, height: 60))
        buttonSix.setTitle("Scraping (Tara)", for: .normal)
        buttonSix.addTarget(self, action: #selector(ContainerViewController.openScrape), for: .touchUpInside)
        buttonSix.setTitleColor(UIColor.white, for: .normal)
        view.addSubview(buttonSix)
        
        let buttonSeven = UIButton(frame: CGRect(x: 10, y: 560, width: width - 20, height: 60))
        buttonSeven.setTitle("Delete Events", for: .normal)
        buttonSeven.addTarget(self, action: #selector(ContainerViewController.openDelete), for: .touchUpInside)
        buttonSeven.setTitleColor(UIColor.white, for: .normal)
        view.addSubview(buttonSeven)
        
        let buttonEight = UIButton(frame: CGRect(x: 10, y: 640, width: width - 20, height: 60))
        buttonEight.setTitle("Share to Facebook", for: .normal)
        buttonEight.addTarget(self, action: #selector(ContainerViewController.openShare), for: .touchUpInside)
        buttonEight.setTitleColor(UIColor.white, for: .normal)
        view.addSubview(buttonEight)
        
    }
    
    func openShare() {
        self.slideMenuController()?.closeLeft()
        tab?.selectedIndex = 7
    }
    
    func openToDo() {
        self.slideMenuController()?.closeLeft()
        tab?.selectedIndex = 0
    }
    
    func openBand() {
        self.slideMenuController()?.closeLeft()
        tab?.selectedIndex = 1
    }
    
    func openVenue() {
        self.slideMenuController()?.closeLeft()
        tab?.selectedIndex = 2
    }
    
    func openEvent() {
        self.slideMenuController()?.closeLeft()
        tab?.selectedIndex = 3
    }
    
    func openEdit() {
        self.slideMenuController()?.closeLeft()
        tab?.selectedIndex = 4
    }
    
    func openScrape() {
        self.slideMenuController()?.closeLeft()
        tab?.selectedIndex = 5
    }
    
    func openDelete() {
        self.slideMenuController()?.closeLeft()
        tab?.selectedIndex = 6
    }
    
}
