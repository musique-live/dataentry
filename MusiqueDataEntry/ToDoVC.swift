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
    var venues: [String]?
    var name: String?
    
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
        tableView.dataSource = self
        view.addSubview(tableView)
        
        tableView.register(ToDoCell.self, forCellReuseIdentifier: "cell")
    }
    
    
    
    func getRegionSubview() -> UIView {
        subview = UIView(frame: CGRect(x: 50, y: 100, width: view.frame.width - 100, height: 200))
        subview.backgroundColor = .white
        
        buttonOne = UIButton(frame: CGRect(x: 20, y: view.frame.height/2, width: 100, height: 40))
        buttonOne.tag = 0
        buttonOne.setTitle("DC", for: .normal)
        buttonOne.addTarget(self, action: #selector(clickRegion), for: .touchUpInside)
        buttonOne.backgroundColor = UIColor.blue
        subview.addSubview(buttonOne)
        
        buttonTwo = UIButton(frame: CGRect(x: 140, y: view.frame.height/2, width: 100, height: 40))
        buttonTwo.tag = 1
        buttonTwo.setTitle("Annapolis", for: .normal)
        buttonTwo.addTarget(self, action: #selector(clickRegion), for: .touchUpInside)
        buttonTwo.backgroundColor = UIColor.blue
        subview.addSubview(buttonTwo)
        
        buttonThree = UIButton(frame: CGRect(x: 260, y: view.frame.height/2, width: 100, height: 40))
        buttonThree.tag = 2
        buttonThree.setTitle("Baltimore", for: .normal)
        buttonThree.addTarget(self, action: #selector(clickRegion), for: .touchUpInside)
        buttonThree.backgroundColor = UIColor.blue
        subview.addSubview(buttonThree)
        
        buttonFour = UIButton(frame: CGRect(x: 380, y: view.frame.height/2, width: 100, height: 40))
        buttonFour.tag = 3
        buttonFour.setTitle("Ocean City", for: .normal)
        buttonFour.addTarget(self, action: #selector(clickRegion), for: .touchUpInside)
        buttonFour.backgroundColor = UIColor.blue
        subview.addSubview(buttonFour)
        
        return subview
        
    }
    
    func clickRegion(button: UIButton) {
        button.backgroundColor = UIColor.gray
        switch button.tag {
        case 0:
            region = "DC"
        case 1:
            region = "Annapolis"
        case 2:
            region = "Baltimore"
        case 3:
            region = "OC"
        default:
            print("")
        }
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
        return 100
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? ToDoCell {
            if let venue = venues?[indexPath.row] {
                cell.getInfo(venue: venue)
            }
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
