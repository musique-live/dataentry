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
        
        NetworkController().getVenuesList(completion:  {
            venues in
            self.venues = venues
            self.tableView.reloadData()
        })
        
        
        view.backgroundColor = .white
        tableView = UITableView(frame: CGRect(x: 0, y: 10, width: view.frame.width, height: view.frame.height - 60))
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
        
        tableView.register(ToDoCell.self, forCellReuseIdentifier: "cell")
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 80
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
