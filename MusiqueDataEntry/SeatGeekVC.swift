//
//  SeatGeekVC.swift
//  MusiqueDataEntry
//
//  Created by Tara Wilson on 6/13/17.
//  Copyright © 2017 twil. All rights reserved.
//

import Foundation
import UIKit

class SeatGeekVC: UIViewController, UITableViewDelegate, UITableViewDataSource, SeatGeekObjectDecisionProtocol {

    
    var tableView: UITableView!
    var events: [SeatGeekObject]?
    let sgcontroller = SeatGeekController()
    var subview: UIView?
    var close = UIButton()
    var morebutton = UIButton()
    
    override func viewDidLoad() {
        view.backgroundColor = UIColor.darkGray
        sgcontroller.loadNextEvents(completion: {
            events in
            self.events = events
            self.tableView.reloadData()
        })
        
        let menuButton = UIButton(frame: CGRect(x: 30, y: 20, width: 100, height: 50))
        menuButton.setTitle("MENU", for: .normal)
        menuButton.setTitleColor(.white, for: .normal)
        menuButton.addTarget(self, action: "openMenu", for: .touchUpInside)
        view.addSubview(menuButton)
        
        morebutton = UIButton(frame: CGRect(x: view.frame.width - 200, y: 20, width: 150, height: 50))
        morebutton.setTitle("LOAD MORE", for: .normal)
        morebutton.addTarget(self, action: "loadMore", for: .touchUpInside)
        morebutton.setTitleColor(UIColor.white, for: .normal)
        view.addSubview(morebutton)
        
        tableView = UITableView(frame: CGRect(x: 0, y: 90, width: view.frame.width, height: view.frame.height - 90))
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
        
        tableView.register(SeatGeekCell.self, forCellReuseIdentifier: "cell")
    }
    
    func loadMore() {
        morebutton.backgroundColor = UIColor.gray
        self.events = nil
        tableView.reloadData()
        sgcontroller.loadNextEvents(completion: {
            events in
            self.events = events
            self.morebutton.backgroundColor = UIColor.blue
            self.tableView.reloadData()
        })
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 400
    }
    
    func didDeny(event: SeatGeekObject, index: Int) {
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? SeatGeekCell {
            if let event = events?[indexPath.row] {
                cell.setInfo(event: event, index: indexPath.row)
            }
            cell.delegate = self
            cell.selectionStyle = .none
            return cell
        }
        return UITableViewCell()
    }
    
    func openMenu() {
        self.slideMenuController()?.openLeft()
    }
    
    func didProceed(event: SeatGeekObject, index: Int) {
        
    }
    
    func didEdit(event: SeatGeekObject, index: Int) {
        events?.remove(at: index)
        tableView.reloadData()
        if let nextvc = self.tabBarController?.viewControllers?[1] as? BandEntryVC {
            nextvc.seatGeekObject = event
            self.tabBarController?.selectedIndex = 1
        }
    }
    
    func closeVid() {
        if let subview = subview {
            subview.removeFromSuperview()
            close.removeFromSuperview()
        }
    }
}

class SeatGeekCell: UITableViewCell {
    
    //check lat and long, see if venue is input, make sure has id
    var delegate: SeatGeekObjectDecisionProtocol!
    let eventname = UILabel()
    let date = UILabel()
    let bandimage = UIImageView()
    let genres = UILabel()
    let address = UILabel()
    let looksGood = UIButton()
    let deny = UIButton()
    let edit = UIButton()
    let seeVideo = UIButton()
    let hasVenue = UILabel()
    var event: SeatGeekObject?
    var index: Int?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        eventname.translatesAutoresizingMaskIntoConstraints = false
        eventname.numberOfLines = 3
        contentView.addSubview(eventname)
        
        date.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(date)
        
        bandimage.translatesAutoresizingMaskIntoConstraints = false
        bandimage.backgroundColor = UIColor.lightGray
        bandimage.contentMode = .scaleAspectFit
        contentView.addSubview(bandimage)
        
        genres.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(genres)
        
        hasVenue.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(hasVenue)
        
