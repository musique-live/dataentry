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

let otheraccess = "EAASevzKy9ZA4BAL6bxNcuQiedXgoizw0clJZBTSkdwOOLV8qICQQGaFhvWxhpyQE1ZA6vsVrFqEWWYMzEGQTx9c8r40rUMwpEluXK7AzQXJxh5VGsciWpSGLmKE7LMntvSJATWXJlEsIQdE9t3ZA3fC0iERRb4YZD"

class ViewController: FormViewController {
    
    var enteredValue: String?
    var newBand: Band?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        form +++ Section("Enter Band Facebook Username:")
            <<< TextRow("username"){ row in
                row.title = "Username"
                row.placeholder = ""
            }
            <<< ButtonRow(){
                $0.title = "GO"
                }.onCellSelection({
                    selected in
                    self.doFacebookCollect()
                })
            +++ Section("Collected Data")
            <<< EmailRow("bandemail"){
                $0.title = "Email"
                $0.placeholder = ""
            }
            <<< TextRow("facebook"){
                $0.title = "Facebook URL:"
                $0.placeholder = ""
            }
            <<< TextRow("image"){
                $0.title = "Band Image:"
                $0.placeholder = ""
            }
            <<< TextRow("website"){
                $0.title = "Website:"
                $0.placeholder = ""
            }
            <<< TextRow("region"){
                $0.title = "Region:"
                $0.placeholder = ""
            }
            +++ Section("")
            <<< TextAreaRow("genre"){
                $0.title = "Genre:"
                $0.placeholder = "Genre"
            }
            <<< TextAreaRow("description"){
                $0.title = "Description:"
                $0.placeholder = "Description"
            }
            <<< ButtonRow(){
                $0.title = "Looks Good!"
                }.onCellSelection({
                    selected in
                    
                })
        
        navigationOptions = RowNavigationOptions.Enabled.union(.StopDisabledRow)
        animateScroll = true
        rowKeyboardSpacing = 20
        
        
    }
    
    func doFacebookCollect() {
        let row: TextRow? = form.rowBy(tag: "username")
        if let value = row?.value {
            self.enteredValue = value
            let request = FBSDKGraphRequest(graphPath: "/\(value)", parameters: nil, tokenString: "EAACEdEose0cBABEN8XVOmINBkBTKlheMHmOONewXoABPOQ9U4MCecB6McdSoD38uiUgUNe5YSm7RvcGPAhvRpBfEXBNx8VpZALtJWZCGbzaz3O7ZBoiTHkxcn7LnqevVycdIVTQILsCCdxzMZCe4ZCvhyetTIYniy6UJgNBubhZAZBG7sBflybialrSDcWuGX4ZD", version: "", httpMethod: "GET")
            let _ = request?.start(completionHandler: {
                requesthandler in
                if let band = self.createBand((requesthandler.1 as? NSDictionary)!) {
                    self.newBand = band
                    self.displayCollected()
                }
            })
        }
    }
    
    func displayCollected() {
        guard let newBand = newBand else { return }
        
        let emailRow: EmailRow? = form.rowBy(tag: "bandemail")
        emailRow?.placeholder = newBand.email
        emailRow?.updateCell()
        
        let fbrow: TextRow? = form.rowBy(tag: "facebook")
        fbrow?.placeholder = newBand.facebook
        fbrow?.updateCell()
        
        let imageRow: TextRow? = form.rowBy(tag: "image")
        imageRow?.placeholder = newBand.image
        imageRow?.updateCell()
        
        let genreRow: TextAreaRow? = form.rowBy(tag: "genre")
        genreRow?.placeholder = newBand.genre
        genreRow?.updateCell()
        
        let webRow: TextRow? = form.rowBy(tag: "website")
        webRow?.placeholder = newBand.website
        webRow?.updateCell()
        
        let regionRow: TextRow? = form.rowBy(tag: "region")
        regionRow?.placeholder = newBand.region
        regionRow?.updateCell()
        
        let descriptionRow: TextAreaRow? = form.rowBy(tag: "description")
        descriptionRow?.placeholder = newBand.bandDescription
        descriptionRow?.updateCell()
    }
    
    func createBand(_ dict: NSDictionary) -> Band? {
        if let name = dict["name"] as? String {
            let band = Band(name: name)
            
            if let email = dict["press_contact"] as? String {
                band.email = email
            }
            
            if let enteredValue = enteredValue {
                band.facebook = "http://www.facebook.com/\(enteredValue)"
            }
            
            if let cover = dict["cover"] as? NSDictionary {
                if let image = cover["source"] as? String {
                    band.image = image
                }
            }
            
            if let genre = dict["genre"] as? String {
                band.genre = genre
            }
            
            if let website = dict["website"] as? String {
                band.website = website
            }
            
            if let region = dict["current_location"] as? String {
                band.region = region
            }
            
            if let bandDescription = dict["description"] as? String {
                band.bandDescription = bandDescription
            }
            
            return band
        }
        return nil
    }
}

class Band: NSObject {
    var name: String?
    var email: String?
    var facebook: String?
    var image: String?
    var genre: String?
    var website: String?
    var youtube: String?
    var region: String?
    var bandDescription: String?
    
    init(name: String) {
        self.name = name
    }
}
