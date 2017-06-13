//
//  ToDoCell.swift
//  MusiqueDataEntry
//
//  Created by Tara Wilson on 6/13/17.
//  Copyright © 2017 twil. All rights reserved.
//

import Foundation
import UIKit

class ToDoCell: UITableViewCell {
    
    let label = UILabel()
    let date = UILabel()
    let claimed = UILabel()
    let unclaim = UIButton()
    var venue: String?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 18)
        contentView.addSubview(label)
        
        claimed.translatesAutoresizingMaskIntoConstraints = false
        claimed.font = UIFont.systemFont(ofSize: 18)
        contentView.addSubview(claimed)
        
        date.translatesAutoresizingMaskIntoConstraints = false
        date.textAlignment = .right
        contentView.addSubview(date)
        
        unclaim.translatesAutoresizingMaskIntoConstraints = false
        unclaim.setTitle("Done Working", for: .normal)
        unclaim.addTarget(self, action: "StopWorking", for: .touchUpInside)
        unclaim.setTitleColor(UIColor.blue, for: .normal)
        unclaim.titleLabel?.textAlignment = .right
        contentView.addSubview(unclaim)
        
        contentView.addConstraints([
            NSLayoutConstraint(item: date, attribute: .leading, relatedBy: .equal, toItem: contentView, attribute: .trailing, multiplier: 1, constant: -100),
            NSLayoutConstraint(item: date, attribute: .trailing, relatedBy: .equal, toItem: contentView, attribute: .trailing, multiplier: 1, constant: -10),
            NSLayoutConstraint(item: date, attribute: .top, relatedBy: .equal, toItem: contentView, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: date, attribute: .bottom, relatedBy: .equal, toItem: contentView, attribute: .bottom, multiplier: 1, constant: -20)
            ])
        contentView.addConstraints([
            NSLayoutConstraint(item: unclaim, attribute: .leading, relatedBy: .equal, toItem: date, attribute: .leading, multiplier: 1, constant: -150),
            NSLayoutConstraint(item: unclaim, attribute: .trailing, relatedBy: .equal, toItem: date, attribute: .leading, multiplier: 1, constant: -10),
            NSLayoutConstraint(item: unclaim, attribute: .top, relatedBy: .equal, toItem: contentView, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: unclaim, attribute: .bottom, relatedBy: .equal, toItem: contentView, attribute: .bottom, multiplier: 1, constant: -20)
            ])
        contentView.addConstraints([
            NSLayoutConstraint(item: label, attribute: .leading, relatedBy: .equal, toItem: contentView, attribute: .leading, multiplier: 1, constant: 10),
            NSLayoutConstraint(item: label, attribute: .trailing, relatedBy: .equal, toItem: contentView, attribute: .trailing, multiplier: 1, constant: -200),
            NSLayoutConstraint(item: label, attribute: .top, relatedBy: .equal, toItem: contentView, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: label, attribute: .bottom, relatedBy: .equal, toItem: contentView, attribute: .bottom, multiplier: 1, constant: -20)
            ])
        contentView.addConstraints([
            NSLayoutConstraint(item: claimed, attribute: .leading, relatedBy: .equal, toItem: contentView, attribute: .leading, multiplier: 1, constant: 10),
            NSLayoutConstraint(item: claimed, attribute: .trailing, relatedBy: .equal, toItem: contentView, attribute: .trailing, multiplier: 1, constant: -200),
            NSLayoutConstraint(item: claimed, attribute: .top, relatedBy: .equal, toItem: contentView, attribute: .top, multiplier: 1, constant: 40),
            NSLayoutConstraint(item: claimed, attribute: .bottom, relatedBy: .equal, toItem: contentView, attribute: .bottom, multiplier: 1, constant: 0)
            ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func StopWorking() {
        if let venue = venue {
            self.claimed.text = nil
            NetworkController().setClaimed(venue: venue, name: "")
        }
    }
    
    func getInfo(venue: String) {
        self.label.text = venue
        self.venue = venue
        NetworkController().getLastDate(fullvenue: venue, completion: {
            event in
            if let date = event?.timestamp {
                let currentdate = Date()
                let calendar = NSCalendar.current
                let components = calendar.dateComponents([.day], from: currentdate, to: date as Date)
                if components.day! < 3 {
                    self.backgroundColor = UIColor.red.withAlphaComponent(0.5)
                } else if components.day! < 14 {
                    self.backgroundColor = UIColor.yellow.withAlphaComponent(0.5)
                } else if components.day! > 40 {
                    self.backgroundColor = UIColor.yellow.withAlphaComponent(0.5)
                }
                let formatter = DateFormatter()
                formatter.dateStyle = .short
                self.date.text = formatter.string(from: date as Date)
            } else {
                self.date.text = "NONE"
                self.backgroundColor = UIColor.red.withAlphaComponent(0.5)
            }
        })
        
        NetworkController().getClaimed(venue: venue, completion: {
            name in
            if let name = name {
                if !name.isEmpty {
                    self.claimed.text = "Currently being worked on by: \(name)"
                }
            }
        })
        
    }
    
    func setClaimed(venue: String, name: String) {
        NetworkController().setClaimed(venue: venue, name: name)
        self.claimed.text = "Currently being worked on by: \(name)"
    }
    
    override func prepareForReuse() {
        self.backgroundColor = UIColor.white
        self.label.text = nil
        self.date.text = nil
        self.claimed.text = nil
    }
    
}
