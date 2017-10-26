//
//  TicketflyVC.swift
//  MusiqueDataEntry
//
//  Created by Tara Wilson on 8/3/17.
//  Copyright © 2017 twil. All rights reserved.
//

import Foundation
import UIKit

class TicketflyVC: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    
    var bands: [String]?
    var venues: [String]?
    
    var venueString: String?
    var goButton = UIButton()
    var venueTableView: UITableView!
    var tableView: UITableView!
    var events: [EventObject]?
    var didload = false
    var venueDict: [String: String]?
    
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
        
        tableView = UITableView(frame: CGRect(x: 20, y: 400, width: view.frame.width - 40, height: view.frame.height - 150))
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.layer.borderColor = UIColor.black.cgColor
        tableView.layer.borderWidth = 3
        tableView.delegate = self
        tableView.tag = 1
        tableView.dataSource = self
        view.addSubview(tableView)
        
        venueTableView = UITableView(frame: CGRect(x: 20, y: 90, width: view.frame.width - 40, height: 280))
        venueTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        venueTableView.layer.borderColor = UIColor.black.cgColor
        venueTableView.layer.borderWidth = 3
        venueTableView.tag = 2
        venueTableView.delegate = self
        venueTableView.dataSource = self
        view.addSubview(venueTableView)
        
        
    }
    
    func sendAll() {
        if let bands = self.bands {
            let intID = Int((venueDict?[venueString!])!)
            TicketFlyController().sendEvents(bands: self.bands!, id: intID!, events: self.events!, completion: {
                success in
                self.events = nil
                self.tableView.reloadData()
            })
        } else {
            let alert = UIAlertController(title: "Hang on", message: "All the bands are still downloading from the database, this takes a sec, try again in 20 seconds", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {
                handle in
            }))
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.tag == 1 {
            let alert = UIAlertController(title: "ACTION", message: "What do you want to do?", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Delete", style: UIAlertActionStyle.default, handler: {
                handle in
                self.events?.remove(at: indexPath.row)
                self.tableView.reloadData()
            }))
            alert.addAction(UIAlertAction(title: "Open this", style: UIAlertActionStyle.default, handler: {
                handle in
                self.openView(index: indexPath.row)
            }))
            self.present(alert, animated: true, completion: nil)
        } else {
            if let venues = venues {
                self.venueString = venues[indexPath.row]
            }
        }
        
    }
    
    func openView(index: Int) {
        let vc = DetailVC()
        vc.event = events?[index]
        navigationController?.present(vc, animated: true, completion: nil)
    }
    
    func fetchData() {
        goButton.backgroundColor = UIColor.gray
        if let venue = self.venueString, let id = venueDict?[venue] {
            TicketFlyController().getEventsForID(id: id, venue: venue, completion: {
                events in
                self.goButton.backgroundColor = UIColor.blue
                self.events = events
                self.tableView.reloadData()
            })
        }
    }
    
    func openMenu() {
        self.slideMenuController()?.openLeft()
    }
    
    
    func refresh() {
        NetworkController().getTicketFlyVenues(completion: {
            venuesDict in
            self.venues = Array(venuesDict.keys)
            self.venueDict = venuesDict
            self.venueTableView.reloadData()
            self.tableView.reloadData()
        })
        
        NetworkController().getBandObjectsList(completion: {
            bands in
            self.bands = bands
        })
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView.tag == 1 {
            return events?.count ?? 0
        } else {
            return venues?.count ?? 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView.tag == 1 {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "cell") {
                if let band = events?[indexPath.row].band?.band {
                    cell.textLabel?.text = band
                }
                if let extra = events?[indexPath.row].extraBands {
                    for extraband in extra {
                        cell.textLabel?.text = (cell.textLabel?.text)! + ", " + (extraband.band ?? "")
                    }
                }
                return cell
            }
        } else {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "cell") {
                if let venue = venues?[indexPath.row] {
                    cell.textLabel?.text = venue
                }
                return cell
            }
        }
        return UITableViewCell()
        
    }
    
}
