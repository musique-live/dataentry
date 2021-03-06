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
        
        let buttonSeven = UIButton(frame: CGRect(x: 10, y: 480, width: width - 20, height: 60))
        buttonSeven.setTitle("View Events", for: .normal)
        buttonSeven.addTarget(self, action: #selector(ContainerViewController.openDelete), for: .touchUpInside)
        buttonSeven.setTitleColor(UIColor.white, for: .normal)
        view.addSubview(buttonSeven)
        
        let buttonEight = UIButton(frame: CGRect(x: 10, y: 560, width: width - 20, height: 60))
        buttonEight.setTitle("Ticketfly Scrape (Tara)", for: .normal)
        buttonEight.addTarget(self, action: #selector(ContainerViewController.openTicketFly), for: .touchUpInside)
        buttonEight.setTitleColor(UIColor.white, for: .normal)
        view.addSubview(buttonEight)
        
        let buttonNine = UIButton(frame: CGRect(x: 10, y: 640, width: width - 20, height: 60))
        buttonNine.setTitle("SeatGeek Scrape (Tara)", for: .normal)
        buttonNine.addTarget(self, action: #selector(ContainerViewController.openSG), for: .touchUpInside)
        buttonNine.setTitleColor(UIColor.white, for: .normal)
        view.addSubview(buttonNine)
        
        let ten = UIButton(frame: CGRect(x: 10, y: 720, width: width - 20, height: 60))
        ten.setTitle("All Bands and Venues", for: .normal)
        ten.addTarget(self, action: #selector(ContainerViewController.openTara), for: .touchUpInside)
        ten.setTitleColor(UIColor.white, for: .normal)
        view.addSubview(ten)
        
        let eleven = UIButton(frame: CGRect(x: 10, y: 800, width: width - 20, height: 60))
        eleven.setTitle("Facebook Scrape", for: .normal)
        eleven.addTarget(self, action: #selector(ContainerViewController.openFBScrape), for: .touchUpInside)
        eleven.setTitleColor(UIColor.white, for: .normal)
//        view.addSubview(eleven)
        
    }
    
    func openTara() {
        self.slideMenuController()?.closeLeft()
        tab?.selectedIndex = 8
    }
    
    func openFBScrape() {
        self.slideMenuController()?.closeLeft()
        tab?.selectedIndex = 9
    }
    
    func openSG() {
        self.slideMenuController()?.closeLeft()
        tab?.selectedIndex = 7
    }
    
    func openTicketFly() {
        self.slideMenuController()?.closeLeft()
        tab?.selectedIndex = 6
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
    
    func openDelete() {
        self.slideMenuController()?.closeLeft()
        tab?.selectedIndex = 5
    }
    
}
