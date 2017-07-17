//
//  FacebookShareVC.swift
//  MusiqueDataEntry
//
//  Created by Tara Wilson on 7/17/17.
//  Copyright © 2017 twil. All rights reserved.
//

import Foundation
import UIKit
import FBSDKLoginKit

class FacebookShareVC: UIViewController {
    
    let loginManager = FBSDKLoginManager()
    var shareText: String?
    var shareImage: UIImage?
    let extratext = " Download our app to see more live events: https://itunes.apple.com/us/app/musique-live/id1217586564"
    let link = "https://itunes.apple.com/us/app/musique-live/id1217586564"
    let pageid = "835920719906047"
    var textField: UITextView?
    var imageView: UIImageView?
    var shareLink: UITextView?
    let kathiShareText = "Hey! I'm with the Musique Live App and we're featuring your event on our facebook today. It would be really great if you could share that feature to your followers by sharing this post: "
    var sendButton: UIButton!
    var copyButton: UIButton!
    
    override func viewDidLoad() {
        view.backgroundColor = UIColor.white
        
        doFacebook()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setUpUI()
    }
    
    func setUpUI() {
        
        let menuButton = UIButton(frame: CGRect(x: 20, y: 50, width: 100, height: 50))
        menuButton.setTitle("MENU", for: .normal)
        menuButton.setTitleColor(.black, for: .normal)
        menuButton.addTarget(self, action: "openMenu", for: .touchUpInside)
        view.addSubview(menuButton)
        
        textField = UITextView(frame: CGRect(x: 100, y: 200, width: view.frame.width - 200, height: 80))
        textField?.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
        view.addSubview(textField!)
        
        imageView = UIImageView(frame: CGRect(x: 100, y: 300, width: 150, height: 150))
        imageView?.backgroundColor = UIColor.gray
        view.addSubview(imageView!)
        
        sendButton = UIButton(frame: CGRect(x: 100, y: 620, width: 150, height: 50))
        sendButton.backgroundColor = UIColor.blue
        sendButton.setTitle("Send", for: .normal)
        sendButton.addTarget(self, action: #selector(self.sendToFB), for: .touchUpInside)
        view.addSubview(sendButton)
        
        copyButton = UIButton(frame: CGRect(x: 100, y: 690, width: 150, height: 50))
        copyButton.backgroundColor = UIColor.red
        copyButton.setTitle("COPY", for: .normal)
        copyButton.addTarget(self, action: #selector(self.copyText), for: .touchUpInside)
        view.addSubview(copyButton)
        
        shareLink = UITextView(frame: CGRect(x: 100, y: 500, width: view.frame.width - 200, height: 100))
        shareLink?.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
        shareLink?.text = "Share..."
        if let share = UserDefaults.standard.string(forKey: "currentShareLink") {
            shareLink?.text = kathiShareText + share
        }
        view.addSubview(shareLink!)
        
        let notes = UILabel(frame: CGRect(x: 100, y: 750, width: view.frame.width - 200, height: 200))
        notes.numberOfLines = 0
        notes.text = "Make sure the above is what you want to share. Press Share. \nThat post was just posted on the Musique Facebook page. Everyone can see it. \nIf you want someone else to share that post, press the copy button. \n Then, as Kathi, paste what is copied into messenger. This works best if you are messaging a band or venue page and not a user. \nREMEMBER: you are messaging the page as a normal user. Musique Live Page cannot send messages, it's not a person."
        view.addSubview(notes)
        
        getShareInfo()
    }
    
    func copyText() {
        if let shareLink = shareLink {
            if let text = shareLink.text {
                UIPasteboard.general.string = text
                copyButton.setTitle("Copied!", for: .normal)
                copyButton.backgroundColor = UIColor.green
                let when = DispatchTime.now() + 2
                DispatchQueue.main.asyncAfter(deadline: when) {
                    copyButton.setTitle("COPY", for: .normal)
                    copyButton.backgroundColor = UIColor.red
                }
            }
        }
        
    }
    
    func sendToFB() {
        sendButton.backgroundColor = UIColor.gray
        if let text = textField?.text, let image = imageView?.image, let pagekey = UserDefaults.standard.string(forKey: "pagekey") {
            
            let fbimage = UIImagePNGRepresentation(image)!
            

            let photorequest = FBSDKGraphRequest(graphPath: "/\(self.pageid)/photos", parameters: ["sourceImage":fbimage], tokenString: pagekey, version: "", httpMethod: "POST")
            photorequest?.start(completionHandler: {
                requestHandler in
                
                if let handler = requestHandler.1 {
                    if let dict = handler as? NSDictionary {
                        print(dict)
                        if let postid = dict["post_id"] as? String {
                            
                            let link = "https://www.facebook.com/" + postid
                            let postparams = ["message":text, "link":link]
                            let request = FBSDKGraphRequest(graphPath: "/\(self.pageid)/feed", parameters: postparams, tokenString: pagekey, version: "", httpMethod: "POST")
                            request?.start(completionHandler: {
                                handle in
                                print(handle.2)
                                if let handler = handle.1 {
                                    if let dict = handler as? NSDictionary {
                                        print(dict)
                                        if let postid = dict["id"] as? String {
                                            UserDefaults.standard.set("https://www.facebook.com/" + postid, forKey: "currentShareLink")
                                            UserDefaults.standard.synchronize()
                                            DispatchQueue.main.async {
                                                self.sendButton.backgroundColor = UIColor.blue
                                                if let shareLink = self.shareLink {
                                                    shareLink.text = self.kathiShareText + "https://www.facebook.com/" + postid
                                                    
                                                    self.clear()
                                                }
                                            }
                                        }
                                    }
                                }
                            })
                            
                            
                        }
                    }
                }
                
                
               
                
                
                
            })
            
        }
    }
    
    func clear() {
        textField?.text = ""
        imageView?.image = nil
        
        if let userDefaults = UserDefaults(suiteName: "group.musiquelive.datashare") {
            userDefaults.removeObject(forKey: "shareText")
            userDefaults.removeObject(forKey: "data")
        }
    }
    
    func doFacebook() {
        if let _ = UserDefaults.standard.string(forKey: "fbkey"), let _ = UserDefaults.standard.string(forKey: "pagekey") {
            
        } else {
            let doFacebook = UIButton(frame: CGRect(x: 10, y: 30, width: 200, height: 50))
            doFacebook.backgroundColor = UIColor.blue
            doFacebook.setTitle("LOGIN", for: .normal)
            doFacebook.addTarget(self, action: #selector(FacebookShareVC.login), for: .touchUpInside)
            view.addSubview(doFacebook)
        }
    }
    
    func login() {
        let permissions = ["manage_pages", "publish_pages"]
        loginManager.logIn(withPublishPermissions: permissions, from: self, handler: {
            loginResult in
            let result = loginResult.0
            if let token = result?.token.tokenString {
                UserDefaults.standard.set(token, forKey: "fbkey")
                
                let request = FBSDKGraphRequest(graphPath: "/\(self.pageid)", parameters: ["fields":"access_token"], tokenString: token, version: "", httpMethod: "GET")
                let _ = request?.start(completionHandler: {
                    requesthandler in
                    if let handler = requesthandler.1 {
                        if let dict = requesthandler.1 as? NSDictionary {
                            if let newtoken = dict["access_token"] as? String {
                                UserDefaults.standard.set(newtoken, forKey: "pagekey")
                            }
                        }
                    }
                })
            }
            
        })
    }
    
    func openMenu() {
        self.slideMenuController()?.openLeft()
    }
    
    func getShareInfo() {
        if let userDefaults = UserDefaults(suiteName: "group.musiquelive.datashare") {
            if let text = userDefaults.value(forKey: "shareText") as? String, let data = userDefaults.value(forKey: "data") as? Data {
                textField?.text = text + extratext
                let oldImage = UIImage(data: data)
                self.imageView?.image = oldImage
            }
            
        }
    }
    
    
}
