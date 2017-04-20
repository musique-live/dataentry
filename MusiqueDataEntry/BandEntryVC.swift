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

let otheraccess = "EAASevzKy9ZA4BAL6bxNcuQiedXgoizw0clJZBTSkdwOOLV8qICQQGaFhvWxhpyQE1ZA6vsVrFqEWWYMzEGQTx9c8r40rUMwpEluXK7AzQXJxh5VGsciWpSGLmKE7LMntvSJATWXJlEsIQdE9t3ZA3fC0iERRb4YZD"

class BandEntryVC: FormViewController {
    
    var enteredValue: String?
    var newBandObject: BandObject?
    var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        form +++ Section("Enter BandObject Facebook Username:")
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
            <<< EmailRow("BandObjectemail"){
                $0.title = "Email"
                $0.placeholder = ""
            }
            <<< TextRow("facebook"){
                $0.title = "Facebook URL:"
                $0.placeholder = ""
            }
            <<< TextRow("image"){
                $0.title = "BandObject Image:"
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
        
     
        imageView = UIImageView(frame: CGRect(x: 20, y: view.frame.height - 200, width: 180, height: 180))
        imageView.backgroundColor = UIColor.gray
        view.addSubview(imageView)
        

    }
    
    
    func doFacebookCollect() {
        let row: TextRow? = form.rowBy(tag: "username")
        if let value = row?.value {
            self.enteredValue = value
            let request = FBSDKGraphRequest(graphPath: "/\(value)", parameters: nil, tokenString: "EAACEdEose0cBABEN8XVOmINBkBTKlheMHmOONewXoABPOQ9U4MCecB6McdSoD38uiUgUNe5YSm7RvcGPAhvRpBfEXBNx8VpZALtJWZCGbzaz3O7ZBoiTHkxcn7LnqevVycdIVTQILsCCdxzMZCe4ZCvhyetTIYniy6UJgNBubhZAZBG7sBflybialrSDcWuGX4ZD", version: "", httpMethod: "GET")
            let _ = request?.start(completionHandler: {
                requesthandler in
                if let _ = requesthandler.1 {
                    if let BandObject = self.createBandObject((requesthandler.1 as? NSDictionary)!) {
                        self.newBandObject = BandObject
                        self.displayCollected()
                    }
                }
            })
        }
    }
    
    func displayCollected() {
        guard let newBandObject = newBandObject else { return }
        
        let emailRow: EmailRow? = form.rowBy(tag: "BandObjectemail")
        emailRow?.value = newBandObject.email
        emailRow?.updateCell()
        
        let fbrow: TextRow? = form.rowBy(tag: "facebook")
        fbrow?.value = newBandObject.facebook
        fbrow?.updateCell()
        
        let imageRow: TextRow? = form.rowBy(tag: "image")
        imageRow?.value = newBandObject.image
        imageRow?.updateCell()
        
        if let image = newBandObject.image {
            let url = URL(string: image)
            imageView.sd_setImage(with: url)
        }
        
        let genreRow: TextAreaRow? = form.rowBy(tag: "genre")
        genreRow?.value = newBandObject.genre
        genreRow?.updateCell()
        
        let webRow: TextRow? = form.rowBy(tag: "website")
        webRow?.value = newBandObject.website
        webRow?.updateCell()
        
        let regionRow: TextRow? = form.rowBy(tag: "region")
        regionRow?.value = newBandObject.region
        regionRow?.updateCell()
        
        let descriptionRow: TextAreaRow? = form.rowBy(tag: "description")
        descriptionRow?.value = newBandObject.bandDescription
        descriptionRow?.updateCell()
    }
    
    func createBandObject(_ dict: NSDictionary) -> BandObject? {
        if let name = dict["name"] as? String {
            let bandObj = BandObject(name: name)
            
            if let email = dict["press_contact"] as? String {
                bandObj.email = email
            }
            
            if let enteredValue = enteredValue {
                bandObj.facebook = "http://www.facebook.com/\(enteredValue)"
            }
            
            if let cover = dict["cover"] as? NSDictionary {
                if let image = cover["source"] as? String {
                    bandObj.image = image
                }
            }
            
            if let genre = dict["genre"] as? String {
                bandObj.genre = genre
            }
            
            if let website = dict["website"] as? String {
                bandObj.website = website
            }
            
            if let region = dict["current_location"] as? String {
                bandObj.region = region
            }
            
            if let BandObjectDescription = dict["description"] as? String {
                bandObj.bandDescription = BandObjectDescription
            }
            
            return bandObj
        }
        return nil
    }
}
