//
//  ToDoList.swift
//  MusiqueDataEntry
//
//  Created by Tara Wilson on 4/24/17.
//  Copyright © 2017 twil. All rights reserved.
//

import Foundation
import UIKit

class ToDoList: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var tableView: UITableView!
    var venues: NSDictionary?
    var allVenues = [String]()
    var taraVenues = [String]()
    var kathiVenues = [String]()
    var tameraVenues = [String]()
    var unclaimedvenues = [String]()
    var name: String?
    var currentRegion: String?
    var currentVenue: String?
    var regionView: UIView?
    var reservationsNumber: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.darkGray
        
        NetworkController().getVenuesList(completion:  {
            venues in
            self.venues = venues
            self.allVenues = venues.allKeys as! [String]
            self.tableView.reloadData()
            
            for venue in self.allVenues {
                if let val = venues.object(forKey: venue) as? String {
                    switch val {
                    case "tara":
                        self.taraVenues.append(venue)
                    case "tamera":
                        self.tameraVenues.append(venue)
                    case "kathi":
                        self.kathiVenues.append(venue)
                    case "unclaimed":
                        self.unclaimedvenues.append(venue)
                    default:
                        self.unclaimedvenues.append(venue)
                    }
                }
                
            }
        })
        
        let menuButton = UIButton(frame: CGRect(x: 30, y: 20, width: 100, height: 50))
        menuButton.setTitle("MENU", for: .normal)
        menuButton.setTitleColor(.white, for: .normal)
        menuButton.addTarget(self, action: "openMenu", for: .touchUpInside)
        view.addSubview(menuButton)
        
        let kathiButton = UIButton(frame: CGRect(x: 150, y: 20, width: 100, height: 50))
        kathiButton.setTitle("Kathi", for: .normal)
        kathiButton.setTitleColor(.white, for: .normal)
        kathiButton.tag = 0
        kathiButton.addTarget(self, action: #selector(ToDoList.filterUser), for: .touchUpInside)
        view.addSubview(kathiButton)
        
        let tamerabutton = UIButton(frame: CGRect(x: 270, y: 20, width: 100, height: 50))
        tamerabutton.setTitle("Tamera", for: .normal)
        tamerabutton.setTitleColor(.white, for: .normal)
        tamerabutton.tag = 1
        tamerabutton.addTarget(self, action: #selector(ToDoList.filterUser), for: .touchUpInside)
        view.addSubview(tamerabutton)
        
        let tarabutton = UIButton(frame: CGRect(x: 390, y: 20, width: 100, height: 50))
        tarabutton.setTitle("Tara", for: .normal)
        tarabutton.setTitleColor(.white, for: .normal)
        tarabutton.tag = 2
        tarabutton.addTarget(self, action: #selector(ToDoList.filterUser), for: .touchUpInside)
        view.addSubview(tarabutton)
        
        let unknown = UIButton(frame: CGRect(x: 510, y: 20, width: 100, height: 50))
        unknown.setTitle("Unclaimed", for: .normal)
        unknown.setTitleColor(.white, for: .normal)
        unknown.tag = 3
        unknown.addTarget(self, action: #selector(ToDoList.filterUser), for: .touchUpInside)
        view.addSubview(unknown)
        
        let all = UIButton(frame: CGRect(x: 630, y: 20, width: 100, height: 50))
        all.setTitle("All", for: .normal)
        all.setTitleColor(.white, for: .normal)
        all.tag = 4
        all.addTarget(self, action: #selector(ToDoList.filterUser), for: .touchUpInside)
        view.addSubview(all)
        
        tableView = UITableView(frame: CGRect(x: 0, y: 90, width: view.frame.width, height: view.frame.height - 90))
        tableView.delegate = self
        let refresh = UIRefreshControl()
        refresh.addTarget(self, action: #selector(ToDoList.refresh), for: .valueChanged)
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refresh
        }
        tableView.dataSource = self
        view.addSubview(tableView)
        
        tableView.register(ToDoCell.self, forCellReuseIdentifier: "cell")
        
        
    }
    
    func filterUser(button: UIButton) {
        switch button.tag {
        case 0:
            let dict = NSMutableDictionary()
            for val in kathiVenues {
                dict.setObject("kathi", forKey: val as NSCopying)
            }
            venues = dict
            tableView.reloadData()
        case 1:
            let dict = NSMutableDictionary()
            for val in tameraVenues {
                dict.setObject("tamera", forKey: val as NSCopying)
            }
            venues = dict
            tableView.reloadData()
        case 2:
            let dict = NSMutableDictionary()
            for val in taraVenues {
                dict.setObject("tara", forKey: val as NSCopying)
            }
            venues = dict
            tableView.reloadData()
        case 3:
            let dict = NSMutableDictionary()
            for val in unclaimedvenues {
                dict.setObject("unclaimed", forKey: val as NSCopying)
            }
            venues = dict
            tableView.reloadData()
        case 4:
            let dict = NSMutableDictionary()
            for val in allVenues {
                dict.setObject("", forKey: val as NSCopying)
            }
            venues = dict
            tableView.reloadData()
        default:
            let dict = NSMutableDictionary()
            for val in allVenues {
                dict.setObject("", forKey: val as NSCopying)
            }
            venues = dict
            tableView.reloadData()
        }
    }
    
    func refresh() {
        NetworkController().getVenuesList(completion:  {
            venues in
            if #available(iOS 10.0, *) {
                self.tableView.refreshControl?.endRefreshing()
            }
            self.tableView.reloadData()
        })
    }


    
    func openMenu() {
        self.slideMenuController()?.openLeft()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return venues?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? ToDoCell {
            if let keys = venues?.allKeys as? [String] {
                let venue = keys[indexPath.row]
                cell.getInfo(venue: venue)
                cell.claimedBy(name: venues?.object(forKey: venue) as! String)
            }
            cell.parent = self
            cell.selectionStyle = .none
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? ToDoCell {
            if let keys = venues?.allKeys as? [String] {
                let venue = keys[indexPath.row]
                if let name = self.name {
                    cell.setClaimed(venue: venue, name: name)
                } else {
                    getName(cell: cell, venue: venue)
                }
            }
        }
    }
    
    func getName(cell: ToDoCell, venue: String) {
        let alert = UIAlertController(title: "CLAIM", message: "Enter name:", preferredStyle: UIAlertControllerStyle.alert)
        alert.addTextField(configurationHandler: {
            textfield in
        })
        alert.addAction(UIAlertAction(title: "Save", style: UIAlertActionStyle.default, handler: {
            handle in
            let firstTextField = alert.textFields![0] as UITextField
            cell.setClaimed(venue: venue, name: firstTextField.text ?? "User")
            self.name = firstTextField.text
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: {
            handle in
        }))
        self.present(alert, animated: true, completion: nil)
    }
}
