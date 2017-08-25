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
    let venueField = AutoCompleteTextField()
    var venueString: String?
    var idEntry = UITextField()
    var goButton = UIButton()
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
        
        let halfwidth = view.frame.width/2
        
        refresh()
        
        let menuButton = UIButton(frame: CGRect(x: 20, y: 50, width: 100, height: 50))
        menuButton.setTitle("MENU", for: .normal)
        menuButton.setTitleColor(.black, for: .normal)
        menuButton.addTarget(self, action: #selector(TicketflyVC.openMenu), for: .touchUpInside)
        view.addSubview(menuButton)
        
        goButton = UIButton(frame: CGRect(x: 140, y: 50, width: 100, height: 50))
        goButton.setTitle("Fetch", for: .normal)
        goButton.backgroundColor = UIColor.blue
        goButton.setTitleColor(.white, for: .normal)
        goButton.addTarget(self, action: "fetchData", for: .touchUpInside)
        view.addSubview(goButton)
        
        let sendAllButton = UIButton(frame: CGRect(x: 260, y: 50, width: 100, height: 50))
        sendAllButton.setTitle("SEND ALL", for: .normal)
        sendAllButton.setTitleColor(.black, for: .normal)
        sendAllButton.addTarget(self, action: #selector(TicketflyVC.sendAll), for: .touchUpInside)
        view.addSubview(sendAllButton)
        
        tableView = UITableView(frame: CGRect(x: 20, y: 200, width: view.frame.width - 40, height: view.frame.height - 450))
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.layer.borderColor = UIColor.black.cgColor
        tableView.layer.borderWidth = 3
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
        
        venueField.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        venueField.autoCompleteTextColor = UIColor.black
        venueField.autoCompleteCellHeight = 50
        venueField.maximumAutoCompleteCount = 20
        venueField.hidesWhenSelected = true
        venueField.hidesWhenEmpty = true
        venueField.enableAttributedText = true
        venueField.placeholder = "Venue"
        venueField.frame = CGRect(x: 20, y: 120, width: halfwidth - 40, height: 50)
        view.addSubview(venueField)
        
        venueField.onSelect = {text, indexpath in
            self.venueString = text
            self.venueField.resignFirstResponder()
        }
        
        venueField.onTextChange = {text in
            self.venueField.autoCompleteStrings = self.venues?.filter() {($0.lowercased().contains(text.lowercased()))}
        }
        venueField.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: venueField.frame.size.height))
        venueField.leftView = paddingView
        venueField.leftViewMode = .always
        
        let notes = UILabel(frame: CGRect(x: 20, y: view.frame.height - 250, width: view.frame.width - 40, height: 230))
        notes.text = "9:30 Club, Baltimore Soundstage, Black Cat, Bottle and Cork, DC9, Echostage, Fish Head Cantina, Flash, Gypsy Sallys, Hill Country DC, Horseshoe Casino, Jammin java, Lincoln Theatre, Live! Center Stage, Merriweather Post Pavilion, Metro Gallery, Ottobar, Pier Six Concert Pavilion, Rams Head Dockside, Rams Head Live, Rams Head On Stage, Rams Head Tavern, Rock and Roll Hotel, Sixth & I Synagogue, Smokehouse Live, Songbyrd Music House, Soundcheck, The Hamilton, U Street Music Hall, Vinyl Lounge at Gypsy Sallys"
        notes.numberOfLines = 0
        view.addSubview(notes)
        
        
    }
    
    func sendAll() {
        let intID = Int((venueDict?[venueString!])!)
        TicketFlyController().sendEvents(bands: self.bands!, id: intID!, events: self.events!, completion: {
            success in
            self.events = nil
            self.tableView.reloadData()
        })
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
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
    }
    
    func openView(index: Int) {
        let vc = DetailVC()
        vc.event = events?[index]
        navigationController?.present(vc, animated: true, completion: nil)
    }
    
    func fetchData() {
        if let venue = self.venueString, let id = venueDict?[venue] {
            TicketFlyController().getEventsForID(id: id, venue: venue, completion: {
                events in
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
        return events?.count ?? 0
    }
 
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
        return UITableViewCell()
    }
 
}
