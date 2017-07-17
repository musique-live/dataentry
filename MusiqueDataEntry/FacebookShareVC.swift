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
    let pageid = "835920719906047"
    var textField: UITextField?
    var imageView: UIImageView?
    
    override func viewDidLoad() {
        view.backgroundColor = UIColor.white
        setUpUI()
        doFacebook()
    }
    
    func setUpUI() {
        
        let menuButton = UIButton(frame: CGRect(x: 20, y: 50, width: 100, height: 50))
        menuButton.setTitle("MENU", for: .normal)
        menuButton.setTitleColor(.black, for: .normal)
        menuButton.addTarget(self, action: "openMenu", for: .touchUpInside)
        view.addSubview(menuButton)
        
        textField = UITextField(frame: CGRect(x: 100, y: 200, width: view.frame.width - 200, height: 150))
        textField?.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
        view.addSubview(textField!)
        
        imageView = UIImageView(frame: CGRect(x: 100, y: 400, width: 300, height: 300))
        imageView?.backgroundColor = UIColor.gray
        view.addSubview(imageView!)
        
        let sendButton = UIButton(frame: CGRect(x: 100, y: 800, width: 150, height: 100))
        sendButton.backgroundColor = UIColor.blue
        sendButton.addTarget(self, action: #selector(self.sendToFB), for: .touchUpInside)
        view.addSubview(sendButton)
        
        getShareInfo()
    }
    
    func sendToFB() {
        if let text = textField?.text, let image = imageView?.image {
            
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
    
    func getShareInfo() {
        print("WTF")
        if let userDefaults = UserDefaults(suiteName: "group.musiquelive.datashare") {
            if let text = userDefaults.value(forKey: "shareText") as? String, let image = userDefaults.value(forKey: "path") as? String {
                textField?.text = text + extratext
                

                let imagePath = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(image)!

                let oldImageData = NSData(contentsOfFile: image)
                
                let oldImage = UIImage(data: oldImageData as! Data)
                self.imageView?.image = oldImage
            }
            
        }
    }
    
    
}
