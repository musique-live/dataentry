//
//  SeatGeekVC.swift
//  MusiqueDataEntry
//
//  Created by Tara Wilson on 6/13/17.
//  Copyright © 2017 twil. All rights reserved.
//

import Foundation
import UIKit

class SeatGeekVC: UIViewController, UITableViewDelegate, UITableViewDataSource, SeatGeekObjectDecisionProtocol {
    
    var tableView: UITableView!
    var events: [SeatGeekObject]?
    let sgcontroller = SeatGeekController()
    var subview: UIView?
    var close = UIButton()
    var morebutton = UIButton()
    
    override func viewDidLoad() {
        view.backgroundColor = UIColor.white
        sgcontroller.loadNextEvents(completion: {
            events in
            self.events = events
            self.tableView.reloadData()
        })
        
        view.backgroundColor = .white
        tableView = UITableView(frame: CGRect(x: 0, y: 50, width: view.frame.width, height: view.frame.height - 60))
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
        
        tableView.register(SeatGeekCell.self, forCellReuseIdentifier: "cell")
        
        morebutton = UIButton(frame: CGRect(x: view.frame.width - 200, y: 10, width: 200, height: 30))
        morebutton.setTitle("LOAD MORE", for: .normal)
        morebutton.addTarget(self, action: "loadMore", for: .touchUpInside)
        morebutton.backgroundColor = UIColor.blue
        morebutton.setTitleColor(UIColor.white, for: .normal)
        view.addSubview(morebutton)
    }
    
    func loadMore() {
        morebutton.backgroundColor = UIColor.gray
        self.events = nil
        tableView.reloadData()
        sgcontroller.loadNextEvents(completion: {
            events in
            self.events = events
            self.morebutton.backgroundColor = UIColor.blue
            self.tableView.reloadData()
        })
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 400
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? SeatGeekCell {
            if let event = events?[indexPath.row] {
                cell.setInfo(event: event, index: indexPath.row)
            }
            cell.delegate = self
            cell.selectionStyle = .none
            return cell
        }
        return UITableViewCell()
    }
    
    func didDeny(event: SeatGeekObject, index: Int) {
        events?.remove(at: index)
        tableView.reloadData()
        if let id = event.id {
            NetworkController().denySeatGeek(sgid: id)
        }
    }
    
    func didProceed(event: SeatGeekObject, index: Int) {
        
    }
    
    func didEdit(event: SeatGeekObject, index: Int) {
        events?.remove(at: index)
        tableView.reloadData()
        if let nextvc = self.tabBarController?.viewControllers?[1] as? BandEntryVC {
            nextvc.seatGeekObject = event
            self.tabBarController?.selectedIndex = 1
        }
    }
    
    func closeVid() {
        if let subview = subview {
            subview.removeFromSuperview()
            close.removeFromSuperview()
        }
    }
    
    func seeYoutube(event: SeatGeekObject, index: Int) {
        if let ytstring = event.youtube {
            let videovc = VideoVC()
            videovc.youtube = ytstring
            videovc.view.frame = CGRect(x: 0, y: 50, width: videovc.view.frame.width, height: videovc.view.frame.height - 100)
            view.addSubview(videovc.view)
            subview = videovc.view
        }
        
        close = UIButton(frame: CGRect(x: 10, y: 10, width: 50, height: 40))
        close.setTitle("Close", for: .normal)
        close.backgroundColor = UIColor.red
        close.addTarget(self, action: "closeVid", for: .touchUpInside)
        view.addSubview(close)
    }
}
