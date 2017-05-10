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
    var eventlist: [String]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NetworkController().getVenuesList(completion: {
            venues in
            self.eventlist = venues
            self.tableView.reloadData()
        })
        
        view.backgroundColor = .white
        tableView = UITableView(frame: CGRect(x: 0, y: 50, width: view.frame.width, height: view.frame.height - 110))
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 80
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return eventlist?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let alert = UIAlertController(title: "SELECTED", message: "Do you want claim or complete this item?", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Claim", style: UIAlertActionStyle.default, handler: {
            action in

        }))
        alert.addAction(UIAlertAction(title: "Complete", style: UIAlertActionStyle.default, handler: {
            action in

        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "May"
        case 1:
            return "June"
        case 2:
            return "July"
        case 3:
            return "August"
        case 4:
            return "September"
        default:
            return "Error"
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = eventlist?[indexPath.row]
        return cell
    }
    
    
}
