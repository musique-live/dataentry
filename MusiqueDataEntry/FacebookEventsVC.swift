//
//  TicketflyVC.swift
//  MusiqueDataEntry
//
//  Created by Tara Wilson on 8/3/17.
//  Copyright © 2017 twil. All rights reserved.
//

import Foundation
import UIKit
import FBSDKCoreKit
import Eureka
import SDWebImage
import FBSDKLoginKit

class FacebookEventsVC: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    
    var goButton = UIButton()
    var tableView: UITableView!
    var events = [FacebookEvent]()
    var venueString: String?
    var input: UITextField?
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        
        refresh()
        
        let menuButton = UIButton(frame: CGRect(x: 20, y: 20, width: 100, height: 50))
        menuButton.setTitle("MENU", for: .normal)
        menuButton.setTitleColor(.black, for: .normal)
        menuButton.addTarget(self, action: #selector(TicketflyVC.openMenu), for: .touchUpInside)
        view.addSubview(menuButton)
        
        goButton = UIButton(frame: CGRect(x: 140, y: 20, width: 100, height: 50))
        goButton.setTitle("Fetch", for: .normal)
        goButton.backgroundColor = UIColor.blue
        goButton.setTitleColor(.white, for: .normal)
        goButton.addTarget(self, action: "fetchData", for: .touchUpInside)
        view.addSubview(goButton)
        
        let sendAllButton = UIButton(frame: CGRect(x: 260, y: 20, width: 100, height: 50))
        sendAllButton.setTitle("SEND ALL", for: .normal)
        sendAllButton.setTitleColor(.black, for: .normal)
        sendAllButton.addTarget(self, action: #selector(TicketflyVC.sendAll), for: .touchUpInside)
        view.addSubview(sendAllButton)
        
        input = UITextField(frame: CGRect(x: 20, y: 90, width: 100, height: 50))
        input?.backgroundColor = UIColor.gray
        input?.delegate = self
        view.addSubview(input!)
        
        tableView = UITableView(frame: CGRect(x: 20, y: 200, width: view.frame.width - 40, height: view.frame.height - 350))
        tableView.register(FBScrapeCell.self, forCellReuseIdentifier: "cell")
        tableView.layer.borderColor = UIColor.black.cgColor
        tableView.layer.borderWidth = 3
        tableView.delegate = self
        tableView.tag = 1
        tableView.dataSource = self
        view.addSubview(tableView)
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.venueString = textField.text ?? ""
        return true
    }
    
    func sendAll() {
        
    }
    
    func fetchData() {
        goButton.backgroundColor = UIColor.gray
        if let val = self.venueString {
            tryFacebook(value: val)
        } else if let val = self.input?.text {
            tryFacebook(value: val)
        }
    }
    
    func tryFacebook(value: String) {
        if let accesstoken = UserDefaults.standard.string(forKey: "fbkey") {
            let request = FBSDKGraphRequest(graphPath: "/\(value)", parameters: ["fields": "name, events"], tokenString: accesstoken, version: "", httpMethod: "GET")
            let _ = request?.start(completionHandler: {
                requesthandler in
                if let dict = requesthandler.1 as? NSDictionary{
                    if let eventsdict = dict["events"] as? NSDictionary {
                        self.handleEvents(events: (eventsdict["data"] as? [NSDictionary])!)
                    }
                    
                } else {
                    
                }
            })
        } 
    }
    
    func handleEvents(events: [NSDictionary]) {
        goButton.backgroundColor = UIColor.blue
        for event in events {
            if let mappedEvent = FacebookEvent(JSON: event as! [String : Any]) {
                self.events.append(mappedEvent)
                tableView.reloadData()
            }
        }
    }
    
    func openMenu() {
        self.slideMenuController()?.openLeft()
    }
    
    
    func refresh() {

    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

            return events.count
 
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

            if let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as? FBScrapeCell{
                cell.setInfo(event: events[indexPath.row], index: indexPath.row)
                return cell
            }

        return UITableViewCell()
        
    }
    
}

