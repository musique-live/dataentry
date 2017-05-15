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
    var eventlist: [EventObject]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
        
        NetworkController().getVenuesListWithDates(completion: {
            events in
            self.eventlist = events?.sorted(by: { $0.timestamp?.compare(($1.timestamp as? Date) ?? Date()) == ComparisonResult.orderedAscending })
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
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return eventlist?.count ?? 0
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if let venue = eventlist?[indexPath.row].venue?.venue {
            if let date = eventlist?[indexPath.row].timestamp {
                let formatter = DateFormatter()
                formatter.dateStyle = .medium
                cell.textLabel?.text = venue + " " + formatter.string(from: date as Date)
            } else {
                cell.textLabel?.text = venue + " NONE"
            }
        }
        return cell
    }
    
    
}
