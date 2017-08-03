//
//  TicketflyVC.swift
//  MusiqueDataEntry
//
//  Created by Tara Wilson on 8/3/17.
//  Copyright © 2017 twil. All rights reserved.
//

import Foundation
import UIKit

class TicketflyVC: UIViewController, UITextFieldDelegate {

    var bands: [String]?
    var venues: [String]?
    let venueField = AutoCompleteTextField()
    var venueString: String?
    var idEntry = UITextField()
    var goButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        
        let halfwidth = view.frame.width/2
        
        refresh()
        
        let menuButton = UIButton(frame: CGRect(x: 20, y: 50, width: 100, height: 50))
        menuButton.setTitle("MENU", for: .normal)
        menuButton.setTitleColor(.black, for: .normal)
        menuButton.addTarget(self, action: #selector(TicketflyVC.openMenu), for: .touchUpInside)
        view.addSubview(menuButton)
        
        
        venueField.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        venueField.autoCompleteTextColor = UIColor.black
        venueField.autoCompleteCellHeight = 50
        venueField.maximumAutoCompleteCount = 20
        venueField.hidesWhenSelected = true
        venueField.hidesWhenEmpty = true
        venueField.enableAttributedText = true
        venueField.placeholder = "Venue"
        venueField.frame = CGRect(x: 20, y: 120, width: halfwidth - 40, height: 50)
        view.addSubview(venueField)
        
        venueField.onSelect = {text, indexpath in
            self.venueString = text
            self.venueField.resignFirstResponder()
        }
        
        venueField.onTextChange = {text in
            self.venueField.autoCompleteStrings = self.venues?.filter() {($0.lowercased().contains(text.lowercased()))}
        }
        venueField.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
        
        
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: venueField.frame.size.height))
        venueField.leftView = paddingView
        venueField.leftViewMode = .always
        

        idEntry = UITextField(frame: CGRect(x: halfwidth + 20, y: 120, width: halfwidth - 40, height: 50))
        idEntry.delegate = self
        idEntry.placeholder = "Ticketfly ID"
        idEntry.tag = 0
        idEntry.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
        view.addSubview(idEntry)
        let paddingView2 = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: venueField.frame.size.height))
        idEntry.leftView = paddingView2
        idEntry.leftViewMode = .always
        
        goButton = UIButton(frame: CGRect(x: 20, y: 190, width: 80, height: 50))
        goButton.setTitle("Fetch", for: .normal)
        goButton.backgroundColor = UIColor.blue
        goButton.setTitleColor(.white, for: .normal)
        goButton.addTarget(self, action: "fetchData", for: .touchUpInside)
        view.addSubview(goButton)
    }
    
    func fetchData() {
        if let id = idEntry.text {
            //set ID with venue if needed
            TicketFlyController().getEventsForID(id: id)
        }
    }
    
    func openMenu() {
        self.slideMenuController()?.openLeft()
    }
 

    func refresh() {
        NetworkController().getVenuesList(completion: {
            venues in
            self.venues = venues.allKeys as! [String]
        })
        
        NetworkController().getBandObjectsList(completion: {
            bands in
            self.bands = bands
        })
    }
 
 
}
