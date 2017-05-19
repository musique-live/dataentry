//
//  EventEntryVC.swift
//  MusiqueDataEntry
//
//  Created by Tara Wilson on 4/20/17.
//  Copyright © 2017 twil. All rights reserved.
//

import Foundation
import UIKit

class EventEntryVC: UIViewController, UITextFieldDelegate {
    
    var bands: [String]?
    var venues: [String]?
    let bandField = AutoCompleteTextField()
    let venueField = AutoCompleteTextField()
    var datepicker: UIDatePicker?
    var actInd: UIActivityIndicatorView?
    let event = EventObject()
    
    var timeEntry = UITextField()
    var priceEntry = UITextField()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        
        let halfwidth = view.frame.width/2
        
        refresh()
        
        bandField.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        bandField.autoCompleteTextColor = UIColor.black
        bandField.autoCompleteCellHeight = 50
        bandField.maximumAutoCompleteCount = 20
        bandField.hidesWhenSelected = true
        bandField.hidesWhenEmpty = true
        bandField.enableAttributedText = true
        bandField.placeholder = "Band"
        bandField.frame = CGRect(x: 20, y: 50, width: halfwidth, height: 50)
        view.addSubview(bandField)
        
        bandField.onSelect = {text, indexpath in
            self.event.bandString = text
            self.bandField.resignFirstResponder()
        }
        
        bandField.onTextChange = {text in
            self.bandField.autoCompleteStrings = self.bands?.filter() {($0.lowercased().contains(text.lowercased()))}
        }
        
        bandField.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
        
        let bandFieldpaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: bandField.frame.size.height))
        bandField.leftView = bandFieldpaddingView
        bandField.leftViewMode = .always
        
        venueField.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        venueField.autoCompleteTextColor = UIColor.black
        venueField.autoCompleteCellHeight = 50
        venueField.maximumAutoCompleteCount = 20
        venueField.hidesWhenSelected = true
        venueField.hidesWhenEmpty = true
        venueField.enableAttributedText = true
        venueField.placeholder = "Venue"
        venueField.frame = CGRect(x: 20, y: 250, width: halfwidth, height: 50)
        view.addSubview(venueField)
        
        venueField.onSelect = {text, indexpath in
            self.event.venueString = text
            self.venueField.resignFirstResponder()
        }
        
        venueField.onTextChange = {text in
            self.venueField.autoCompleteStrings = self.venues?.filter() {($0.lowercased().contains(text.lowercased()))}
        }
        venueField.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: venueField.frame.size.height))
        venueField.leftView = paddingView
        venueField.leftViewMode = .always
        
        datepicker = UIDatePicker(frame: CGRect(x: 20, y: 450, width: halfwidth, height: 250))
        datepicker?.datePickerMode = .date
        datepicker?.addTarget(self, action: #selector(EventEntryVC.handleDatePicker), for: .valueChanged)
        view.addSubview(datepicker!)
        
        timeEntry = UITextField(frame: CGRect(x: 20, y: 750, width: halfwidth, height: 50))
        timeEntry.delegate = self
        timeEntry.placeholder = "Time"
        timeEntry.tag = 0
        timeEntry.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
        view.addSubview(timeEntry)
        
        let priceEntry = UITextField(frame: CGRect(x: 20, y: 850, width: halfwidth, height: 50))
        priceEntry.delegate = self
        priceEntry.tag = 1
        priceEntry.placeholder = "Price"
        priceEntry.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
        view.addSubview(priceEntry)
        
        let goButton = UIButton(frame: CGRect(x: view.frame.width - 100, y: 100, width: 80, height: 50))
        goButton.setTitle("Send", for: .normal)
        goButton.setTitleColor(.blue, for: .normal)
        goButton.addTarget(self, action: "sendData", for: .touchUpInside)
        view.addSubview(goButton)
    }
    
    func sendData() {
        NetworkController().sendEventData(event: event, completion: {
            success in
            self.bandField.text = ""
            self.venueField.text = ""
            self.timeEntry.text = ""
            self.priceEntry.text = ""
        })
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.tag == 0 {
            event.timeString = textField.text
        } else {
            if let pricenum = Int(textField.text!) {
                event.price = pricenum
            }
        }
        return true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        refresh()
    }
    
    func handleDatePicker() {
        if let date = self.datepicker?.date {
            event.timestamp = date as NSDate
        }
    }
    
    func refresh() {
        NetworkController().getVenuesList(completion: {
            venues in
            self.venues = venues
        })
        
        NetworkController().getBandObjectsList(completion: {
            bands in
            self.bands = bands
        })
    }
    
}
