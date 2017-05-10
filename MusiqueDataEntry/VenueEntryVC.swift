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

class VenueEntryVC: FormViewController {
    
    var enteredValue: String?
    var newVenueObject: VenueObject?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        form +++ Section("Venue")
            <<< TextRow("venuename"){
                $0.title = "Name:"
                $0.placeholder = ""
            }
            <<< TextRow("venuefacebook"){
                $0.title = "Facebook URL:"
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
        
        navigationOptions = RowNavigationOptions.Enabled.union(.StopDisabledRow)
        animateScroll = true
        rowKeyboardSpacing = 20
        
        
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
        })
    }

}
