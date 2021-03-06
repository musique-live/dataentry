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
    var seatGeekObject: SeatGeekObject?
    var goButton = UIButton()
    
    var timeEntry = UITextField()
    var priceEntry = UITextField()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        event.band = BandObject()
        event.venue = VenueObject()
        
        view.backgroundColor = UIColor.white
        
        let halfwidth = view.frame.width/2
        
        refresh()
        
        let menuButton = UIButton(frame: CGRect(x: 20, y: 50, width: 100, height: 50))
        menuButton.setTitle("MENU", for: .normal)
        menuButton.setTitleColor(.black, for: .normal)
        menuButton.addTarget(self, action: "openMenu", for: .touchUpInside)
        view.addSubview(menuButton)
        
        bandField.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        bandField.autoCompleteTextColor = UIColor.black
        bandField.autoCompleteCellHeight = 50
        bandField.maximumAutoCompleteCount = 20
        bandField.hidesWhenSelected = true
        bandField.hidesWhenEmpty = true
        bandField.enableAttributedText = true
        bandField.placeholder = "Band"
        bandField.frame = CGRect(x: 120, y: 50, width: halfwidth, height: 50)
        view.addSubview(bandField)
        
        bandField.onSelect = {text, indexpath in
            self.event.band?.band = text
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
        venueField.frame = CGRect(x: 120, y: 250, width: halfwidth, height: 50)
        view.addSubview(venueField)
        
        venueField.onSelect = {text, indexpath in
            self.event.venue?.venue = text
            self.venueField.resignFirstResponder()
        }
        
        venueField.onTextChange = {text in
            self.venueField.autoCompleteStrings = self.venues?.filter() {($0.lowercased().contains(text.lowercased()))}
        }
        venueField.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: venueField.frame.size.height))
        venueField.leftView = paddingView
        venueField.leftViewMode = .always
        
        datepicker = UIDatePicker(frame: CGRect(x: 120, y: 450, width: halfwidth, height: 250))
        datepicker?.datePickerMode = .date
        datepicker?.addTarget(self, action: #selector(EventEntryVC.handleDatePicker), for: .valueChanged)
        view.addSubview(datepicker!)
        
        timeEntry = UITextField(frame: CGRect(x: 120, y: 750, width: halfwidth, height: 50))
        timeEntry.delegate = self
        timeEntry.placeholder = "Time"
        timeEntry.tag = 0
        timeEntry.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
        view.addSubview(timeEntry)
        
        priceEntry = UITextField(frame: CGRect(x: 120, y: 850, width: halfwidth, height: 50))
        priceEntry.delegate = self
        priceEntry.tag = 1
        priceEntry.placeholder = "Price"
        priceEntry.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
        view.addSubview(priceEntry)
        
        goButton = UIButton(frame: CGRect(x: view.frame.width - 100, y: 20, width: 80, height: 50))
        goButton.setTitle("Send", for: .normal)
        goButton.backgroundColor = UIColor.blue
        goButton.setTitleColor(.white, for: .normal)
        goButton.addTarget(self, action: "sendData", for: .touchUpInside)
        view.addSubview(goButton)
        
    }
    
    func sendData() {
        goButton.isEnabled = false
        goButton.backgroundColor = UIColor.gray
        NetworkController().sendEventDataWithoutBandVenueInfo(event: event, completion: {
            success, message in
            if success {
                self.bandField.text = ""
                self.venueField.text = ""
                self.timeEntry.text = ""
                self.priceEntry.text = ""
                self.goButton.isEnabled = true
                self.goButton.backgroundColor = UIColor.blue
            }
            else {
                let alert = UIAlertController(title: "ERROR", message: message, preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {
                    handle in
                }))
                self.present(alert, animated: true, completion: nil)
                self.goButton.isEnabled = true
                self.goButton.backgroundColor = UIColor.red
            }
        })
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.tag == 0 {
            event.time = textField.text
        } else {
            if let pricenum = Int(textField.text!) {
                event.price = pricenum
            } else {
                let alert = UIAlertController(title: "HEY", message: "Price needs to be a number", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: {
                    handle in
                }))
                self.present(alert, animated: true, completion: nil)
            }
        }
        return true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        refresh()
        if self.seatGeekObject != nil {
            populateWithSeatGeek()
        }
    }
    
    func openMenu() {
        self.slideMenuController()?.openLeft()
    }
    
    func populateWithSeatGeek() {
        guard let seatGeekObject = seatGeekObject else { return }
        if let band = seatGeekObject.name {
            self.bandField.text = cleanFBString(string: band)
            event.band?.band = band
        }
        if let venue = seatGeekObject.venuename {
            self.venueField.text = cleanFBString(string: venue)
            event.venue?.venue = venue
        }
        if let date = seatGeekObject.date {
            let calendar = Calendar.current
            
            let components = calendar.dateComponents([.hour, .minute, .year, .month, .day], from: date)
            
            if let newdate = calendar.date(from: components) {
                datepicker?.setDate(newdate, animated: true)
            }
            
            let hour = calendar.component(.hour, from: date)
            let minute = calendar.component(.minute, from: date)
            var newhour = hour
            var newminute = "00"
            if hour > 12 {
                newhour = hour - 12
            }
            if minute != 0 {
                newminute = "\(minute)"
            }
            self.timeEntry.text = "\(newhour):\(newminute)"
            
            event.timestamp = date as NSDate
            event.time = "\(newhour):\(newminute)"
            
        }
        if let price = seatGeekObject.lowestprice {
            self.priceEntry.text = "\(price)"
            event.price = Int(price)
        }
        if let id = seatGeekObject.id {
            event.seatGeekID = id
        }
        if let url = seatGeekObject.URL {
            event.ticketURL = url
        }
        
    }
    
    func cleanFBString(string: String) -> String {
        var newstring = string.replacingOccurrences(of: ".", with: "")
        newstring = newstring.replacingOccurrences(of: "#", with: "")
        newstring = newstring.replacingOccurrences(of: "$", with: "")
        newstring = newstring.replacingOccurrences(of: "[", with: "")
        newstring = newstring.replacingOccurrences(of: "]", with: "")
        return newstring
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.seatGeekObject = nil
    }
    
    func handleDatePicker() {
        if let date = self.datepicker?.date {
            event.timestamp = date as NSDate
        }
    }
    
    func refresh() {
        NetworkController().getVenuesList(completion: {
            venues in
            self.venueField.backgroundColor = UIColor.green
            self.venues = venues.allKeys as! [String]
        })
        
        NetworkController().getBandObjectsList(completion: {
            bands in
            self.bandField.backgroundColor = UIColor.green
            self.bands = bands
        })
    }
    
}
