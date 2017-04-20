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
import GoogleAPIClientForREST
import GTMAppAuth

let otheraccess = "EAASevzKy9ZA4BAL6bxNcuQiedXgoizw0clJZBTSkdwOOLV8qICQQGaFhvWxhpyQE1ZA6vsVrFqEWWYMzEGQTx9c8r40rUMwpEluXK7AzQXJxh5VGsciWpSGLmKE7LMntvSJATWXJlEsIQdE9t3ZA3fC0iERRb4YZD"

let googleID = "403612539176-tjtd4pdd5m15dvgdngu9nnbluscme52l.apps.googleusercontent.com"

class ViewController: FormViewController {
    
    
    private let service = GTLRSheetsService()
    private let kKeychainItemName = "Google Sheets API"
    private let kClientID = googleID
    private let scopes = [kGTLRAuthScopeSheetsSpreadsheets]
    
    
    var enteredValue: String?
    var newBand: Band?
    var imageView: UIImageView!
     let output = UITextView()
    
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
        
     
        imageView = UIImageView(frame: CGRect(x: 20, y: view.frame.height - 200, width: 180, height: 180))
        imageView.backgroundColor = UIColor.gray
        view.addSubview(imageView)
        
        output.frame = CGRect(x: 20, y: view.frame.height - 250, width: view.frame.width - 40, height: 40)
        output.isEditable = false
        view.addSubview(output)

    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let authorizer = service.authorizer,
            let canAuth = authorizer.canAuthorize, canAuth {
            listMajors()
        } else {

        }
    }
    
    func doFacebookCollect() {
        let row: TextRow? = form.rowBy(tag: "username")
        if let value = row?.value {
            self.enteredValue = value
            let request = FBSDKGraphRequest(graphPath: "/\(value)", parameters: nil, tokenString: "EAACEdEose0cBABEN8XVOmINBkBTKlheMHmOONewXoABPOQ9U4MCecB6McdSoD38uiUgUNe5YSm7RvcGPAhvRpBfEXBNx8VpZALtJWZCGbzaz3O7ZBoiTHkxcn7LnqevVycdIVTQILsCCdxzMZCe4ZCvhyetTIYniy6UJgNBubhZAZBG7sBflybialrSDcWuGX4ZD", version: "", httpMethod: "GET")
            let _ = request?.start(completionHandler: {
                requesthandler in
                if let _ = requesthandler.1 {
                    if let band = self.createBand((requesthandler.1 as? NSDictionary)!) {
                        self.newBand = band
                        self.displayCollected()
                    }
                }
            })
        }
    }
    
    func displayCollected() {
        guard let newBand = newBand else { return }
        
        let emailRow: EmailRow? = form.rowBy(tag: "bandemail")
        emailRow?.value = newBand.email
        emailRow?.updateCell()
        
        let fbrow: TextRow? = form.rowBy(tag: "facebook")
        fbrow?.value = newBand.facebook
        fbrow?.updateCell()
        
        let imageRow: TextRow? = form.rowBy(tag: "image")
        imageRow?.value = newBand.image
        imageRow?.updateCell()
        
        if let image = newBand.image {
            let url = URL(string: image)
            imageView.sd_setImage(with: url)
        }
        
        let genreRow: TextAreaRow? = form.rowBy(tag: "genre")
        genreRow?.value = newBand.genre
        genreRow?.updateCell()
        
        let webRow: TextRow? = form.rowBy(tag: "website")
        webRow?.value = newBand.website
        webRow?.updateCell()
        
        let regionRow: TextRow? = form.rowBy(tag: "region")
        regionRow?.value = newBand.region
        regionRow?.updateCell()
        
        let descriptionRow: TextAreaRow? = form.rowBy(tag: "description")
        descriptionRow?.value = newBand.bandDescription
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