        address.translatesAutoresizingMaskIntoConstraints = false
        address.numberOfLines = 2
        contentView.addSubview(address)
        
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
            NSLayoutConstraint(item: eventname, attribute: .trailing, relatedBy: .equal, toItem: contentView, attribute: .leading, multiplier: 1, constant: 300),
            NSLayoutConstraint(item: eventname, attribute: .top, relatedBy: .equal, toItem: contentView, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: eventname, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 70)
            ])
        contentView.addConstraints([
            NSLayoutConstraint(item: date, attribute: .leading, relatedBy: .equal, toItem: contentView, attribute: .leading, multiplier: 1, constant: 10),
            NSLayoutConstraint(item: date, attribute: .trailing, relatedBy: .equal, toItem: contentView, attribute: .leading, multiplier: 1, constant: 150),
            NSLayoutConstraint(item: date, attribute: .top, relatedBy: .equal, toItem: eventname, attribute: .bottom, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: date, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 30)
            ])
        contentView.addConstraints([
            NSLayoutConstraint(item: genres, attribute: .leading, relatedBy: .equal, toItem: contentView, attribute: .leading, multiplier: 1, constant: 160),
            NSLayoutConstraint(item: genres, attribute: .trailing, relatedBy: .equal, toItem: contentView, attribute: .leading, multiplier: 1, constant: 300),
            NSLayoutConstraint(item: genres, attribute: .top, relatedBy: .equal, toItem: eventname, attribute: .bottom, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: genres, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 30)
            ])
        contentView.addConstraints([
            NSLayoutConstraint(item: address, attribute: .leading, relatedBy: .equal, toItem: contentView, attribute: .leading, multiplier: 1, constant: 10),
            NSLayoutConstraint(item: address, attribute: .trailing, relatedBy: .equal, toItem: contentView, attribute: .leading, multiplier: 1, constant: 300),
            NSLayoutConstraint(item: address, attribute: .top, relatedBy: .equal, toItem: date, attribute: .bottom, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: address, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 50)
            ])
        
        
        contentView.addConstraints([
            NSLayoutConstraint(item: bandimage, attribute: .leading, relatedBy: .equal, toItem: contentView, attribute: .leading, multiplier: 1, constant: 20),
            NSLayoutConstraint(item: bandimage, attribute: .trailing, relatedBy: .equal, toItem: contentView, attribute: .leading, multiplier: 1, constant: 290),
            NSLayoutConstraint(item: bandimage, attribute: .top, relatedBy: .equal, toItem: address, attribute: .bottom, multiplier: 1, constant: 20),
            NSLayoutConstraint(item: bandimage, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 180)
            ])
        
        contentView.addConstraints([
            NSLayoutConstraint(item: hasVenue, attribute: .leading, relatedBy: .equal, toItem: contentView, attribute: .leading, multiplier: 1, constant: 10),
            NSLayoutConstraint(item: hasVenue, attribute: .trailing, relatedBy: .equal, toItem: contentView, attribute: .leading, multiplier: 1, constant: 300),
            NSLayoutConstraint(item: hasVenue, attribute: .top, relatedBy: .equal, toItem: bandimage, attribute: .bottom, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: hasVenue, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 50)
            ])
        
        contentView.addConstraints([
            NSLayoutConstraint(item: deny, attribute: .leading, relatedBy: .equal, toItem: contentView, attribute: .trailing, multiplier: 1, constant: -200),
            NSLayoutConstraint(item: deny, attribute: .trailing, relatedBy: .equal, toItem: contentView, attribute: .trailing, multiplier: 1, constant: -10),
            NSLayoutConstraint(item: deny, attribute: .top, relatedBy: .equal, toItem: contentView, attribute: .top, multiplier: 1, constant: 100),
            NSLayoutConstraint(item: deny, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 50)
            ])
        contentView.addConstraints([
            NSLayoutConstraint(item: edit, attribute: .leading, relatedBy: .equal, toItem: contentView, attribute: .trailing, multiplier: 1, constant: -200),
            NSLayoutConstraint(item: edit, attribute: .trailing, relatedBy: .equal, toItem: contentView, attribute: .trailing, multiplier: 1, constant: -10),
            NSLayoutConstraint(item: edit, attribute: .top, relatedBy: .equal, toItem: deny, attribute: .bottom, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: edit, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 50)
            ])
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func setInfo(event: SeatGeekObject, index: Int) {
        self.event = event
        self.index = index
        var canContinue = true
        if let name = event.name, let venue = event.venuename {
            self.eventname.text = "\(name) at \(venue)"
        } else {
            canContinue = false
        }
        if let eventdate = event.date {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            self.date.text = formatter.string(from: eventdate as Date)
        } else {
            canContinue = false
        }
        var genrestring = ""
        for genre in event.genres {
            genrestring = genrestring + genre + " "
        }
        self.genres.text = genrestring
        if genrestring.isEmpty {
            canContinue = false
        }
        
        if let addressStr = event.address {
            self.address.text = addressStr
        } else {
            canContinue = false
        }
        
        if let image = event.imageURL {
            let url = URL(string: image)
            bandimage.sd_setImage(with: url)
        }
        
        if let exist = event.venueExists, exist == true {
            hasVenue.text = "Venue Exists"
            hasVenue.textColor = UIColor.green
        } else {
            hasVenue.text = "New Venue"
            hasVenue.textColor = UIColor.red
            canContinue = false
        }
        
        if canContinue == false {
            looksGood.isEnabled = false
            looksGood.setTitleColor(UIColor.gray, for: .normal)
        }
    }
    
    func pressEdit() {
        delegate.didEdit(event: self.event!, index: index!)
    }
    
    func pressDeny() {
        delegate.didDeny(event: self.event!, index: index!)
    }
    
    override func prepareForReuse() {
        self.eventname.text = nil
        self.date.text = nil
        self.bandimage.image = nil
        self.genres.text = nil
        self.address.text = nil
        self.looksGood.isEnabled = true
        self.edit.isEnabled = true
        self.deny.isEnabled = true
        self.seeVideo.isEnabled = true
        self.deny.setTitleColor(UIColor.blue, for: .normal)
        self.edit.setTitleColor(UIColor.blue, for: .normal)
        self.looksGood.setTitleColor(UIColor.blue, for: .normal)
        
    }
    
}
