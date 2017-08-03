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
        
        form +++ Section(){ section in
                section.header = {
                    var header = HeaderFooterView<UIView>(.callback({
                        let view = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 100))
                        view.backgroundColor = .darkGray
                        let menuButton = UIButton(frame: CGRect(x: 30, y: 20, width: 100, height: 50))
                        menuButton.setTitle("MENU", for: .normal)
                        menuButton.setTitleColor(.white, for: .normal)
                        menuButton.addTarget(self, action: #selector(self.openMenu), for: .touchUpInside)
                        view.addSubview(menuButton)
                        return view
                    }))
                    header.height = { 100 }
                    return header
                }()
            }
            +++ Section("Enter BandObject Facebook Username:")
            <<< TextRow("username"){ row in
                row.title = "Username"
                row.placeholder = ""
            }
            <<< ButtonRow(){
                $0.title = "SEARCH FACEBOOK"
                }.onCellSelection({
                    selected in
                    self.doFacebookCollect()
                })
            <<< ButtonRow(){
                $0.title = "GOOGLE FACEBOOK"
                }.onCellSelection({
                    selected in
                    self.googleFacebook()
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
            <<< ButtonRow(){
                $0.title = "Find Other Images"
                }.onCellSelection({
                    selected in
                    self.searchImages()
                })
            <<< ButtonRow(){
                $0.title = "Clear Image"
                }.onCellSelection({
                    selected in
                    self.clearImage()
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
                $0.maxLength = 30
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
    
    func openMenu() {
        self.slideMenuController()?.openLeft()
    }
    
    
    func clearImage() {
        let imageRow: TextRow? = form.rowBy(tag: "image")
        imageRow?.value = ""
        imageRow?.updateCell()
    }
    
    override func textInput<T>(_ textInput: UITextInput, shouldChangeCharactersInRange range: NSRange, replacementString string: String, cell: Cell<T>) -> Bool {
        var text: String?
        var maxLength: Int?
        let textAreaRow = cell.baseRow as? TextAreaRow
        let textRow = cell.baseRow as? TextRow
        if textAreaRow != nil {
            text = textAreaRow?.value as String?
            maxLength = textAreaRow?.maxLength
        } else if textRow != nil {
            text = textRow?.value as String?
            maxLength = textRow?.maxLength
        }
        if text == nil || maxLength == nil {
            return true
        }
        return text!.characters.count + string.characters.count - range.length <= maxLength!
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
        newBandObject.band = nameRow?.value
        
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
    
    
    func tryAll(value: String) {
        let band = value.replacingOccurrences(of: " ", with: "")
        self.enteredValue = band
        self.tryFacebook(value: band, completion: {
            result in
            if result == false {
                self.enteredValue = band + "music"
                self.tryFacebook(value: band + "music", completion: {
                    bool in
                    if bool == false {
                        self.enteredValue = band + "band"
                        self.tryFacebook(value: band + "band", completion: {
                            bool in
                            if bool == false {
                                self.enteredValue = band + "official"
                                self.tryFacebook(value: band + "official", completion: {
                                    bool in
                                    if bool == false {
                                        self.enteredValue = "official" + band
                                        self.tryFacebook(value: "official" + band, completion: {
                                            bool in
                                            if bool == false {
                                            }
                                        })
                                    }
                                })
                            }
                        })
                    }
                })
            }
        })

    }
    
    func doFacebookCollect() {
        let row: TextRow? = form.rowBy(tag: "username")
        if let value = row?.value, !(value.isEmpty) {
            self.enteredValue = value
            tryFacebook(value: value, completion: {
                result in
            })
        } else {
            let bandrow: TextRow? = self.form.rowBy(tag: "name")
            if let band = bandrow?.value {
                self.tryAll(value: band)
            }
        }

    }
    
    func tryFacebook(value: String, completion: @escaping (Bool) -> Void) {
        if let accesstoken = UserDefaults.standard.string(forKey: "fbkey") {
            let request = FBSDKGraphRequest(graphPath: "/\(value)", parameters: ["fields": "name, press_contact, cover, genre, website, current_location, description"], tokenString: accesstoken, version: "", httpMethod: "GET")
            let _ = request?.start(completionHandler: {
                requesthandler in
                if let _ = requesthandler.1 {
                    if let BandObject = self.createBandObject((requesthandler.1 as? NSDictionary)!) {
                        self.newBandObject = BandObject
                        self.displayCollected()
                        completion(true)
                    }
                } else {
                    completion(false)
                }
            })
        } else {
            loginManager.logIn(withPublishPermissions: ["manage_pages", "publish_pages", "pages_show_list", "pages_manage_cta"], from: self, handler: {
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
                                completion(true)
                            }
                        } else {
                            completion(false)
                        }
                    })
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
        
        let nameRow: TextRow? = form.rowBy(tag: "name")
        nameRow?.value = newBandObject.band
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
    
    func searchYoutube() {
        let nameRow: TextRow? = form.rowBy(tag: "name")
        if let name = nameRow?.value {
            NetworkController().getYoutubeForBand(band: name, completion: {
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
    
    func googleFacebook() {
        let googleLink = "https://www.google.com/search?q="
        let nameRow: TextRow? = form.rowBy(tag: "name")
        if let name = nameRow?.value {
            let urlstring = googleLink + name.replacingOccurrences(of: " ", with: "+") + "facebook+music"
            let url = URL(string: urlstring)
            UIApplication.shared.openURL(url!)
        }
    }
    
    func createBandObject(_ dict: NSDictionary) -> BandObject? {
        if let name = dict["name"] as? String {
            let bandObj = BandObject()
            bandObj.band = name
            
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


var extensionPropertyStorage: [String: [String: Any]] = [:]

var maxLength_ = "maxLength"

extension Row {
    
    public var maxLength: Int? {
        get {
            return didSetMaxLength
        }
        set {
            didSetMaxLength = newValue
        }
    }
    
    private var didSetMaxLength: Int? {
        get {
            return extensionPropertyStorage[self.tag!]?[maxLength_] as? Int
        }
        set {
            var selfDictionary = extensionPropertyStorage[self.tag!] ?? [String: Any]()
            selfDictionary[maxLength_] = newValue
            extensionPropertyStorage[self.tag!] = selfDictionary
        }
    }
}