class FBScrapeCell: UITableViewCell {
    
    let eventname = UILabel()
    let date = UILabel()
    let looksGood = UIButton()
    let deny = UIButton()
    let edit = UIButton()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        eventname.translatesAutoresizingMaskIntoConstraints = false
        eventname.numberOfLines = 3
        contentView.addSubview(eventname)
        
        date.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(date)
        
        deny.translatesAutoresizingMaskIntoConstraints = false
        deny.setTitle("Deny", for: .normal)
        deny.setTitleColor(UIColor.blue, for: .normal)
        deny.addTarget(self, action: "pressDeny", for: .touchUpInside)
        contentView.addSubview(deny)
        
        edit.translatesAutoresizingMaskIntoConstraints = false
        edit.setTitle("Edit", for: .normal)
        edit.setTitleColor(UIColor.blue, for: .normal)
        edit.addTarget(self, action: "pressEdit", for: .touchUpInside)
        contentView.addSubview(edit)
        
        contentView.addConstraints([
            NSLayoutConstraint(item: eventname, attribute: .leading, relatedBy: .equal, toItem: contentView, attribute: .leading, multiplier: 1, constant: 10),
            NSLayoutConstraint(item: eventname, attribute: .trailing, relatedBy: .equal, toItem: contentView, attribute: .trailing, multiplier: 1, constant: -10),
            NSLayoutConstraint(item: eventname, attribute: .top, relatedBy: .equal, toItem: contentView, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: eventname, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 70)
            ])
        contentView.addConstraints([
            NSLayoutConstraint(item: date, attribute: .leading, relatedBy: .equal, toItem: contentView, attribute: .leading, multiplier: 1, constant: 10),
            NSLayoutConstraint(item: date, attribute: .trailing, relatedBy: .equal, toItem: contentView, attribute: .trailing, multiplier: 1, constant: -10),
            NSLayoutConstraint(item: date, attribute: .top, relatedBy: .equal, toItem: eventname, attribute: .bottom, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: date, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 30)
            ])
        
        
        contentView.addConstraints([
            NSLayoutConstraint(item: deny, attribute: .leading, relatedBy: .equal, toItem: contentView, attribute: .trailing, multiplier: 1, constant: -60),
            NSLayoutConstraint(item: deny, attribute: .trailing, relatedBy: .equal, toItem: contentView, attribute: .trailing, multiplier: 1, constant: -10),
            NSLayoutConstraint(item: deny, attribute: .top, relatedBy: .equal, toItem: contentView, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: deny, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 50)
            ])
        contentView.addConstraints([
            NSLayoutConstraint(item: edit, attribute: .leading, relatedBy: .equal, toItem: contentView, attribute: .trailing, multiplier: 1, constant: -60),
            NSLayoutConstraint(item: edit, attribute: .trailing, relatedBy: .equal, toItem: contentView, attribute: .trailing, multiplier: 1, constant: -10),
            NSLayoutConstraint(item: edit, attribute: .top, relatedBy: .equal, toItem: deny, attribute: .bottom, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: edit, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 50)
            ])
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func setInfo(event: FacebookEvent, index: Int) {
        if let name = event.name, let venue = event.place {
            self.eventname.text = "\(name) at \(venue)"
        }
        if let eventdate = event.date {
            let formatter = DateFormatter()
            formatter.dateStyle = .long
            self.date.text = formatter.string(from: eventdate)
        }
    }
    
    func pressEdit() {

    }
    
    func pressDeny() {
    
    }
    
    override func prepareForReuse() {
        self.eventname.text = nil
        self.date.text = nil
        self.looksGood.isEnabled = true
        self.edit.isEnabled = true
        self.deny.isEnabled = true
        self.deny.setTitleColor(UIColor.blue, for: .normal)
        self.edit.setTitleColor(UIColor.blue, for: .normal)
        self.looksGood.setTitleColor(UIColor.blue, for: .normal)
        
    }
    
}

