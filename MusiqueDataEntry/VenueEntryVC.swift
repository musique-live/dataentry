//
//  ViewController.swift
//  MusiqueDataEntry
//
//  Created by Tara Wilson on 4/19/17.
//  Copyright © 2017 twil. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import Eureka
import SDWebImage
import CoreLocation

class VenueEntryVC: FormViewController {
    
    var enteredValue: String?
    var newVenueObject: VenueObject?
    var seatGeekObject: SeatGeekObject?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        form +++ Section("Venue")
            <<< TextRow("venuename"){
                $0.title = "Name:"
                $0.placeholder = ""
            }
            <<< TextRow("venuewebsite"){
                $0.title = "Website:"
                $0.placeholder = ""
            }
            <<< EmailRow("venueemail"){
                $0.title = "Email:"
                $0.placeholder = ""
            }
            <<< TextRow("venueyelp"){
                $0.title = "yelp:"
                $0.placeholder = ""
            }
            <<< TextRow("venueregion"){
                $0.title = "Region:"
                $0.placeholder = ""
            }
            <<< TextRow("venueAddress"){
                $0.title = "Address:"
                $0.placeholder = ""
            }
            <<< ButtonRow(){
                $0.title = "Looks Good!"
                }.onCellSelection({
                    selected in
                    self.sendVenue()
                })
            <<< ButtonRow(){
                $0.title = "Skip."
                }.onCellSelection({
                    selected in
                    if let seat = self.seatGeekObject {
                        self.skip()
                    }
                })
        
        
        navigationOptions = RowNavigationOptions.Enabled.union(.StopDisabledRow)
        animateScroll = true
        rowKeyboardSpacing = 20
        
        
    }
    
    func skip() {
        if let seatGeekObject = self.seatGeekObject {
            if let nextvc = self.tabBarController?.viewControllers?[3] as? EventEntryVC {
                nextvc.seatGeekObject = seatGeekObject
                self.tabBarController?.selectedIndex = 3
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if self.seatGeekObject != nil {
            populateWithSeatGeek()
        }
    }
    
    func populateWithSeatGeek() {
        guard let seatGeekObject = seatGeekObject else { return }
        
        let nameRow: TextRow? = form.rowBy(tag: "venuename")
        nameRow?.value = seatGeekObject.venuename
        nameRow?.updateCell()
        
        let addressRow: TextRow? = form.rowBy(tag: "venueAddress")
        addressRow?.value = seatGeekObject.address
        addressRow?.updateCell()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.seatGeekObject = nil
    }

    
    func sendVenue() {
        guard let nameRow: TextRow? = form.rowBy(tag: "venuename") else { return }
        newVenueObject = VenueObject(name: nameRow?.value ?? "error")
        
        let emailRow: EmailRow? = form.rowBy(tag: "venueemail")
        newVenueObject?.email = emailRow?.value
        
        let fbrow: TextRow? = form.rowBy(tag: "venuefacebook")
        newVenueObject?.facebook = fbrow?.value
        
        let ytrow: TextRow? = form.rowBy(tag: "venueyelp")
        newVenueObject?.yelp = ytrow?.value
        
        let webRow: TextRow? = form.rowBy(tag: "venuewebsite")
        newVenueObject?.website = webRow?.value
        
        let regionRow: TextRow? = form.rowBy(tag: "venueregion")
        newVenueObject?.region = regionRow?.value
        
        let addrRow: TextRow? = form.rowBy(tag: "venueAddress")
        newVenueObject?.address = addrRow?.value
        
        if let seatGeekObject = seatGeekObject {
            if let lat = seatGeekObject.latitude, let lon = seatGeekObject.longitude {
                let location = CLLocation(latitude: CLLocationDegrees(lat), longitude: CLLocationDegrees(lon))
                newVenueObject?.coordinates = location
            }
        }
        
        NetworkController().sendVenueData(venue: newVenueObject!, completion: {
            done in
            
            emailRow?.value = ""
            emailRow?.updateCell()
            fbrow?.value = ""
            fbrow?.updateCell()
            ytrow?.value = ""
            ytrow?.updateCell()
            nameRow?.value = ""
            nameRow?.updateCell()
            webRow?.value = ""
            webRow?.updateCell()
            addrRow?.value = ""
            addrRow?.updateCell()
            regionRow?.value = ""
            regionRow?.updateCell()
            
            if let seatGeekObject = self.seatGeekObject {
                if let nextvc = self.tabBarController?.viewControllers?[3] as? EventEntryVC {
                    nextvc.seatGeekObject = seatGeekObject
                    self.tabBarController?.selectedIndex = 3
                }
            }
        })
    }

}
