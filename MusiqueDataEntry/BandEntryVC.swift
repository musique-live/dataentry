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
import FBSDKLoginKit

class BandEntryVC: FormViewController {
    
    var enteredValue: String?
    var newBandObject: BandObject?
    var imageView: UIImageView!
    let loginManager = FBSDKLoginManager()
    
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
            <<< TextRow("name"){
                $0.title = "Name:"
                $0.placeholder = ""
            }
            <<< EmailRow("Email"){
                $0.title = "Email"
                $0.placeholder = ""
            }
            <<< TextRow("facebook"){
                $0.title = "Facebook URL:"
                $0.placeholder = ""
            }
            <<< TextRow("image"){
                $0.title = "Image:"
                $0.placeholder = ""
            }
            <<< TextRow("website"){
                $0.title = "Website:"
                $0.placeholder = ""
            }
            <<< TextRow("youtube"){
                $0.title = "Youtube:"
                $0.placeholder = ""
            }
            <<< TextRow("region"){
                $0.title = "Region:"
                $0.placeholder = ""
            }
            <<< TextRow("genre"){
                $0.title = "Genre:"
                $0.placeholder = "Genre"
            }
            +++ Section("")
            <<< TextAreaRow("description"){
                $0.title = "Description:"
                $0.placeholder = "Description"
            }
            <<< ButtonRow(){
                $0.title = "Looks Good!"
                }.onCellSelection({
                    selected in
                    self.sendBand()
                })
        
        navigationOptions = RowNavigationOptions.Enabled.union(.StopDisabledRow)
        animateScroll = true
        rowKeyboardSpacing = 20
        
     
        imageView = UIImageView(frame: CGRect(x: 20, y: view.frame.height - 250, width: 180, height: 180))
        imageView.backgroundColor = UIColor.gray
        view.addSubview(imageView)
        

    }
    
    func sendBand() {
        guard let newBandObject = newBandObject else { return }
        
        let emailRow: EmailRow? = form.rowBy(tag: "Email")
        newBandObject.email = emailRow?.value
        
        let fbrow: TextRow? = form.rowBy(tag: "facebook")
        newBandObject.facebook = fbrow?.value
        
        let ytrow: TextRow? = form.rowBy(tag: "youtube")
        newBandObject.youtube = ytrow?.value
        
        let nameRow: TextRow? = form.rowBy(tag: "name")
        newBandObject.name = nameRow?.value
        
        let imageRow: TextRow? = form.rowBy(tag: "image")
        newBandObject.image = imageRow?.value
        
        let genreRow: TextRow? = form.rowBy(tag: "genre")
        newBandObject.genre = genreRow?.value
        
        let webRow: TextRow? = form.rowBy(tag: "website")
        newBandObject.website = webRow?.value
        
        let regionRow: TextRow? = form.rowBy(tag: "region")
        newBandObject.region = regionRow?.value
        
        let descriptionRow: TextAreaRow? = form.rowBy(tag: "description")
        newBandObject.bandDescription = descriptionRow?.value
        
        NetworkController().sendBandData(band: newBandObject, completion: {
            done in
            
            emailRow?.value = ""
            emailRow?.updateCell()
            fbrow?.value = ""
            fbrow?.updateCell()
            ytrow?.value = ""
            ytrow?.updateCell()
            nameRow?.value = ""
            nameRow?.updateCell()
            imageRow?.value = ""
            imageRow?.updateCell()
            genreRow?.value = ""
            genreRow?.updateCell()
            webRow?.value = ""
            webRow?.updateCell()
            regionRow?.value = ""
            regionRow?.updateCell()
            descriptionRow?.value = ""
            descriptionRow?.updateCell()
            let row: TextRow? = self.form.rowBy(tag: "username")
            row?.value = ""
            row?.updateCell()
        })
    }
    
    
    func doFacebookCollect() {
        let row: TextRow? = form.rowBy(tag: "username")
        if let value = row?.value {
            self.enteredValue = value
        
        
        if let accesstoken = UserDefaults.standard.string(forKey: "fbkey") {
            let request = FBSDKGraphRequest(graphPath: "/\(value)", parameters: ["fields": "name, press_contact, cover, genre, website, current_location, description"], tokenString: accesstoken, version: "", httpMethod: "GET")
            let _ = request?.start(completionHandler: {
                requesthandler in
                print(requesthandler.0)
                print(requesthandler.2)
                if let _ = requesthandler.1 {
                    if let BandObject = self.createBandObject((requesthandler.1 as? NSDictionary)!) {
                        self.newBandObject = BandObject
                        self.displayCollected()
                    }
                }
            })
        } else {
            loginManager.logIn(withReadPermissions: [], from: self, handler: {
                loginResult in
                let result = loginResult.0
                if let token = result?.token.tokenString {
                    UserDefaults.standard.set(token, forKey: "fbkey")
                

                
                
                        let request = FBSDKGraphRequest(graphPath: "/\(value)", parameters: nil, tokenString: token, version: "", httpMethod: "GET")
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
                
            })
        }
        
            
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
        
        let nameRow: TextRow? = form.rowBy(tag: "name")
        nameRow?.value = newBandObject.name
        nameRow?.updateCell()
        
        let imageRow: TextRow? = form.rowBy(tag: "image")
        imageRow?.value = newBandObject.image
        imageRow?.updateCell()
        
        if let image = newBandObject.image {
            let url = URL(string: image)
            imageView.sd_setImage(with: url)
        }
        
        let genreRow: TextRow? = form.rowBy(tag: "genre")
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
    
    func clear() {
        
    }
}
