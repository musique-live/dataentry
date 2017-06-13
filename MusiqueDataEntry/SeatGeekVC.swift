//
//  SeatGeekVC.swift
//  MusiqueDataEntry
//
//  Created by Tara Wilson on 6/13/17.
//  Copyright © 2017 twil. All rights reserved.
//

import Foundation
import UIKit

class SeatGeekVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var tableView: UITableView!
    var events: [SeatGeekObject]?
    
    override func viewDidLoad() {
        view.backgroundColor = UIColor.white
        SeatGeekController().loadNextEvents(completion: {
            events in
            self.events = events
            self.tableView.reloadData()
        })
        
        view.backgroundColor = .white
        tableView = UITableView(frame: CGRect(x: 0, y: 10, width: view.frame.width, height: view.frame.height - 60))
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 80
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if let event = events?[indexPath.row], let name = event.name, let venue = event.venuename {
            cell.textLabel?.text = "\(name) at \(venue)"
        }
        return cell
    }
}
