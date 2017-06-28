//
//  ToDoList.swift
//  MusiqueDataEntry
//
//  Created by Tara Wilson on 4/24/17.
//  Copyright © 2017 twil. All rights reserved.
//

import Foundation
import UIKit

class ToDoList: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var tableView: UITableView!
    var venues: [String]?
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
            self.venues = venues.sorted()
            self.tableView.reloadData()
        })
        
        let menuButton = UIButton(frame: CGRect(x: 30, y: 20, width: 100, height: 50))
        menuButton.setTitle("MENU", for: .normal)
        menuButton.setTitleColor(.white, for: .normal)
        menuButton.addTarget(self, action: "openMenu", for: .touchUpInside)
        view.addSubview(menuButton)
        
        tableView = UITableView(frame: CGRect(x: 0, y: 90, width: view.frame.width, height: view.frame.height - 90))
        tableView.delegate = self
        let refresh = UIRefreshControl()
        refresh.addTarget(self, action: "refresh", for: .valueChanged)
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refresh
        }
        tableView.dataSource = self
        view.addSubview(tableView)
        
        tableView.register(ToDoCell.self, forCellReuseIdentifier: "cell")
    }
    
    func refresh() {
        NetworkController().getVenuesList(completion:  {
            venues in
            self.venues = venues.sorted()
            if #available(iOS 10.0, *) {
                self.tableView.refreshControl?.endRefreshing()
            }
            self.tableView.reloadData()
        })
    }
    
    func addRegion(venue: String) {
        currentVenue = venue
        regionView = getRegionSubview()
        view.addSubview(regionView!)
    }
    
    func getRegionSubview() -> UIView {
        let subview = UIView(frame: CGRect(x: 50, y: 100, width: view.frame.width - 100, height: 250))
        subview.layer.borderWidth = 5
        subview.layer.borderColor = UIColor.black.cgColor
        subview.backgroundColor = .white
        
        let buttonOne = UIButton(frame: CGRect(x: 10, y: 40, width: 100, height: 60))
        buttonOne.tag = 0
        buttonOne.setTitle("DC", for: .normal)
        buttonOne.addTarget(self, action: #selector(clickRegion), for: .touchUpInside)
        buttonOne.backgroundColor = UIColor.blue
        subview.addSubview(buttonOne)
        
        let buttonTwo = UIButton(frame: CGRect(x: 120, y: 40, width: 100, height: 60))
        buttonTwo.tag = 1
        buttonTwo.setTitle("Annapolis", for: .normal)
        buttonTwo.addTarget(self, action: #selector(clickRegion), for: .touchUpInside)
        buttonTwo.backgroundColor = UIColor.blue
        subview.addSubview(buttonTwo)
        
        let buttonThree = UIButton(frame: CGRect(x: 230, y: 40, width: 100, height: 60))
        buttonThree.tag = 2
        buttonThree.setTitle("Baltimore", for: .normal)
        buttonThree.addTarget(self, action: #selector(clickRegion), for: .touchUpInside)
        buttonThree.backgroundColor = UIColor.blue
        subview.addSubview(buttonThree)
        
        let buttonFour = UIButton(frame: CGRect(x: 340, y: 40, width: 100, height: 60))
        buttonFour.tag = 3
        buttonFour.setTitle("Ocean City", for: .normal)
        buttonFour.addTarget(self, action: #selector(clickRegion), for: .touchUpInside)
        buttonFour.backgroundColor = UIColor.blue
        subview.addSubview(buttonFour)
        
        let ok = UIButton(frame: CGRect(x: 10, y: 40, width: 100, height: 60))
        ok.setTitle("OK", for: .normal)
        ok.addTarget(self, action: #selector(self.ok), for: .touchUpInside)
        ok.backgroundColor = UIColor.blue
        subview.addSubview(ok)
        
        let spinner = UIPickerView(frame: CGRect(x: 450, y: 50, width: 150, height: 100))
        spinner.delegate = self
        spinner.backgroundColor = UIColor.gray
        spinner.dataSource = self
        subview.addSubview(spinner)
        
        return subview
        
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 100
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(row)"
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        reservationsNumber = row
    }
    
    func clickRegion(button: UIButton) {
        button.backgroundColor = UIColor.gray
        switch button.tag {
        case 0:
            currentRegion = "DC"
        case 1:
            currentRegion = "Annapolis"
        case 2:
            currentRegion = "Baltimore"
        case 3:
            currentRegion = "OC"
        default:
            print("")
        }
    }
    
    func ok() {
        sendRegion()
    }
    
    func sendRegion() {
        if let view = regionView {
            regionView?.removeFromSuperview()
            regionView = nil
        }
        guard let ven = currentVenue, let reg = currentRegion, let res = reservationsNumber else { return }
        NetworkController().updateRegion(venue: ven, region: reg, res: res)
        currentRegion = nil
        currentVenue = nil
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
        return 180
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? ToDoCell {
            if let venue = venues?[indexPath.row] {
                cell.getInfo(venue: venue)
            }
            cell.parent = self
            cell.selectionStyle = .none
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? ToDoCell {
            if let venue = venues?[indexPath.row] {
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
