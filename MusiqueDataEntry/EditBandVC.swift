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

class EditBandVC: FormViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        form +++ Section("Enter Band Name:")
            <<< TextRow("name"){ row in
                row.title = "Name:"
                row.placeholder = ""
            }
            <<< ButtonRow(){
                $0.title = "Get Info"
                }.onCellSelection({
                    selected in
                    self.populateFromDatabase()
                })
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
            <<< ButtonRow(){
                $0.title = "Find Other Images"
                }.onCellSelection({
                    selected in
                    self.searchImages()
                })
            <<< TextRow("website"){
                $0.title = "Website:"
                $0.placeholder = ""
            }
            <<< TextRow("youtube"){
                $0.title = "Youtube:"
                $0.placeholder = ""
            }
            <<< ButtonRow(){
                $0.title = "Search Youtube"
                }.onCellSelection({
                    selected in
                    self.searchYoutube()
                })
            <<< ButtonRow(){
                $0.title = "Open Youtube"
                }.onCellSelection({
                    selected in
                    self.openYoutube()
                })
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
                $0.title = "Update"
                }.onCellSelection({
                    selected in
                    self.sendBand()
                })
        
        navigationOptions = RowNavigationOptions.Enabled.union(.StopDisabledRow)
        animateScroll = true
        rowKeyboardSpacing = 20
        
    }
    
    func populateFromDatabase() {
        let nameRow: TextRow? = form.rowBy(tag: "name")
        let fbrow: TextRow? = form.rowBy(tag: "facebook")
        let imageRow: TextRow? = form.rowBy(tag: "image")
        let genreRow: TextRow? = form.rowBy(tag: "genre")
        let webRow: TextRow? = form.rowBy(tag: "website")
        let ytRow: TextRow? = form.rowBy(tag: "youtube")
        let descriptionRow: TextAreaRow? = form.rowBy(tag: "description")
        
        
        NetworkController().getBand(band: nameRow?.value ?? "", completion: {
            band in
          
            if let fb = band.facebook {
                fbrow?.value = fb
                fbrow?.updateCell()
            }
            if let image = band.image {
                imageRow?.value = image
                imageRow?.updateCell()
            }
            if let genre = band.genre {
                genreRow?.value = genre
                genreRow?.updateCell()
            }
            if let web = band.website {
                webRow?.value = web
                webRow?.updateCell()
            }
            if let yt = band.youtube {
                ytRow?.value = yt
                ytRow?.updateCell()
            }
            if let des = band.bandDescription {
                descriptionRow?.value = des
                descriptionRow?.updateCell()
            }
        })

    }
    
    
    func sendBand() {
        let nameRow: TextRow? = form.rowBy(tag: "name")
        let emailRow: TextRow? = form.rowBy(tag: "email")
        let fbrow: TextRow? = form.rowBy(tag: "facebook")
        let imageRow: TextRow? = form.rowBy(tag: "image")
        let genreRow: TextRow? = form.rowBy(tag: "genre")
        let webRow: TextRow? = form.rowBy(tag: "website")
        let ytRow: TextRow? = form.rowBy(tag: "youtube")
        let region: TextRow? = form.rowBy(tag: "region")
        let descriptionRow: TextAreaRow? = form.rowBy(tag: "description")
        
        
        if let name = nameRow?.value {
            let updateBand = BandObject(name: name)
            
            if let email = emailRow?.value {
                updateBand.email = email
            }
            
            if let fb = fbrow?.value {
                updateBand.facebook = fb
            }
            
            if let image = imageRow?.value {
                updateBand.image = image
            }
            
            if let genre = genreRow?.value {
                updateBand.genre = genre
            }
            
            if let web = webRow?.value {
                updateBand.website = web
            }
            
            if let yt = ytRow?.value {
                updateBand.youtube = yt
            }
            
            if let rg = region?.value {
                updateBand.region = rg
            }
            
            if let descrip = descriptionRow?.value {
                updateBand.bandDescription = descrip
            }
            
            NetworkController().updateBandData(band: updateBand, completion: {
                success in
                emailRow?.value = ""
                emailRow?.updateCell()
                fbrow?.value = ""
                fbrow?.updateCell()
                ytRow?.value = ""
                ytRow?.updateCell()
                nameRow?.value = ""
                nameRow?.updateCell()
                imageRow?.value = ""
                imageRow?.updateCell()
                genreRow?.value = ""
                genreRow?.updateCell()
                webRow?.value = ""
                webRow?.updateCell()
                region?.value = ""
                region?.updateCell()
                descriptionRow?.value = ""
                descriptionRow?.updateCell()
                let row: TextRow? = self.form.rowBy(tag: "username")
                row?.value = ""
                row?.updateCell()

            })
        }
    
    }
    
    
    func searchYoutube() {
        let nameRow: TextRow? = form.rowBy(tag: "name")
        if let name = nameRow?.value {
            SeatGeekController().getYoutubeForBand(band: name, completion: {
                youtubelink in
                self.updateYoutube(url: youtubelink)
            })
        }
    }
    
    func updateYoutube(url: String) {
        let ytrow: TextRow? = form.rowBy(tag: "youtube")
        ytrow?.value = url
        ytrow?.updateCell()
    }
    
    func openYoutube() {
        let ytrow: TextRow? = form.rowBy(tag: "youtube")
        if let yt = ytrow?.value {
            let url = URL(string: yt)
            UIApplication.shared.openURL(url!)
        }
    }
    
    func searchImages() {
        let googleLink = "https://www.google.com/search?site=&tbm=isch&source=hp&biw=1187&bih=612&q="
        let nameRow: TextRow? = form.rowBy(tag: "name")
        if let name = nameRow?.value {
            let urlstring = googleLink + name.replacingOccurrences(of: " ", with: "+") + "+music+band"
            let url = URL(string: urlstring)
            UIApplication.shared.openURL(url!)
        }
    }

}
